public Action StartKnifeRound(Handle timer) {
    g_PendingSideSwap = false;

    Get5_MessageToAll("The knife round will begin in 5 seconds.");
    if (InWarmup())
        EndWarmup(5);
    else
        RestartGame(5);

    CreateTimer(10.0, Timer_AnnounceKnife);
    return Plugin_Handled;
}

public Action Timer_AnnounceKnife(Handle timer) {
    for (int i = 0; i < 5; i++)
        Get5_MessageToAll("Knife!");

    return Plugin_Handled;
}

public void EndKnifeRound(bool swap) {
    if (swap) {
        SwapSides();
        for (int i = 1; i <= MaxClients; i++) {
            if (IsValidClient(i)) {
                if (IsClientInGame(i) && IsPlayerAlive(i)) {
                    ForcePlayerSuicide(i);
                }
                int team = GetClientTeam(i);
                if (team == CS_TEAM_T) {
                    SwitchPlayerTeam(i, CS_TEAM_CT);
                } else if (team == CS_TEAM_CT) {
                    SwitchPlayerTeam(i, CS_TEAM_T);
                } else if (IsClientCoaching(i))  {
                    int correctTeam = MatchTeamToCSTeam(GetClientMatchTeam(i));
                    UpdateCoachTarget(i, correctTeam);
                }
            }
        }
    } else {
        g_TeamSide[MatchTeam_Team1] = CS_TEAM_CT;
        g_TeamSide[MatchTeam_Team2] = CS_TEAM_T;
    }

    ChangeState(GameState_GoingLive);
    CreateTimer(3.0, StartGoingLive, _, TIMER_FLAG_NO_MAPCHANGE);
}

static bool AwaitingKnifeDecision(int client) {
    bool waiting = g_GameState == GameState_WaitingForKnifeRoundDecision;
    bool onWinningTeam = IsPlayer(client) && GetClientMatchTeam(client) == g_KnifeWinnerTeam;
    bool admin = (client == 0);
    return waiting && (onWinningTeam || admin);
}

public Action Command_Stay(int client, int args) {
    if (AwaitingKnifeDecision(client)) {
        if(g_AlreadyVoted[client] == 1){
            ReplyToCommand(client, ">> You have already voted.");
        }else{
            g_AlreadyVoted[client] = 1;
            g_TeamStayVotes++;
            ReplyToCommand(client, ">> You voted to stay.");
        }
    }else{
        //Unsure if this is actually necessary...
        //ReplyToCommand(client, ">> You may not use this command at this time.");
    }
    return Plugin_Handled;
}

public Action Command_Swap(int client, int args) {
    if (AwaitingKnifeDecision(client)) {
        if(g_AlreadyVoted[client] == 1){
            ReplyToCommand(client, ">> You have already voted.");
        }else{
            g_AlreadyVoted[client] = 1;
            g_TeamSwapVotes++;
            ReplyToCommand(client, ">> You voted to swap.");
        }
    }else{
        //Unsure if this is actually necessary...
        //ReplyToCommand(client, ">> You may not use this command at this time.");
    }
    return Plugin_Handled;
}

public Action Command_Ct(int client, int args) {
    if (IsPlayer(client)) {
        if (GetClientTeam(client) == CS_TEAM_CT)
            FakeClientCommand(client, "sm_stay");
        else if (GetClientTeam(client) == CS_TEAM_T)
            FakeClientCommand(client, "sm_swap");
    }

    //LogDebug("cs team = %d", GetClientTeam(client));
    //LogDebug("m_iCoachingTeam = %d", GetEntProp(client, Prop_Send, "m_iCoachingTeam"));
    //LogDebug("m_iPendingTeamNum = %d",  GetEntProp(client, Prop_Send, "m_iPendingTeamNum"));

    return Plugin_Handled;
}

public Action Command_T(int client, int args) {
    if (IsPlayer(client)) {
        if (GetClientTeam(client) == CS_TEAM_T)
            FakeClientCommand(client, "sm_stay");
        else if (GetClientTeam(client) == CS_TEAM_CT)
            FakeClientCommand(client, "sm_swap");
    }

    //LogDebug("cs team = %d", GetClientTeam(client));
    //LogDebug("m_iCoachingTeam = %d", GetEntProp(client, Prop_Send, "m_iCoachingTeam"));
    //LogDebug("m_iPendingTeamNum = %d",  GetEntProp(client, Prop_Send, "m_iPendingTeamNum"));

    return Plugin_Handled;
}

public Action Stay_or_Swap(Handle timer){

    if(g_TeamStayVotes > g_TeamSwapVotes){
        //Stay
        EndKnifeRound(false);
        Get5_MessageToAll("{YELLOW}%s{NORMAL} has voted to stay.", g_TeamNames[g_KnifeWinnerTeam]);
    }else if(g_TeamStayVotes < g_TeamSwapVotes){
        //Swap
        EndKnifeRound(true);
        Get5_MessageToAll("{YELLOW}%s{NORMAL} has voted to swap.", g_TeamNames[g_KnifeWinnerTeam]);
    }else if(g_TeamStayVotes > 0 && g_TeamSwapVotes > 0 && g_TeamStayVotes == g_TeamSwapVotes){
        if (GetRandomFloat(0.0, 1.0) < 0.5) {
            //Stay
            EndKnifeRound(false);
            Get5_MessageToAll("{YELLOW}%s{NORMAL} has tied votes. They have been randomly selected to stay.", g_TeamNames[g_KnifeWinnerTeam]);
        } else {
            //Swap
            EndKnifeRound(true);
            Get5_MessageToAll("{YELLOW}%s{NORMAL} has tied votes. They have been randomly selected to swap.", g_TeamNames[g_KnifeWinnerTeam]);
        }
    }else if(g_TeamStayVotes == 0 && g_TeamSwapVotes == 0){
        if (GetRandomFloat(0.0, 1.0) < 0.5) {
            //Stay
            EndKnifeRound(false);
            Get5_MessageToAll("{YELLOW}%s{NORMAL} did not vote. They have been randomly selected to stay.", g_TeamNames[g_KnifeWinnerTeam]);
        } else {
            //Swap
            EndKnifeRound(true);
            Get5_MessageToAll("{YELLOW}%s{NORMAL} did not vote. They have been randomly selected to swap.", g_TeamNames[g_KnifeWinnerTeam]);
        }
    }
}
