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
        EndKnifeRound(false);
        Get5_MessageToAll("%s has decided to stay.", g_FormattedTeamNames[g_KnifeWinnerTeam]);
    }
    return Plugin_Handled;
}

public Action Command_Swap(int client, int args) {
    if (AwaitingKnifeDecision(client)) {
        EndKnifeRound(true);
        Get5_MessageToAll("%s has decided to swap.", g_FormattedTeamNames[g_KnifeWinnerTeam]);
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

    LogDebug("cs team = %d", GetClientTeam(client));
    LogDebug("m_iCoachingTeam = %d", GetEntProp(client, Prop_Send, "m_iCoachingTeam"));
    LogDebug("m_iPendingTeamNum = %d",  GetEntProp(client, Prop_Send, "m_iPendingTeamNum"));


    return Plugin_Handled;
}

public Action Command_T(int client, int args) {
    if (IsPlayer(client)) {
        if (GetClientTeam(client) == CS_TEAM_T)
            FakeClientCommand(client, "sm_stay");
        else if (GetClientTeam(client) == CS_TEAM_CT)
            FakeClientCommand(client, "sm_swap");
    }
    return Plugin_Handled;
}
