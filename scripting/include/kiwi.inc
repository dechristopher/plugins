#if defined _kiwi_included_
  #endinput
#endif
#define _kiwi_included_

#define AUTH_LENGTH 64

enum GameState {
    GameState_None,                          // no setup has taken place
    GameState_PreVeto,                       // warmup, waiting for the veto
    GameState_Veto,                          // warmup, doing the veto
    GameState_Warmup,                        // setup done, waiting for players to ready up
    GameState_KnifeRound,                    // in the knife round
    GameState_WaitingForKnifeRoundDecision,  // waiting for a .stay/.swap command after the knife round
    GameState_GoingLive,                     // in the lo3 process
    GameState_Live,                          // the match is live
    GameState_PostGame,                      // postgame screen + waiting for GOTV to finish broadcast
};

enum MatchTeam {
    MatchTeam_Team1,
    MatchTeam_Team2,
    MatchTeam_TeamSpec,
    MatchTeam_TeamNone,
    MatchTeam_Count,
};

enum MatchSideType {
    MatchSideType_Standard,     // Team that doesn't pick map gets side choice, leftovers go to knife rounds
    MatchSideType_AlwaysKnife,  // All maps use a knife round to pick sides
    MatchSideType_NeverKnife,   // Team 1 always starts CT
};

enum SideChoice {
    SideChoice_Team1CT,     // Team 1 will start on CT
    SideChoice_Team1T,      // Team 2 will start on T
    SideChoice_KnifeRound,  // There will be a knife round to choose sides
};

// Called when a series is first setup.
forward void Get5_OnSeriesInit();

// Called each time in a match when a map is going live.
// The mapNumber parameter starts at 0.
forward void Get5_OnGoingLive(int mapNumber);

// Called whenever the gamestate phase is changed.
forward void Get5_OnGameStateChanged(GameState oldState, GameState newState);

// Called when the stats for the last round have been updated.
forward void Get5_OnRoundStatsUpdated();

// Called at the end of a map in a series.
forward void Get5_OnMapResult(const char[] map, MatchTeam mapWinner,
    int team1Score, int team2Score, int mapNumber);

// Called at the end of a full match.
// Note: both Get5_OnMapResult and Get5_OnSeriesResult are called
// on the last map of a series.
forward void Get5_OnSeriesResult(MatchTeam seriesWinner,
    int team1MapScore, int team2MapScore);

// Called when a match config fails to load.
forward void Get5_OnLoadMatchConfigFailed(const char[] reason);

// Called when a team vetoes a map.
forward void Get5_OnMapVetoed(MatchTeam team, const char[] map);

// Called when a team selects a map.
// The team parameter will be MatchTeam_TeamNone if the map was
// selected as the last remaining map and not by one of the teams
// specifically.
forward void Get5_OnMapPicked(MatchTeam team, const char[] map);

// Called when a demo finishes recording.
forward void Get5_OnDemoFinished(const char[] filename);

// Returns the current pug gamestate.
native GameState Get5_GetGameState();

// Prints a plugin-formatted message to a client.
native void Get5_Message(int client, const char[] format, any:...);

// Prints a plugin-formatted message to all clients.
native void Get5_MessageToAll(const char[] format, any:...);

// Loads a match config (keyvalues or JSON) from a local file.
// Returns true if the config was successfully loaded.
native bool Get5_LoadMatchConfig(const char[] filename);

// Loads a match config by downloading a remote config via a HTTP GET request.
// If using the SteamWorks extension, request parameters should be left out of the url
// and put into the optional ArrayLists parameters.
native bool Get5_LoadMatchConfigFromURL(const char[] url, bool preferSystem2=true,
    ArrayList paramNames=null, ArrayList paramValues=null);

// Adds a player to a match team.
// Returns if they were successfully added.
native bool Get5_AddPlayerToTeam(const char[] steamId, MatchTeam team);

// Removes a player from all match teams.
// Returns if they were successfully removed (false if not round).
native bool Get5_RemovePlayerFromTeam(const char[] steamId);

