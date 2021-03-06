#include <cstrike>
#include <sdktools>
#include <sourcemod>
#include <testing>
#include "include/restorecvars.inc"
#include "include/logdebug.inc"
#include "include/kiwi.inc"

#undef REQUIRE_EXTENSIONS
#include <SteamWorks>
#include <system2>
#include <smjansson>
#include <advanced_motd>
#include <steamtools>



#define CURL_DEFAULT_OPT(%1) curl_easy_setopt_int_array(%1, CURL_Default_opt, sizeof(CURL_Default_opt))
#define REMOTE_CONFIG_FILENAME "remote.json"

#define LIVE_TIMER_INTERVAL 1.0
#define INFO_MESSAGE_TIMER_INTERVAL 29.0

#define DEBUG_CVAR "kiwi_debug"
#define MATCH_ID_LENGTH 64
#define MATCH_NAME_LENGTH 64
#define MAX_CVAR_LENGTH 128
#define MATCH_END_DELAY_AFTER_TV 10

#define TEAM1_COLOR "{LIGHT_GREEN}"
#define TEAM2_COLOR "{PINK}"
#define TEAM1_STARTING_SIDE CS_TEAM_CT
#define TEAM2_STARTING_SIDE CS_TEAM_T
#define KNIFE_CONFIG "kiwi/knife.cfg"

#pragma semicolon 1
#pragma newdecls required



/***********************
 *                     *
 *   Global variables  *
 *                     *
 ***********************/

/** ConVar handles **/
ConVar g_AutoLoadConfigCvar;
ConVar g_CheckAuthsCvar;
ConVar g_DemoNameFormatCvar;
ConVar g_DemoTimeFormatCvar;
ConVar g_KickClientsWithNoMatchCvar;
ConVar g_LiveCfgCvar;
ConVar g_PausingEnabledCvar;
ConVar g_StopCommandEnabledCvar;
ConVar g_WaitForSpecReadyCvar;
ConVar g_WarmupCfgCvar;
ConVar g_MatchUrlFormatCvar;

ConVar g_VersionCvar;

// Hooked cvars built into csgo
ConVar g_CoachingEnabledCvar;

/** Series config game-state **/
int g_MapsToWin = 1;
bool g_BO2Match = false;
char g_MatchID[MATCH_ID_LENGTH];
ArrayList g_MapPoolList = null;
ArrayList g_TeamAuths[MatchTeam_Count];
char g_TeamNames[MatchTeam_Count][MAX_CVAR_LENGTH];
char g_FormattedTeamNames[MatchTeam_Count][MAX_CVAR_LENGTH];
char g_TeamFlags[MatchTeam_Count][MAX_CVAR_LENGTH];
char g_TeamLogos[MatchTeam_Count][MAX_CVAR_LENGTH];
char g_TeamMatchTexts[MatchTeam_Count][MAX_CVAR_LENGTH];
char g_MatchTitle[MAX_CVAR_LENGTH];
int g_FavoredTeamPercentage = 0;
char g_FavoredTeamText[MAX_CVAR_LENGTH];
int g_PlayersPerTeam = 5;
bool g_SkipVeto = false;
MatchSideType g_MatchSideType = MatchSideType_Standard;
ArrayList g_CvarNames = null;
ArrayList g_CvarValues = null;

/**Team Surrender Votes**/
int g_Team1SurrenderVotes = 0;
int g_Team2SurrenderVotes = 0;
int g_AlreadySurrendered[MAXPLAYERS+1];
int g_TeamSurrendered = 0;

/** Other state **/
GameState g_GameState = GameState_None;
ArrayList g_MapsToPlay = null;
ArrayList g_MapSides = null;
ArrayList g_MapsLeftInVetoPool = null;
MatchTeam g_LastVetoTeam;
bool g_RestoreMatchBackup = false;

// Stats values
bool g_SetTeamClutching[4];
int g_RoundKills[MAXPLAYERS+1]; // kills per round
int g_RoundClutchingEnemyCount[MAXPLAYERS+1]; // number of enemies left alive when last alive on your team
int g_LastFlashBangThrower = -1;
int g_RoundFlashedBy[MAXPLAYERS+1];
KeyValues g_StatsKv;

ArrayList g_TeamScoresPerMap = null;
char g_LoadedConfigFile[PLATFORM_MAX_PATH];
int g_VetoCaptains[MatchTeam_Count]; // Clients doing the map vetos.
int g_TeamSeriesScores[MatchTeam_Count]; // Current number of maps won per-team.
bool g_TeamReady[MatchTeam_Count]; // Whether a team is marked as ready.
int g_TeamSide[MatchTeam_Count]; // Current CS_TEAM_* side for the team.
bool g_TeamReadyForUnpause[MatchTeam_Count];
bool g_TeamGivenStopCommand[MatchTeam_Count];

/** Map game-state **/
MatchTeam g_KnifeWinnerTeam = MatchTeam_TeamNone;
int g_TeamSwapVotes = 0;
int g_TeamStayVotes = 0;
int g_AlreadyVoted[MAXPLAYERS+1];

/** Map-game state not related to the actual gameplay **/
char g_DemoFileName[PLATFORM_MAX_PATH];
bool g_MapChangePending = false;
bool g_MovingClientToCoach[MAXPLAYERS+1];
bool g_PendingSideSwap = false;

Handle g_KnifeChangedCvars = INVALID_HANDLE;

/** Forwards **/
Handle g_OnDemoFinished = INVALID_HANDLE;
Handle g_OnGameStateChanged = INVALID_HANDLE;
Handle g_OnGoingLive = INVALID_HANDLE;
Handle g_OnLoadMatchConfigFailed = INVALID_HANDLE;
Handle g_OnMapPicked = INVALID_HANDLE;
Handle g_OnMapResult = INVALID_HANDLE;
Handle g_OnMapVetoed = INVALID_HANDLE;
Handle g_OnRoundStatsUpdated = INVALID_HANDLE;
Handle g_OnSeriesInit = INVALID_HANDLE;
Handle g_OnSeriesResult = INVALID_HANDLE;

#include "kiwi/util.sp"
#include "kiwi/kniferounds.sp"
#include "kiwi/goinglive.sp"
#include "kiwi/maps.sp"
#include "kiwi/mapveto.sp"
#include "kiwi/matchconfig.sp"
#include "kiwi/natives.sp"
#include "kiwi/teamlogic.sp"
#include "kiwi/tests.sp"
#include "kiwi/version.sp"
#include "kiwi/jsonhelpers.sp"
#include "kiwi/stats.sp"



/***********************
 *                     *
 * Sourcemod forwards  *
 *                     *
 ***********************/

public Plugin myinfo = {
    name = "[KIWI] PUG",
    author = "drop",
    description = "The KIWI PUG plugin",
    version = PLUGIN_VERSION,
    url = "https://kiir.us"
};

public void OnPluginStart() {
    InitDebugLog(DEBUG_CVAR, "kiwi");

    /** ConVars **/
    g_AutoLoadConfigCvar = CreateConVar("kiwi_autoload_config", "",
        "Name of a match config file to automatically load when the server loads");
    g_CheckAuthsCvar = CreateConVar("kiwi_check_auths", "1",
        "If set to 0, kiwi will not force players to the correct team based on steamid");
    g_DemoNameFormatCvar = CreateConVar("kiwi_demo_name_format",
        "kiwi-{MATCHID}", "Format for demo file names");
    g_DemoTimeFormatCvar = CreateConVar("kiwi_time_format", "%Y-%m-%d_%H",
        "Time format to use when creating demo file names. Don't tweak this unless you know what you're doing! Avoid using spaces or colons.");
    g_KickClientsWithNoMatchCvar = CreateConVar("kiwi_kick_when_no_match_loaded", "1",
        "Whether the plugin kicks new clients when no match is loaded");
    g_LiveCfgCvar = CreateConVar("kiwi_live_cfg", "kiwi/live.cfg",
        "Config file to exec when the game goes live");
    g_PausingEnabledCvar = CreateConVar("kiwi_pausing_enabled", "1",
        "Whether pausing is allowed.");
    g_StopCommandEnabledCvar = CreateConVar("kiwi_stop_command_enabled", "0",
        "Whether clients can use the !stop command to restore to the last round");
    g_WaitForSpecReadyCvar = CreateConVar("kiwi_wait_for_spec_ready", "0",
        "Whether to wait for spectators to ready up if there are any");
    g_WarmupCfgCvar = CreateConVar("kiwi_warmup_cfg", "kiwi/warmup.cfg",
        "Config file to exec in warmup periods");
    g_MatchUrlFormatCvar = CreateConVar("kiwi_match_url", "https://kiir.us/match/{MATCHID}",
        "The url of the current match");

    /** Create and exec plugin's configuration file **/
    AutoExecConfig(true, "kiwi");

    g_VersionCvar = CreateConVar("kiwi_version", PLUGIN_VERSION, "Current kiwi version", FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
    g_VersionCvar.SetString(PLUGIN_VERSION);

    g_CoachingEnabledCvar = FindConVar("sv_coaching_enabled");

    /** Client commands **/
    RegConsoleCmd("sm_ready", Command_Ready, "Marks the client as ready");
    //RegConsoleCmd("sm_unready", Command_NotReady, "Marks the client as not ready");
    //RegConsoleCmd("sm_notready", Command_NotReady, "Marks the client as not ready");
    RegConsoleCmd("sm_pause", Command_Pause, "Pauses the game");
    RegConsoleCmd("sm_unpause", Command_Unpause, "Unpauses the game");
    //RegConsoleCmd("sm_coach", Command_SmCoach, "Marks a client as a coach for their team");
    RegConsoleCmd("sm_stay", Command_Stay, "Elects to stay on the current team after winning a knife round");
    RegConsoleCmd("sm_swap", Command_Swap, "Elects to swap the current teams after winning a knife round");
    RegConsoleCmd("sm_switch", Command_Swap, "Elects to swap the current teams after winning a knife round");
    RegConsoleCmd("sm_t", Command_T, "Elects to start on T side after winning a knife round");
    RegConsoleCmd("sm_ct", Command_Ct, "Elects to start on CT side after winning a knife round");
    RegConsoleCmd("sm_gg", Command_Gg, "Cast your vote to surrender. On 5 votes to surrender, game will end.");
    RegConsoleCmd("sm_surrender", Command_Gg, "Cast your vote to surrender. On 5 votes to surrender, game will end.");
    //RegConsoleCmd("sm_stop", Command_Stop, "Elects to stop the game to reload a backup file");
    RegConsoleCmd("sm_pug", Command_Pug, "Shows PUG match page for current match");
    RegConsoleCmd("sm_group", Command_Group, "Shows the KIWI group page");
    //RegConsoleCmd("sm_stats", Command_Stats, "Shows a player's profile page");

    /** Admin/server commands **/
    RegAdminCmd("kiwi_loadmatch", Command_LoadMatch, ADMFLAG_CHANGEMAP,
        "Loads a match config file (json or keyvalues) from a file relative to the csgo/ directory");
    RegAdminCmd("loadmatch_url", Command_LoadMatchUrl, ADMFLAG_CHANGEMAP,
        "Loads a JSON config file by sending a GET request to download it. Requires either the SteamWorks or system2 extensions");
    RegAdminCmd("kiwi_loadteam", Command_LoadTeam, ADMFLAG_CHANGEMAP,
        "Loads a team data from a file into a team");
    RegAdminCmd("kiwi_endmatch", Command_EndMatch, ADMFLAG_CHANGEMAP,
        "Force ends the current match");
    RegAdminCmd("addplayer", Command_AddPlayer, ADMFLAG_CHANGEMAP,
        "Adds a steamid to a match team");
    RegAdminCmd("removeplayer", Command_RemovePlayer, ADMFLAG_CHANGEMAP,
        "Removes a steamid to a match team");
    RegAdminCmd("kiwi_creatematch", Command_CreateMatch, ADMFLAG_CHANGEMAP,
        "Creates and loads a match using the players currently on the server as a Bo1 with the current map");
    RegAdminCmd("forceready", Command_ForceReady, ADMFLAG_CHANGEMAP,
        "Force readies all current teams");
    RegAdminCmd("dumpstats", Command_DumpStats, ADMFLAG_CHANGEMAP,
        "Dumps match stats to a file");
    RegAdminCmd("cancelmatch", Command_Cancelmatch, ADMFLAG_CHANGEMAP,
        "Force ends the match and kicks all clients");
    RegAdminCmd("colortest", Command_Colortest, ADMFLAG_CHANGEMAP,
        "Displays all possible colors in CS");

    /** Other commands **/
    RegConsoleCmd("kiwi_status", Command_Status, "Prints JSON formatted match state info");
    RegServerCmd("kiwi_test", Command_Test,
        "Runs tests - should not be used on a live match server since it will reload a match config to test");

    /** Hooks **/
    HookEvent("player_spawn", Event_PlayerSpawn);
    HookEvent("cs_win_panel_match", Event_MatchOver);
    HookEvent("round_prestart", Event_RoundPreStart);
    HookEvent("round_end", Event_RoundEnd);
    HookEvent("server_cvar", Event_CvarChanged, EventHookMode_Pre);
    HookEvent("player_connect_full", Event_PlayerConnectFull);
    HookEvent("player_team", Event_OnPlayerTeam, EventHookMode_Pre);
    Stats_PluginStart();
    Stats_InitSeries();

    AddCommandListener(Command_Coach, "coach");
    AddCommandListener(Command_JoinTeam, "jointeam");
    AddCommandListener(Command_JoinGame, "joingame");

    /** Setup data structures **/
    g_MapPoolList = new ArrayList(PLATFORM_MAX_PATH);
    g_MapsLeftInVetoPool = new ArrayList(PLATFORM_MAX_PATH);
    g_MapsToPlay = new ArrayList(PLATFORM_MAX_PATH);
    g_MapSides = new ArrayList();
    g_CvarNames = new ArrayList(MAX_CVAR_LENGTH);
    g_CvarValues = new ArrayList(MAX_CVAR_LENGTH);
    g_TeamScoresPerMap = new ArrayList(view_as<int>(MatchTeam_Count));

    for (int i = 0; i < sizeof(g_TeamAuths); i++) {
        g_TeamAuths[i] = new ArrayList(AUTH_LENGTH);
    }

    /** Create forwards **/
    g_OnDemoFinished = CreateGlobalForward("Get5_OnDemoFinished", ET_Ignore,
        Param_String);
    g_OnGameStateChanged = CreateGlobalForward("Get5_OnGameStateChanged", ET_Ignore,
        Param_Cell, Param_Cell);
    g_OnGoingLive = CreateGlobalForward("Get5_OnGoingLive", ET_Ignore,
        Param_Cell);
    g_OnMapResult = CreateGlobalForward("Get5_OnMapResult", ET_Ignore,
        Param_String, Param_Cell, Param_Cell, Param_Cell, Param_Cell);
    g_OnLoadMatchConfigFailed = CreateGlobalForward("Get5_OnLoadMatchConfigFailed", ET_Ignore,
        Param_String);
    g_OnMapPicked =  CreateGlobalForward("Get5_OnMapPicked", ET_Ignore,
        Param_Cell, Param_String);
    g_OnMapVetoed = CreateGlobalForward("Get5_OnMapVetoed", ET_Ignore,
        Param_Cell, Param_String);
    g_OnRoundStatsUpdated = CreateGlobalForward("Get5_OnRoundStatsUpdated", ET_Ignore);
    g_OnSeriesInit = CreateGlobalForward("Get5_OnSeriesInit", ET_Ignore);
    g_OnSeriesResult = CreateGlobalForward("Get5_OnSeriesResult", ET_Ignore,
        Param_Cell, Param_Cell, Param_Cell);

    /** Start any repeating timers **/
    CreateTimer(LIVE_TIMER_INTERVAL, Timer_CheckReady, _, TIMER_REPEAT);
    CreateTimer(INFO_MESSAGE_TIMER_INTERVAL, Timer_InfoMessages, _, TIMER_REPEAT);

    // HTTPRequestHandle hPost = Steam_CreateHTTPRequest(HTTPMethod_POST, "http://192.168.1.12:3000/api/matchover");
    // Steam_SetHTTPRequestGetOrPostParameter( hPost, "matchid", "5" );
    // Steam_SetHTTPRequestGetOrPostParameter( hPost, "winningteam", "yesdos" );
    // Steam_SendHTTPRequest( hPost, HTTPRequestComplete );
}

public HTTPRequestComplete(HTTPRequestHandle HTTPRequest, bool requestSuccessful, HTTPStatusCode statusCode) {
        Get5_MessageToAll("Sent endmatch request");
        return;
}

public Action Timer_InfoMessages(Handle timer) {
    if (g_GameState == GameState_PreVeto) {
        //Get5_MessageToAll("Type {GREEN}!ready {NORMAL}when your team is ready to veto.");
        //ServerCommand("sm_hsay The match will start after all %d players have connected, otherwise it will be cancelled after 5 minutes.", (g_PlayersPerTeam * 2));
    } else if (g_GameState == GameState_Warmup && !g_MapChangePending) {
        if (AllTeamsReady(false) && !AllTeamsReady(true)) {
            //Get5_MessageToAll("Waiting for the casters to type {GREEN}!ready {NORMAL}to begin.");
        } else {
            SideChoice sides = view_as<SideChoice>(g_MapSides.Get(GetMapNumber()));
            if (sides == SideChoice_KnifeRound) {
                //Get5_MessageToAll("Type {GREEN}!ready {NORMAL}when your team is ready to knife.");
            } else {
                //Get5_MessageToAll("Type {GREEN}!ready {NORMAL}when your team is ready to begin.");
            }
        }
    } else if (g_GameState == GameState_WaitingForKnifeRoundDecision) {
        //Get5_MessageToAll("%s won the knife round. Waiting for them to type !stay or !swap.",
            //g_FormattedTeamNames[g_KnifeWinnerTeam]);

    } else if (g_GameState == GameState_PostGame) {
        Get5_MessageToAll("The map will change once the GOTV broadcast has ended.");
    }
}

public void OnClientAuthorized(int client, const char[] auth) {
    g_MovingClientToCoach[client] = false;
    if (StrEqual(auth, "BOT", false)) {
        return;
    }

    if (g_GameState == GameState_None && g_KickClientsWithNoMatchCvar.IntValue != 0) {
        KickClient(client, "[KIWI] You are not authorized to join this server");
    }

    if (g_GameState != GameState_None && g_CheckAuthsCvar.IntValue != 0) {
        MatchTeam team = GetClientMatchTeam(client);
        if (team == MatchTeam_TeamNone) {
            KickClient(client, "[KIWI] You are not a player in this match");
        } else {
            int teamCount = CountPlayersOnMatchTeam(team, client);
            if (teamCount >= g_PlayersPerTeam && g_CoachingEnabledCvar.IntValue == 0) {
                KickClient(client, "[KIWI] Your team is full");
            }
        }
    }
}

public void OnClientPutInServer(int client) {
    if (IsFakeClient(client)) {
        return;
    }

    CheckAutoLoadConfig();
    if (g_GameState <= GameState_Warmup && g_GameState != GameState_None) {
        if (GetRealClientCount() <= 1) {
            ExecCfg(g_WarmupCfgCvar);
            EnsurePausedWarmup();
        }
    }

    Stats_ResetClientRoundValues(client);
}

/**
 * Full connect event right when a player joins.
 * This sets the auto-pick time to a high value because mp_forcepicktime is broken and
 * if a player does not select a team but leaves their mouse over one, they are
 * put on that team and spawned, so we can't allow that.
 */
public Action Event_PlayerConnectFull(Handle event, const char[] name, bool dontBroadcast) {
    int client = GetClientOfUserId(GetEventInt(event, "userid"));
    SetEntPropFloat(client, Prop_Send, "m_fForceTeam", 3600.0);
}

public void OnMapStart() {
    g_MapChangePending = false;

    LOOP_TEAMS(team) {
        g_TeamReady[team] = false;
        g_TeamGivenStopCommand[team] = false;
        g_TeamReadyForUnpause[team] = false;
    }

    SetStartingTeams();
    CheckAutoLoadConfig();

    if (g_GameState == GameState_PostGame) {
        ChangeState(GameState_Warmup);
    }

    if (g_GameState == GameState_Warmup || g_GameState == GameState_Veto) {
        ExecCfg(g_WarmupCfgCvar);
        SetMatchTeamCvars();
        ExecuteMatchConfigCvars();
        EnsurePausedWarmup();
    }
}

public Action Timer_CheckReady(Handle timer) {
    if (g_GameState == GameState_PreVeto) {
        if (AllTeamsReady(false)) {
            ChangeState(GameState_Veto);
            CreateMapVeto();
        }

    } else  if (g_GameState == GameState_Warmup) {
        if (AllTeamsReady(true) && !g_MapChangePending) {
            int mapNumber = GetMapNumber();
            if (g_MapSides.Get(mapNumber) == SideChoice_KnifeRound) {
                ChangeState(GameState_KnifeRound);
                StartGame(true);
            } else {
                StartGame(false);
            }
        }
    }

    return Plugin_Continue;
}

static void CheckAutoLoadConfig() {
    if (g_GameState == GameState_None) {
        char autoloadConfig[PLATFORM_MAX_PATH];
        g_AutoLoadConfigCvar.GetString(autoloadConfig, sizeof(autoloadConfig));
        if (!StrEqual(autoloadConfig, "")) {
            LoadMatchConfig(autoloadConfig);
        }
    }
}


/***********************
 *                     *
 *     Commands        *
 *                     *
 ***********************/

static bool Pauseable() {
    return g_GameState >= GameState_KnifeRound && g_PausingEnabledCvar.IntValue != 0;
}

public Action Command_Pause(int client, int args) {
    if (!Pauseable() || IsPaused())
        return Plugin_Handled;

    g_TeamReadyForUnpause[MatchTeam_Team1] = false;
    g_TeamReadyForUnpause[MatchTeam_Team2] = false;
    Pause();
    if (IsPlayer(client)) {
        Get5_MessageToAll("%N paused the match.", client);
    }

    return Plugin_Handled;
}

public Action Command_Unpause(int client, int args) {
    if (!IsPaused())
        return Plugin_Handled;

    // Let console force unpause
    if (client == 0) {
        Unpause();
    } else {
        MatchTeam team = GetClientMatchTeam(client);
        g_TeamReadyForUnpause[team] = true;

        if (g_TeamReadyForUnpause[MatchTeam_Team1] && g_TeamReadyForUnpause[MatchTeam_Team2])  {
            Unpause();
            if (IsPlayer(client)) {
                Get5_MessageToAll("%N unpaused the match.", client);
            }
        } else if (g_TeamReadyForUnpause[MatchTeam_Team1] && !g_TeamReadyForUnpause[MatchTeam_Team2]) {
            Get5_MessageToAll("%s wants to unpause, waiting for %s to type !unpause.",
                g_FormattedTeamNames[MatchTeam_Team1], g_FormattedTeamNames[MatchTeam_Team2]);
        } else if (!g_TeamReadyForUnpause[MatchTeam_Team1] && g_TeamReadyForUnpause[MatchTeam_Team2]) {
            Get5_MessageToAll("%s wants to unpause, waiting for %s to type !unpause.",
                g_FormattedTeamNames[MatchTeam_Team2], g_FormattedTeamNames[MatchTeam_Team1]);
        }
    }

    return Plugin_Handled;
}

public Action Command_Ready(int client, int args) {
    if (g_GameState == GameState_None) {
        return Plugin_Handled;
    }

    ReplyToCommand(client, ">> The match will begin automatically when all players connect. There's no need to ready up.");
    return Plugin_Handled;

    /**MatchTeam t = GetCaptainTeam(client);

    if (t == MatchTeam_Team1 && !g_TeamReady[MatchTeam_Team1]) {
        g_TeamReady[MatchTeam_Team1] = true;
        if (g_GameState == GameState_PreVeto) {
            Get5_MessageToAll("%s is ready to veto.", g_FormattedTeamNames[MatchTeam_Team1]);
        } else if (g_GameState == GameState_Warmup) {
            SideChoice sides = view_as<SideChoice>(g_MapSides.Get(GetMapNumber()));
            if (sides == SideChoice_KnifeRound)
                Get5_MessageToAll("%s is ready to knife for sides.", g_FormattedTeamNames[MatchTeam_Team1]);
            else
                Get5_MessageToAll("%s is ready to begin the match.", g_FormattedTeamNames[MatchTeam_Team1]);
        }
    } else if (t == MatchTeam_Team2 && !g_TeamReady[MatchTeam_Team2]) {
        g_TeamReady[MatchTeam_Team2] = true;
        if (g_GameState == GameState_PreVeto) {
            Get5_MessageToAll("%s is ready to veto.", g_FormattedTeamNames[MatchTeam_Team2]);
        } else if (g_GameState == GameState_Warmup) {
            SideChoice sides = view_as<SideChoice>(g_MapSides.Get(GetMapNumber()));
            if (sides == SideChoice_KnifeRound)
                Get5_MessageToAll("%s is ready to knife for sides.", g_FormattedTeamNames[MatchTeam_Team2]);
            else
                Get5_MessageToAll("%s is ready to begin the match.", g_FormattedTeamNames[MatchTeam_Team2]);
        }
    }
    return Plugin_Handled;**/
}

public Action Command_NotReady(int client, int args) {
    if (g_GameState == GameState_None) {
        return Plugin_Handled;
    }

    MatchTeam t = GetCaptainTeam(client);
    if (t == MatchTeam_Team1 && g_TeamReady[MatchTeam_Team1]) {
        Get5_MessageToAll("%s is no longer ready.", g_FormattedTeamNames[MatchTeam_Team1]);
        g_TeamReady[MatchTeam_Team1] = false;
    } else if (t == MatchTeam_Team2 && g_TeamReady[MatchTeam_Team2]) {
        Get5_MessageToAll("%s is no longer ready.", g_FormattedTeamNames[MatchTeam_Team2]);
        g_TeamReady[MatchTeam_Team2] = false;
    }
    return Plugin_Handled;
}

public Action Command_ForceReady(int client, int args) {
    if (g_GameState != GameState_PreVeto && g_GameState != GameState_Warmup) {
        return Plugin_Handled;
    }

    //Get5_MessageToAll("An admin has force-readied all teams.");
    Get5_MessageToAll("All players connected. The match will now begin.");
    LOOP_TEAMS(team) {
        g_TeamReady[team] = true;
    }

    return Plugin_Handled;
}

public Action Command_EndMatch(int client, int args) {
    if (g_GameState == GameState_None) {
        return Plugin_Handled;
    }
    ChangeState(GameState_None);

    Get5_MessageToAll("An admin force ended the match.");
    return Plugin_Handled;
}

public Action Command_LoadMatch(int client, int args) {
    if (g_GameState != GameState_None) {
        ReplyToCommand(client, "Cannot load a match when a match is already loaded");
        return Plugin_Handled;
    }

    char arg[PLATFORM_MAX_PATH];
    if (args >= 1 && GetCmdArg(1, arg, sizeof(arg))) {
        if (!LoadMatchConfig(arg)) {
            ReplyToCommand(client, "[KIWI] Failed to load match config.");
        }else{
            ReplyToCommand(client, "[KIWI] Successfuly loaded match.");
        }
    } else {
        ReplyToCommand(client, "Usage: kiwi_loadmatch <filename>");
    }

    return Plugin_Handled;
}

public Action Command_LoadMatchUrl(int client, int args) {
    if (g_GameState != GameState_None) {
        ReplyToCommand(client, "Cannot load a match config with another match already loaded");
        return Plugin_Handled;
    }

    bool steamWorksAvaliable = LibraryExists("SteamWorks");
    bool system2Avaliable = LibraryExists("system2");

    if (!steamWorksAvaliable && !system2Avaliable) {
        ReplyToCommand(client, "[KIWI] Cannot load matches from a url without the SteamWorks or system2 extension running");
    } else {
        char arg[PLATFORM_MAX_PATH];
        if (args >= 1 && GetCmdArg(1, arg, sizeof(arg))) {
            if (!LoadMatchFromUrl(arg)) {
                ReplyToCommand(client, "[KIWI] Failed to load match config.");
            }else{
                ReplyToCommand(client, "[KIWI] Successfuly loaded match.");
            }
        } else {
            ReplyToCommand(client, "Usage: loadmatch_url <url>");
        }
    }

    return Plugin_Handled;
}

public Action Command_DumpStats(int client, int args) {
    if (g_GameState == GameState_None) {
        ReplyToCommand(client, "Cannot dump match stats with no match existing");
        return Plugin_Handled;
    }

    char arg[PLATFORM_MAX_PATH];
    if (args < 1) {
        arg = "kiwi_matchstats.cfg";
    } else {
        GetCmdArg(1, arg, sizeof(arg));
    }

    if (g_StatsKv.ExportToFile(arg)) {
        g_StatsKv.Rewind();
        ReplyToCommand(client, "[KIWI] Saved match stats to %s", arg);
    } else {
        ReplyToCommand(client, "[KIWI] Failed to save match stats to %s", arg);
    }

    return Plugin_Handled;
}

public Action Command_Stop(int client, int args) {
    if (g_StopCommandEnabledCvar.IntValue == 0) {
        return Plugin_Handled;
    }

    int roundsPlayed = GameRules_GetProp("m_totalRoundsPlayed");
    if (g_GameState != GameState_Live || roundsPlayed == 0) {
        return Plugin_Handled;
    }

    // Let the server/rcon always force restore.
    if (client == 0) {
        RestoreLastRound();
    }

    MatchTeam team = GetClientMatchTeam(client);
    g_TeamGivenStopCommand[team] = true;

    if (g_TeamGivenStopCommand[MatchTeam_Team1] && !g_TeamGivenStopCommand[MatchTeam_Team2]) {
        Get5_MessageToAll("%s wants to stop and reload last round, need %s to confirm with !stop.",
            g_FormattedTeamNames[MatchTeam_Team1], g_FormattedTeamNames[MatchTeam_Team2]);
    } else if (!g_TeamGivenStopCommand[MatchTeam_Team1] && g_TeamGivenStopCommand[MatchTeam_Team2]) {
        Get5_MessageToAll("%s wants to stop and reload last round, need %s to confirm with !stop.",
            g_FormattedTeamNames[MatchTeam_Team2], g_FormattedTeamNames[MatchTeam_Team1]);
    } else if (g_TeamGivenStopCommand[MatchTeam_Team1] && g_TeamGivenStopCommand[MatchTeam_Team2]) {
        RestoreLastRound();
    }

    return Plugin_Handled;
}

public Action Command_Cancelmatch(int client, int args){
    Get5_MessageToAll("The match is being cancelled because at least 1 player failed to join.");
    CreateTimer(10.0, Match_End_Cancel);
}

public Action Match_End_Cancel(Handle timer){
    for (int i = 1; i <= MaxClients; i++) {
        if (IsPlayer(i)) {
            KickClient(i, "[KIWI] The match has been cancelled because at least 1 player failed to join");
        }
    }
    ServerCommand("kiwi_endmatch");
    ServerCommand("exit");
}

public Action Command_Colortest(int client, int args){
    Get5_MessageToAll("\x01NORMAL, \x02DARK RED, \x03PINK, \x04GREEN, \x05YELLOW, \x06LIGHT GREEN, \x07LIGHT RED, \x08GRAY, \x09ORANGE, \x0BLIGHT BLUE, \x0CDARK BLUE, \x0Eand PURPLE");
    return Plugin_Handled;
}

public Action Command_Pug(int client, int args){
    char matchUrl[PLATFORM_MAX_PATH];
    g_MatchUrlFormatCvar.GetString(matchUrl, sizeof(matchUrl));
    ReplaceString(matchUrl, sizeof(matchUrl), "{MATCHID}", g_MatchID, false);
    AdvMOTD_ShowMOTDPanel(client, "PUG", matchUrl, MOTDPANEL_TYPE_URL, true, true, true, OnMOTDFailure);
    //Get5_MessageToAll("Match URL: %s", matchUrl);
    return Plugin_Handled;
}

public Action Command_Group(int client, int args){
    AdvMOTD_ShowMOTDPanel(client, "PUG", "https://kiir.us/redir.php?url=http://steamcommunity.com/groups/kiirus", MOTDPANEL_TYPE_URL, true, true, true, OnMOTDFailure);
    return Plugin_Handled;
}

public void OnMOTDFailure(int client, MOTDFailureReason reason){
    if (reason == MOTDFailure_Disabled)
    {
        PrintToChat(client, "[SM] You have HTML MOTDs disabled.");
    }
    else if (reason == MOTDFailure_Matchmaking)
    {
        PrintToChat(client, "[SM] You cannot view HTML MOTDs because you joined via Quickplay.");
    }
    else if (reason == MOTDFailure_QueryFailed)
    {
        PrintToChat(client, "[SM] Unable to verify that you can view HTML MOTDs.");
    }
    else
    {
        PrintToChat(client, "[SM] Unable to verify that you can view HTML MOTDs for an unknown reason.");
    }
}

public Action Command_Gg(int client, int args){
    if (IsPlayer(client)) {
        if(g_GameState == GameState_Live){
            if(g_AlreadySurrendered[client] == 1){
                ReplyToCommand(client, ">> You've already voted to surrender.");
            }else{
                g_AlreadySurrendered[client] = 1;
                MatchTeam team = GetClientMatchTeam(client);
                if(team == MatchTeam_Team1){
                    g_Team1SurrenderVotes++;
                    Get5_MessageToAll("{YELLOW}%N{NORMAL} voted to surrender. Progress: {GREEN}%d{NORMAL}/{GREEN}%d", client, g_Team1SurrenderVotes, g_PlayersPerTeam-1);
                }else if(team == MatchTeam_Team2){
                    g_Team2SurrenderVotes++;
                    Get5_MessageToAll("{YELLOW}%N{NORMAL} voted to surrender. Progress: {GREEN}%d{NORMAL}/{GREEN}%d", client, g_Team2SurrenderVotes, g_PlayersPerTeam-1);
                }

                if(g_Team1SurrenderVotes == g_PlayersPerTeam-1){
                    Get5_MessageToAll("{YELLOW}%s{NORMAL} voted to surrender. Match ending shortly.", g_TeamNames[MatchTeam_Team1]);
                    g_TeamSurrendered = 1;
                    CreateTimer(10.0, Match_End_Surrender);
                }else if(g_Team2SurrenderVotes == g_PlayersPerTeam-1){
                    Get5_MessageToAll("{YELLOW}%s{NORMAL} voted to surrender. Match ending shortly.", g_TeamNames[MatchTeam_Team2]);
                    g_TeamSurrendered = 2;
                    CreateTimer(10.0, Match_End_Surrender);
                }
            }
        }else{
            ReplyToCommand(client, ">> The game hasn't gone live yet");
        }
    }
}

public Action Match_End_Surrender(Handle timer){
    for (int i = 1; i <= MaxClients; i++) {
        if (IsPlayer(i)) {
            MatchTeam team = GetClientMatchTeam(i);
            if(team == MatchTeam_Team1){
                if(g_TeamSurrendered == 1){
                    KickClient(i, "[KIWI] The match has been finished because your team surrendered");
                }else{
                    KickClient(i, "[KIWI] The match has been finished because the other team surrendered");
                }
            }else if(team == MatchTeam_Team2){
                if(g_TeamSurrendered == 2){
                    KickClient(i, "[KIWI] The match has been finished because your team surrendered");
                }else{
                    KickClient(i, "[KIWI] The match has been finished because the other team surrendered");
                }
            }
        }
    }
    ServerCommand("kiwi_endmatch");
    ServerCommand("exit");
}

static bool RestoreLastRound() {
    LOOP_TEAMS(x) {
            g_TeamGivenStopCommand[x] = false;
        }

    char lastBackup[PLATFORM_MAX_PATH];
    ConVar lastBackupCvar = FindConVar("mp_backup_round_file_last");
    if (lastBackupCvar != null) {
        lastBackupCvar.GetString(lastBackup, sizeof(lastBackup));
        ServerCommand("mp_backup_restore_load_file \"%s\"", lastBackup);
        return true;
    }
    return false;
}


/***********************
 *                     *
 *       Events        *
 *                     *
 ***********************/

public Action Event_PlayerSpawn(Event event, const char[] name, bool dontBroadcast) {
    if (g_GameState != GameState_None && g_GameState < GameState_KnifeRound) {
        int client = GetClientOfUserId(event.GetInt("userid"));
        if (IsPlayer(client) && OnActiveTeam(client)) {
            SetEntProp(client, Prop_Send, "m_iAccount", GetCvarIntSafe("mp_maxmoney"));
        }
    }
}

public Action Event_MatchOver(Event event, const char[] name, bool dontBroadcast) {
    if (g_GameState == GameState_Live) {
        int t1score = CS_GetTeamScore(MatchTeamToCSTeam(MatchTeam_Team1));
        int t2score = CS_GetTeamScore(MatchTeamToCSTeam(MatchTeam_Team2));
        MatchTeam winningTeam = (t1score > t2score) ? MatchTeam_Team1 : MatchTeam_Team2;
        Stats_UpdateMapScore(winningTeam);

        AddMapScore();
        g_TeamSeriesScores[winningTeam]++;

        char mapName[PLATFORM_MAX_PATH];
        GetCleanMapName(mapName, sizeof(mapName));

        Call_StartForward(g_OnMapResult);
        Call_PushString(mapName);
        Call_PushCell(winningTeam);
        Call_PushCell(CS_GetTeamScore(MatchTeamToCSTeam(MatchTeam_Team1)));
        Call_PushCell(CS_GetTeamScore(MatchTeamToCSTeam(MatchTeam_Team2)));
        Call_PushCell(GetMapNumber() - 1);
        Call_Finish();

        float minDelay = FindConVar("tv_delay").FloatValue + MATCH_END_DELAY_AFTER_TV;
        if (g_TeamSeriesScores[MatchTeam_Team1] == g_MapsToWin) {
            SeriesWonMessage(MatchTeam_Team1);
            CreateTimer(minDelay, Timer_EndSeries);

        } else if (g_TeamSeriesScores[MatchTeam_Team2] == g_MapsToWin) {
            SeriesWonMessage(MatchTeam_Team2);
            CreateTimer(minDelay, Timer_EndSeries);

        } else if (g_BO2Match && GetMapNumber() == 2) {
            SeriesWonMessage(MatchTeam_TeamNone);
            CreateTimer(minDelay, Timer_EndSeries);

        } else {
            if (g_TeamSeriesScores[MatchTeam_Team1] > g_TeamSeriesScores[MatchTeam_Team2]) {
                Get5_MessageToAll("%s{NORMAL} is winning the series %d-%d",
                    g_FormattedTeamNames[MatchTeam_Team1],
                    g_TeamSeriesScores[MatchTeam_Team1],
                    g_TeamSeriesScores[MatchTeam_Team2]);

            } else if (g_TeamSeriesScores[MatchTeam_Team2] > g_TeamSeriesScores[MatchTeam_Team1]) {
                Get5_MessageToAll("%s {NORMAL}is winning the series %d-%d",
                    g_FormattedTeamNames[MatchTeam_Team2],
                    g_TeamSeriesScores[MatchTeam_Team2],
                    g_TeamSeriesScores[MatchTeam_Team1]);

            } else {
                Get5_MessageToAll("The series is tied at %d-%d",
                    g_TeamSeriesScores[MatchTeam_Team1],
                    g_TeamSeriesScores[MatchTeam_Team1]);
            }

            int index = g_TeamSeriesScores[MatchTeam_Team1] + g_TeamSeriesScores[MatchTeam_Team2];
            char nextMap[PLATFORM_MAX_PATH];
            g_MapsToPlay.GetString(index, nextMap, sizeof(nextMap));

            g_MapChangePending = true;
            Get5_MessageToAll("The next map in the series is {GREEN}%s", nextMap);
            ChangeState(GameState_PostGame);
            CreateTimer(minDelay, Timer_NextMatchMap);
        }
    }

    return Plugin_Continue;
}

static void SeriesWonMessage(MatchTeam team) {
    if (g_MapsToWin == 1) {
        Get5_MessageToAll("{YELLOW}%s{NORMAL} has won the match.", g_TeamNames[team]);
    } else {
        if (team == MatchTeam_TeamNone) {
            // BO2 split.
            Get5_MessageToAll("%s and %s have split the series 1-1.",
                g_FormattedTeamNames[MatchTeam_Team1],
                g_FormattedTeamNames[MatchTeam_Team2]);

        } else {
            Get5_MessageToAll("%s has won the series %d-%d.",
                g_FormattedTeamNames[team],
                g_TeamSeriesScores[team],
                g_TeamSeriesScores[OtherMatchTeam(team)]);
        }
    }
}

public Action Timer_NextMatchMap(Handle timer) {
    if (g_GameState >= GameState_Live)
        StopRecording();

    int index = GetMapNumber();
    char map[PLATFORM_MAX_PATH];
    g_MapsToPlay.GetString(index, map, sizeof(map));
    ChangeMap(map);
}

public Action Timer_EndSeries(Handle timer) {
    if (g_KickClientsWithNoMatchCvar.IntValue != 0) {
        for (int i = 1; i <= MaxClients; i++) {
            if (IsPlayer(i)) {
                KickClient(i, "[KIWI] The match has been finished");
            }
        }
    }

    StopRecording();

    MatchTeam winningTeam  = MatchTeam_Team1;
    if (g_TeamSeriesScores[MatchTeam_Team2] > g_TeamSeriesScores[MatchTeam_Team1]) {
        winningTeam = MatchTeam_Team2;
    } else if (g_TeamSeriesScores[MatchTeam_Team1] == g_TeamSeriesScores[MatchTeam_Team2]) {
        winningTeam = MatchTeam_TeamNone;
    }

    Stats_SeriesEnd(winningTeam);

    // new Handle:curl = curl_easy_init();
    // if(curl != INVALID_HANDLE)
    // {
    //     CURL_DEFAULT_OPT(curl);
    //     curl_easy_setopt_string(curl, CURLOPT_URL, "http://kiir.us:3000/api/matchover/?id=" + g_MatchID + "&winner=" + winningTeam);
    //     ExecCURL(curl,current_test);
    // } else {
    //     PrintCreatecUrlError(current_test);
    // }

    Call_StartForward(g_OnSeriesResult);
    Call_PushCell(winningTeam);
    Call_PushCell(g_TeamSeriesScores[MatchTeam_Team1]);
    Call_PushCell(g_TeamSeriesScores[MatchTeam_Team2]);
    Call_Finish();

    ChangeState(GameState_None);

    ServerCommand("kiwi_endmatch");
    ServerCommand("exit");
}

public Action Event_RoundPreStart(Event event, const char[] name, bool dontBroadcast) {
    if (g_PendingSideSwap) {
        g_PendingSideSwap = false;
        SwapSides();
    }
    Stats_ResetRoundValues();
}

public Action Event_RoundEnd(Event event, const char[] name, bool dontBroadcast) {
    if (g_GameState == GameState_KnifeRound) {
        ChangeState(GameState_WaitingForKnifeRoundDecision);
        CreateTimer(1.0, Timer_PostKnife);

        int ctAlive = CountAlivePlayersOnTeam(CS_TEAM_CT);
        int tAlive = CountAlivePlayersOnTeam(CS_TEAM_T);
        int winningCSTeam = CS_TEAM_NONE;
        if (ctAlive > tAlive) {
            winningCSTeam = CS_TEAM_CT;
        } else if (tAlive > ctAlive) {
            winningCSTeam = CS_TEAM_T;
        } else {
            int ctHealth = SumHealthOfTeam(CS_TEAM_CT);
            int tHealth = SumHealthOfTeam(CS_TEAM_T);
            if (ctHealth > tHealth) {
                winningCSTeam = CS_TEAM_CT;
            } else if (tHealth > ctHealth) {
                winningCSTeam = CS_TEAM_T;
            } else {
                if (GetRandomFloat(0.0, 1.0) < 0.5) {
                    winningCSTeam = CS_TEAM_CT;
                } else {
                    winningCSTeam = CS_TEAM_T;
                }
            }
        }

        g_KnifeWinnerTeam = CSTeamToMatchTeam(winningCSTeam);
        Get5_MessageToAll("{YELLOW}%s{NORMAL} won! 20 seconds to vote for {GREEN}!ct{NORMAL} or {GREEN}!t{NORMAL}",
            g_TeamNames[g_KnifeWinnerTeam]);
        CreateTimer(20.0, Stay_or_Swap);
    }

    if (g_GameState == GameState_Live) {
        int csTeamWinner = event.GetInt("winner");

        if(CS_GetTeamScore(MatchTeamToCSTeam(MatchTeam_Team1)) > CS_GetTeamScore(MatchTeamToCSTeam(MatchTeam_Team2))){
            Get5_MessageToAll("{YELLOW}%s{NORMAL} [{GREEN}%d{NORMAL}] - [{DARK_RED}%d{NORMAL}] {YELLOW}%s",
                g_TeamNames[MatchTeam_Team1],
                CS_GetTeamScore(MatchTeamToCSTeam(MatchTeam_Team1)),
                CS_GetTeamScore(MatchTeamToCSTeam(MatchTeam_Team2)),
                g_TeamNames[MatchTeam_Team2]);
        }else if(CS_GetTeamScore(MatchTeamToCSTeam(MatchTeam_Team1)) < CS_GetTeamScore(MatchTeamToCSTeam(MatchTeam_Team2))){
            Get5_MessageToAll("{YELLOW}%s{NORMAL} [{DARK_RED}%d{NORMAL}] - [{GREEN}%d{NORMAL}] {YELLOW}%s",
                g_TeamNames[MatchTeam_Team1],
                CS_GetTeamScore(MatchTeamToCSTeam(MatchTeam_Team1)),
                CS_GetTeamScore(MatchTeamToCSTeam(MatchTeam_Team2)),
                g_TeamNames[MatchTeam_Team2]);
        }else{
            Get5_MessageToAll("{YELLOW}%s{NORMAL} [{PINK}%d{NORMAL}] - [{PINK}%d{NORMAL}] {YELLOW}%s",
                g_TeamNames[MatchTeam_Team1],
                CS_GetTeamScore(MatchTeamToCSTeam(MatchTeam_Team1)),
                CS_GetTeamScore(MatchTeamToCSTeam(MatchTeam_Team2)),
                g_TeamNames[MatchTeam_Team2]);
        }

        Stats_UpdateTeamScores();
        Stats_UpdatePlayerRounds(csTeamWinner);
        Call_StartForward(g_OnRoundStatsUpdated);
        Call_Finish();

        int roundsPlayed = GameRules_GetProp("m_totalRoundsPlayed");
        LogDebug("m_totalRoundsPlayed = %d", roundsPlayed);

        int roundsPerHalf = GetCvarIntSafe("mp_maxrounds") / 2;
        int roundsPerOTHalf = GetCvarIntSafe("mp_overtime_maxrounds") / 2;

        // Regulation halftime. (after round 15)
        if (roundsPlayed == roundsPerHalf) {
            LogDebug("Pending regulation side swap");
            g_PendingSideSwap = true;
        }

        // Now in OT.
        if (roundsPlayed >= 2*roundsPerHalf) {
            int otround = roundsPlayed - 2*roundsPerHalf; // round 33 -> round 3, etc.
            // Do side swaps at OT halves (rounds 3, 9, ...)
            if ((otround + roundsPerOTHalf) % (2 * roundsPerOTHalf) == 0) {
                LogDebug("Pending OT side swap");
                g_PendingSideSwap = true;
            }
        }
    }
}

public void SwapSides() {
    LogDebug("SwapSides");
    int tmp = g_TeamSide[MatchTeam_Team1];
    g_TeamSide[MatchTeam_Team1] = g_TeamSide[MatchTeam_Team2];
    g_TeamSide[MatchTeam_Team2] = tmp;
}

/**
 * Silences cvar changes when executing live/knife/warmup configs, *unless* it's sv_cheats.
 */
public Action Event_CvarChanged(Event event, const char[] name, bool dontBroadcast) {
    if (g_GameState != GameState_None) {
        char cvarName[MAX_CVAR_LENGTH];
        event.GetString("cvarname", cvarName, sizeof(cvarName));
        if (!StrEqual(cvarName, "sv_cheats")) {
            event.BroadcastDisabled = true;
        }
    }

    return Plugin_Continue;
}


public void StartGame(bool knifeRound) {
    if (!IsTVEnabled()) {
        LogError("GOTV demo could not be recorded since tv_enable is not set to 1");
    } else {
        // Get the map with any workshop stuff before removed.
        // This is {MAP} in the format string.
        char mapName[PLATFORM_MAX_PATH];
        GetCleanMapName(mapName, sizeof(mapName));

        // Get the time, this is {TIME} in the format string.
        char timeFormat[64];
        g_DemoTimeFormatCvar.GetString(timeFormat, sizeof(timeFormat));
        int timeStamp = GetTime();
        char formattedTime[64];
        FormatTime(formattedTime, sizeof(formattedTime), timeFormat, timeStamp);

        // Get the player count, this is {TEAMSIZE} in the format string.
        char playerCount[MAX_INTEGER_STRING_LENGTH];
        IntToString(g_PlayersPerTeam, playerCount, sizeof(playerCount));

        // Get team names with spaces removed.
        char team1Str[MAX_CVAR_LENGTH];
        strcopy(team1Str, sizeof(team1Str), g_TeamNames[MatchTeam_Team1]);
        ReplaceString(team1Str, sizeof(team1Str), " ", "_");

        char team2Str[MAX_CVAR_LENGTH];
        strcopy(team2Str, sizeof(team2Str), g_TeamNames[MatchTeam_Team2]);
        ReplaceString(team2Str, sizeof(team2Str), " ", "_");

        // Create the actual demo name to use.
        char demoName[PLATFORM_MAX_PATH];
        g_DemoNameFormatCvar.GetString(demoName, sizeof(demoName));

        int mapNumber = g_TeamSeriesScores[MatchTeam_Team1] + g_TeamSeriesScores[MatchTeam_Team2] + 1;
        ReplaceStringWithInt(demoName, sizeof(demoName), "{MAPNUMBER}", mapNumber, false);
        ReplaceString(demoName, sizeof(demoName), "{MATCHID}", g_MatchID, false);
        ReplaceString(demoName, sizeof(demoName), "{MAPNAME}", mapName, false);
        ReplaceString(demoName, sizeof(demoName), "{TIME}", formattedTime, false);
        ReplaceString(demoName, sizeof(demoName), "{TEAM1}", team1Str, false);
        ReplaceString(demoName, sizeof(demoName), "{TEAM2}", team2Str, false);

        if (Record(demoName)) {
            Format(g_DemoFileName, sizeof(g_DemoFileName), "%s.dem", demoName);
            LogMessage("Recording to %s", g_DemoFileName);
        } else {
            Format(g_DemoFileName, sizeof(g_DemoFileName), "");
        }
    }

    Get5_MessageToAll("Created match {GREEN}->{NORMAL} {ORANGE}{{NORMAL} MatchID: {GREEN}%s{NORMAL} {ORANGE}}{NORMAL}", g_MatchID);
    Get5_MessageToAll("Starting demo capture: {GREEN}kiwi-%s.dem{NORMAL}", g_MatchID);
    Get5_MessageToAll("Get match stats and demo at: {GREEN}kiir.us/match/%s{NORMAL}", g_MatchID);

    ExecCfg(g_LiveCfgCvar);

    if (knifeRound) {
        if (g_KnifeChangedCvars != INVALID_HANDLE)
            CloseCvarStorage(g_KnifeChangedCvars);
        g_KnifeChangedCvars = ExecuteAndSaveCvars(KNIFE_CONFIG);
        CreateTimer(1.0, StartKnifeRound);
    } else {
        ChangeState(GameState_GoingLive);
        CreateTimer(3.0, StartGoingLive, _, TIMER_FLAG_NO_MAPCHANGE);
    }
}

public Action Timer_PostKnife(Handle timer) {
    if (g_KnifeChangedCvars != INVALID_HANDLE)
        RestoreCvars(g_KnifeChangedCvars, true);

    ExecCfg(g_WarmupCfgCvar);
    EnsurePausedWarmup();
}

public Action StopDemo(Handle timer) {
    StopRecording();
    return Plugin_Handled;
}

public void ChangeState(GameState state) {
    LogDebug("Change from state %d -> %d", g_GameState, state);
    Call_StartForward(g_OnGameStateChanged);
    Call_PushCell(g_GameState);
    Call_PushCell(state);
    Call_Finish();
    g_GameState = state;
}

public Action Command_Status(int client, int args) {
    if (!LibraryExists("jansson")) {
        ReplyToCommand(client, "kiwi_status requires the smjansson extension to be loaded!");
        return Plugin_Handled;
    }

    Handle json = json_object();

    set_json_string(json, "matchid", g_MatchID);
    set_json_string(json, "plugin_version", PLUGIN_VERSION);

    #if defined COMMIT_STRING
    set_json_string(json, "commit", COMMIT_STRING);
    #endif

    set_json_int(json, "gamestate", view_as<int>(g_GameState));

    char gamestate[64];
    GameStateString(g_GameState, gamestate, sizeof(gamestate));
    set_json_string(json, "gamestate_string", gamestate);

    if (g_GameState != GameState_None) {
        set_json_string(json, "loaded_config_file", g_LoadedConfigFile);
        set_json_int(json, "map_number", GetMapNumber());

        Handle team1 = json_object();
        AddTeamInfo(team1, MatchTeam_Team1);
        json_object_set(json, "team1", team1);
        CloseHandle(team1);

        Handle team2 = json_object();
        AddTeamInfo(team2, MatchTeam_Team2);
        json_object_set(json, "team2", team2);
        CloseHandle(team2);
    }

    if (g_GameState > GameState_Veto) {
        Handle maps = json_object();

        for (int i = 0; i < g_MapsToPlay.Length; i++) {
            char mapKey[64];
            Format(mapKey, sizeof(mapKey), "map%d", i);

            char mapName[PLATFORM_MAX_PATH];
            g_MapsToPlay.GetString(i, mapName, sizeof(mapName));

            set_json_string(maps, mapKey, mapName);
        }
        json_object_set(json, "maps", maps);
        CloseHandle(maps);
    }

    char buffer[4096];
    json_dump(json, buffer, sizeof(buffer));
    ReplyToCommand(client, buffer);

    CloseHandle(json);
    return Plugin_Handled;
}

static void AddTeamInfo(Handle json, MatchTeam matchTeam) {
    int team = MatchTeamToCSTeam(matchTeam);
    char side[4];
    CSTeamString(team, side, sizeof(side));
    set_json_string(json, "name", g_TeamNames[matchTeam]);
    set_json_int(json, "series_score", g_TeamSeriesScores[matchTeam]);
    set_json_int(json, "ready", g_TeamReady[matchTeam]);
    set_json_string(json, "side", side);
    set_json_int(json, "connected_clients", GetNumHumansOnTeam(team));
    set_json_int(json, "current_map_score", CS_GetTeamScore(team));
}

stock bool AllTeamsReady(bool includeSpec=true) {
    bool playersReady = g_TeamReady[MatchTeam_Team1] && g_TeamReady[MatchTeam_Team2];
    if (g_WaitForSpecReadyCvar.IntValue == 0 ||
        GetTeamAuths(MatchTeam_TeamSpec).Length == 0 ||
        !includeSpec) {
        return playersReady;
    } else {
        return playersReady && g_TeamReady[MatchTeam_TeamSpec];
    }
}