// Returns the current match team a auth is mapped to.
native MatchTeam Get5_GetPlayerTeam(const char[] steamId);

// Translates a CS team (CS_TEAM_T, etc.) to a Match team.
native MatchTeam Get5_CSTeamToMatchTeam(int csTeam);

// Translate da MatchTeam to a CS team.
native int Get5_MatchTeamToCSTeam(MatchTeam team);

// Gets the scores for a match team.
native void Get5_GetTeamScores(MatchTeam team, int& seriesScore, int& currentMapScore);

// Gets the current matchid.
native void Get5_GetMatchID(char[] id, int length);

// Sets the current matchid.
native void Get5_SetMatchID(const char[] id);

// Copies the current series stats into the passed KeyValues structure.
// Below are the keys used for stats in the kv copied.
// The caller is responsible for creating and deleting a KeyValues
// object if using this method.
native bool Get5_GetMatchStats(KeyValues kv);

// Increases an (integer-typed) player statistic in the plugin's stats keyvalue structure.
native int Get5_IncreasePlayerStat(int client, const char[] statName, int amount=1);

// Series stats (root section)
#define STAT_SERIESWINNER "winner"
#define STAT_SERIESTYPE "series_type"
#define STAT_SERIES_TEAM1NAME "team1_name"
#define STAT_SERIES_TEAM2NAME "team2_name"

// Map stats (under "map0", "map1", etc.)
#define STAT_MAPNAME "mapname"
#define STAT_MAPWINNER "winner"
#define STAT_DEMOFILENAME "demo_filename"

// Team stats (under map section, then "team1" or "team2")
#define STAT_TEAMSCORE "score"

// Player stats (under map section, then team section, then player's steam64)
#define STAT_NAME "name"
#define STAT_KILLS "kills"
#define STAT_DEATHS "deaths"
#define STAT_ASSISTS "assists"
#define STAT_FLASHBANG_ASSISTS "flashbang_assists"
#define STAT_TEAMKILLS "teamkills"
#define STAT_SUICIDES "suicides"
#define STAT_DAMAGE "damage"
#define STAT_HEADSHOT_KILLS "headshot_kills"
#define STAT_ROUNDSPLAYED "roundsplayed"
#define STAT_BOMBDEFUSES "bomb_defuses"
#define STAT_BOMBPLANTS "bomb_plants"
#define STAT_1K "1kill_rounds"
#define STAT_2K "2kill_rounds"
#define STAT_3K "3kill_rounds"
#define STAT_4K "4kill_rounds"
#define STAT_5K "5kill_rounds"
#define STAT_V1 "v1"
#define STAT_V2 "v2"
#define STAT_V3 "v3"
#define STAT_V4 "v4"
#define STAT_V5 "v5"

public SharedPlugin __pl_kiwi = {
    name = "kiwi",
    file = "kiwi.smx",
#if defined REQUIRE_PLUGIN
    required = 1,
#else
    required = 0,
#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_kiwi_SetNTVOptional() {
    MarkNativeAsOptional("Get5_GetGameState");
    MarkNativeAsOptional("Get5_Message");
    MarkNativeAsOptional("Get5_MessageToAll");
    MarkNativeAsOptional("Get5_LoadMatchConfig");
    MarkNativeAsOptional("Get5_LoadMatchConfigFromURL");
    MarkNativeAsOptional("Get5_AddPlayerToTeam");
    MarkNativeAsOptional("Get5_RemovePlayerFromTeam");
    MarkNativeAsOptional("Get5_GetPlayerTeam");
    MarkNativeAsOptional("Get5_CSTeamToMatchTeam");
    MarkNativeAsOptional("Get5_MatchTeamToCSTeam");
    MarkNativeAsOptional("Get5_GetTeamScores");
    MarkNativeAsOptional("Get5_GetMatchID");
    MarkNativeAsOptional("Get5_SetMatchID");
    MarkNativeAsOptional("Get5_IncreasePlayerStat");
    MarkNativeAsOptional("Get5_GetMatchStats");
}
#endif