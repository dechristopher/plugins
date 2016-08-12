CheckConFigFiles(String:WM_VERSION[])
{
	decl String:cfgFile[PLATFORM_MAX_PATH];
	decl String:dirName[PLATFORM_MAX_PATH];
	
	Format(dirName, sizeof(dirName), "cfg/sourcemod");
	if (!DirExists(dirName))
	{
		CreateDirectory(dirName, 751);
	}
	
	CreateTranslationFile();
	
	Format(cfgFile, sizeof(cfgFile), "cfg/sourcemod/plugin.warmod.cfg");
	if (!FileExists(cfgFile))
	{
		CreateAutoExecConfigFile(WM_VERSION);
	}
	
	Format(dirName, sizeof(dirName), "cfg/warmod");
	if (!DirExists(dirName))
	{
		CreateDirectory(dirName, 751);
	}
	
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/ruleset_global.cfg");
	if (!FileExists(cfgFile))
	{
		RuleSet_Global(WM_VERSION);
	}
	
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/ruleset_default.cfg");
	if (!FileExists(cfgFile))
	{
		RuleSet_Default(WM_VERSION);
	}
	
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/ruleset_overtime.cfg");
	if (!FileExists(cfgFile))
	{
		RuleSet_OverTime(WM_VERSION);
	}
	
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/ruleset_playout.cfg");
	if (!FileExists(cfgFile))
	{
		RuleSet_PlayOut(WM_VERSION);
	}
	
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/ruleset_warmup.cfg");
	if (!FileExists(cfgFile))
	{
		RuleSet_WarmUp(WM_VERSION);
	}
	
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/practice.cfg");
	if (!FileExists(cfgFile))
	{
		RuleSet_Practice(WM_VERSION);
	}
	
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/on_map_load.cfg");
	if (!FileExists(cfgFile))
	{
		RuleSet_OnMapLoad(WM_VERSION);
	}
	
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/on_match_end.cfg");
	if (!FileExists(cfgFile))
	{
		RuleSet_OnMatchEnd(WM_VERSION);
	}
	
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/veto_maps_list.txt");
	if (!FileExists(cfgFile))
	{
		CreateVetoMapListFile();
	}
}

static CreateAutoExecConfigFile(String:WM_VERSION[])
{
	decl String:cfgFile[PLATFORM_MAX_PATH];
	Format(cfgFile, sizeof(cfgFile), "cfg/sourcemod/plugin.warmod.cfg");
	
	new Handle:file = OpenFile(cfgFile, "w");
	WriteFileLine(file, "// WarMod [BFG] - Auto Executed Config File");
	WriteFileLine(file, "// Created via [BFG] WarMod v%s", WM_VERSION);
	WriteFileLine(file, "// This file will execute when warmod is loaded");
	WriteFileString(file, "exec warmod/on_map_load.cfg", false); // no newline at the end
	CloseHandle(file);
}

static RuleSet_Global(String:WM_VERSION[])
{
	decl String:cfgFile[PLATFORM_MAX_PATH];
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/ruleset_global.cfg");
	new Handle:file = OpenFile(cfgFile, "w");

	WriteFileLine(file, "// WarMod [BFG] - Global Ruleset Config");
	WriteFileLine(file, "// Created via [BFG] WarMod v%s", WM_VERSION);
	WriteFileLine(file, "// This config is executed by all other rulesets");
	WriteFileLine(file, "// It holds the majority of commands, so that each ruleset can use as a base configuration");
	WriteFileLine(file, "//Remove prac commands");
	WriteFileLine(file, "");
	WriteFileLine(file, "sv_infinite_ammo				\"0\"	//Players active weapon will never run out of ammo. If set to 2 then player has infinite total ammo but still has to reload the weapon");
	WriteFileLine(file, "sv_showimpacts				\"0\"	//Shows client (red) and server (blue) bullet impact point (1=both, 2=client-only, 3=server-only)");
	WriteFileLine(file, "sv_cheats				\"0\"	//Allow cheats on server (cheat console commands not hacks)");
	WriteFileLine(file, "");
	WriteFileLine(file, "// WarMod Multiplayer");
	WriteFileLine(file, "");
	WriteFileLine(file, "wm_active				\"1\"	//Enable or disable WarMod as active");
	WriteFileLine(file, "wm_max_players				\"10\"	//Sets the maximum players allowed on both teams combined, others will be forced to spectator (0 = unlimited)");
	WriteFileLine(file, "wm_round_money				\"1\"	//Enable or disable a client's team mates money to be displayed at the start of a round (to him only)");
	WriteFileLine(file, "wm_min_ready				\"10\"	//Sets the minimum required ready players to Live on 3");
	WriteFileLine(file, "wm_ingame_scores			\"1\"	//Enable or disable ingame scores to be showed at the end of each round");
	WriteFileLine(file, "wm_lock_teams				\"1\"	//Enable or disable locked teams when a match is running");
	WriteFileLine(file, "tv_enable					\"1\"	//GOTV enabled?");
	WriteFileLine(file, "wm_auto_record				\"1\"	//Enable or disable auto SourceTV demo record on Live on 3");
	WriteFileLine(file, "");
	WriteFileLine(file, "//WarMod Knife");
	WriteFileLine(file, "wm_auto_knife				\"0\"	//Enable or disable the knife round before going live");
	WriteFileLine(file, "wm_knife_auto_start			\"0\"	//Enable or disable after knife round to be forced lived");
	WriteFileLine(file, "wm_knife_hegrenade			\"0\"	//Enable or disable giving a player a hegrenade on Knife on 3");
	WriteFileLine(file, "wm_knife_flashbang			\"0\"	//Sets how many flashbangs to give a player on Knife on 3");
	WriteFileLine(file, "wm_knife_smokegrenade			\"0\"	//Enable or disable giving a player a smokegrenade on Knife on 3");
	WriteFileLine(file, "wm_knife_zeus				\"0\"	//Enable or disable giving a player a zeus on Knife on 3");
	WriteFileLine(file, "wm_knife_armor				\"1\"	//Enable or disable giving a player Armor on Knife on 3");
	WriteFileLine(file, "wm_knife_helmet				\"0\"	//Enable or disable giving a player a Helmet on Knife on 3 [requires armor active]");
	WriteFileLine(file, "");
	WriteFileLine(file, "//WarMod Pause");
	WriteFileLine(file, "");
	WriteFileLine(file, "sv_pausable				\"1\"	//Is the server pausable");
	WriteFileLine(file, "wm_pause_confirm			\"0\"	//Wait for other team to confirm pause: 0 = off, 1 = on");
	WriteFileLine(file, "wm_unpause_confirm			\"1\"	//Wait for other team to confirm unpause: 0 = off, 1 = on");
	WriteFileLine(file, "wm_auto_unpause				\"1\"	//Sets auto unpause: 0 = off, 1 = on");
	WriteFileLine(file, "wm_auto_unpause_delay			\"180\"	//Sets the seconds to wait before auto unpause");
	WriteFileLine(file, "wm_pause_limit				\"5\"	//Sets max pause count per team per half");
	WriteFileLine(file, "");
	WriteFileLine(file, "// WarMod Misc");
	WriteFileLine(file, "");
	WriteFileLine(file, "wm_show_info				\"1\"	//Enable or disable the display of the Ready System to players");
	WriteFileLine(file, "wm_rcon_only				\"0\"	//Enable or disable admin commands to be only executed via RCON or console");
	WriteFileLine(file, "wm_require_names			\"0\"	//Enable or disable the requirement of set team names for lo3");
	WriteFileLine(file, "wm_random_team_names			\"0\"	//Enable or disable the random set of a pro team name for the match");
	WriteFileLine(file, "wm_auto_ready				\"1\"	//Enable or disable the ready system being automatically enabled on map change");
	WriteFileLine(file, "");
	WriteFileLine(file, "// WarMod Ban");
	WriteFileLine(file, "");
	WriteFileLine(file, "wm_ban_on_disconnect		\"0\"	//Enable or disable players banned on disconnect if match is live");
	WriteFileLine(file, "");
	WriteFileLine(file, "// Warmod Veto");
	WriteFileLine(file, "");
	WriteFileLine(file, "wm_veto					\"1\"	//Veto Style: 0 = off, 1 = Bo1, 2 = Bo2, 3 = Bo3");
	WriteFileLine(file, "wm_veto_bo3				\"0\"	//Veto Style: 0 = Normal, 1 = New");
	WriteFileLine(file, "wm_veto_random				\"0\"	//After the vetoing is done, will a map be picked at random?");
	WriteFileLine(file, "wm_pugsetup_maplist_file			\"warmod/veto_maps_list.txt\"	//Veto Map List to read from. Located in cfg folder");
	WriteFileLine(file, "wm_pugsetup_randomize_maps		\"1\"	//When maps are shown in the map vote/veto, should their order be randomized?");
	WriteFileLine(file, "");
	WriteFileLine(file, "exec gamemode_competitive_server.cfg", false);// no newline at the end
	CloseHandle(file);
}

static RuleSet_Default(String:WM_VERSION[])
{
	decl String:cfgFile[PLATFORM_MAX_PATH];
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/ruleset_default.cfg");
	new Handle:file = OpenFile(cfgFile, "w");

	WriteFileLine(file, "// WarMod [BFG] - Default Ruleset Config");
	WriteFileLine(file, "// Updated via [BFG] WarMod Config Updater for Warmod v%s", WM_VERSION);
	WriteFileLine(file, "// Exec global config");
	WriteFileLine(file, "exec warmod/ruleset_global.cfg");
	WriteFileLine(file, "");
	WriteFileLine(file, "// Change Default commands");
	WriteFileLine(file, "wm_match_config		\"warmod/ruleset_default.cfg\"		//Sets the match config to load on Live on 3");
	WriteFileLine(file, "mp_maxrounds		\"30\"		//max number of rounds to play before server changes maps");
	WriteFileLine(file, "mp_match_can_clinch		\"1\"		//Can a team clinch and end the match by being so far ahead that the other team has no way to catching up?");
	WriteFileLine(file, "mp_overtime_enable		\"0\"		//If a match ends in a tie, use overtime rules to determine winner");
	WriteFileLine(file, "mp_overtime_maxrounds		\"6\"		//When overtime is enabled play additional rounds to determine winner");
	WriteFileLine(file, "mp_overtime_startmoney		\"10000\"		//Money assigned to all players at start of every overtime half");
	WriteFileLine(file, "mp_startmoney		\"800\"			//amount of money each player gets when they reset");
	WriteFileLine(file, "mp_roundtime		\"1.75\"		//How many minutes each round takes");
	WriteFileLine(file, "mp_roundtime_defuse		\"1.75\"		//How many minutes each round of Bomb Defuse takes. If 0 then use mp_roundtime instead");
	WriteFileLine(file, "wm_round_money		\"1\"		//Enable or disable a client's team mates money to be displayed at the start of a round (to him only)");
	WriteFileLine(file, "");
	WriteFileLine(file, "say WarMod [BFG] Default Match Config Loaded", false); // no newline at the end
	CloseHandle(file);
}

static RuleSet_PlayOut(String:WM_VERSION[])
{
	decl String:cfgFile[PLATFORM_MAX_PATH];
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/ruleset_playout.cfg");
	new Handle:file = OpenFile(cfgFile, "w");

	WriteFileLine(file, "// WarMod [BFG] - PlayOut Ruleset Config");
	WriteFileLine(file, "// Created via [BFG] WarMod v%s", WM_VERSION);
	WriteFileLine(file, "// Exec global config");
	WriteFileLine(file, "exec warmod/ruleset_global.cfg");
	WriteFileLine(file, "");
	WriteFileLine(file, "// Change PlayOut commands");
	WriteFileLine(file, "wm_match_config		\"warmod/ruleset_playout.cfg\"		//Sets the match config to load on Live on 3");
	WriteFileLine(file, "mp_maxrounds		\"30\"		//max number of rounds to play before server changes maps");
	WriteFileLine(file, "mp_match_can_clinch		\"0\"		//Can a team clinch and end the match by being so far ahead that the other team has no way to catching up?");
	WriteFileLine(file, "mp_overtime_enable		\"0\"		//If a match ends in a tie, use overtime rules to determine winner");
	WriteFileLine(file, "mp_overtime_maxrounds		\"6\"		//When overtime is enabled play additional rounds to determine winner");
	WriteFileLine(file, "mp_overtime_startmoney		\"10000\"		//Money assigned to all players at start of every overtime half");
	WriteFileLine(file, "mp_startmoney		\"800\"			//amount of money each player gets when they reset");
	WriteFileLine(file, "mp_roundtime		\"1.75\"		//How many minutes each round takes");
	WriteFileLine(file, "mp_roundtime_defuse		\"1.75\"		//How many minutes each round of Bomb Defuse takes. If 0 then use mp_roundtime instead");
	WriteFileLine(file, "wm_round_money		\"1\"		//Enable or disable a client's team mates money to be displayed at the start of a round (to him only)");
	WriteFileLine(file, "");
	WriteFileLine(file, "say WarMod [BFG] PlayOut Match Config Loaded", false); // no newline at the end
	CloseHandle(file);
}

static RuleSet_OverTime(String:WM_VERSION[])
{
	decl String:cfgFile[PLATFORM_MAX_PATH];
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/ruleset_overtime.cfg");
	new Handle:file = OpenFile(cfgFile, "w");

	WriteFileLine(file, "// WarMod [BFG] - OverTime Ruleset Config");
	WriteFileLine(file, "// Created via [BFG] WarMod v%s", WM_VERSION);
	WriteFileLine(file, "// Exec global config");
	WriteFileLine(file, "exec warmod/ruleset_global.cfg");
	WriteFileLine(file, "");
	WriteFileLine(file, "// Change OverTime commands");
	WriteFileLine(file, "wm_match_config		\"warmod/ruleset_overtime.cfg\"		//Sets the match config to load on Live on 3");
	WriteFileLine(file, "mp_maxrounds		\"30\"		//max number of rounds to play before server changes maps");
	WriteFileLine(file, "mp_match_can_clinch		\"1\"		//Can a team clinch and end the match by being so far ahead that the other team has no way to catching up?");
	WriteFileLine(file, "mp_overtime_enable		\"1\"		//If a match ends in a tie, use overtime rules to determine winner");
	WriteFileLine(file, "mp_overtime_maxrounds		\"6\"		//When overtime is enabled play additional rounds to determine winner");
	WriteFileLine(file, "mp_overtime_startmoney 		\"10000\"		//Money assigned to all players at start of every overtime half");
	WriteFileLine(file, "mp_startmoney		\"800\"		//amount of money each player gets when they reset");
	WriteFileLine(file, "mp_roundtime		\"1.75\"		//How many minutes each round takes");
	WriteFileLine(file, "mp_roundtime_defuse		\"1.75\"		//How many minutes each round of Bomb Defuse takes. If 0 then use mp_roundtime instead");
	WriteFileLine(file, "wm_round_money		\"1\"		//Enable or disable a client's team mates money to be displayed at the start of a round (to him only)");
	WriteFileLine(file, "");
	WriteFileLine(file, "say WarMod [BFG] OverTime Config Loaded", false);// no newline at the end
	CloseHandle(file);
}

static RuleSet_WarmUp(String:WM_VERSION[])
{
	decl String:cfgFile[PLATFORM_MAX_PATH];
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/ruleset_warmup.cfg");

	new Handle:file = OpenFile(cfgFile, "w");

	WriteFileLine(file, "// WarMod [BFG] - WarmUp Ruleset Config");
	WriteFileLine(file, "// Created via [BFG] WarMod v%s", WM_VERSION);
	WriteFileLine(file, "// Exec global config");
	WriteFileLine(file, "exec warmod/ruleset_global.cfg");
	WriteFileLine(file, "");
	WriteFileLine(file, "// Change WarmUp commands");
	WriteFileLine(file, "wm_warmup_respawn		\"1\"		//Enable or disable the respawning of players in warmup");
	WriteFileLine(file, "wm_block_warm_up_grenades		\"1\"	//Enable or disable grenade blocking in warmup");
	WriteFileLine(file, "mp_warmuptime		\"300\"		//How long the warmup period lasts. Changing this value resets warmup.");
	WriteFileLine(file, "mp_buytime		\"120\"		//How many seconds after round start players can buy items for.");
	WriteFileLine(file, "mp_freezetime		\"0\"		//How many seconds to keep players frozen when the round starts");
	WriteFileLine(file, "mp_autokick		\"0\"		//Kick idle/team-killing/team-damaging players");
	WriteFileLine(file, "mp_friendlyfire		\"0\"		//Allows team members to injure other members of their team");
	WriteFileLine(file, "mp_startmoney		\"16000\"			//amount of money each player gets when they reset");
	WriteFileLine(file, "mp_warmup_pausetimer		\"1\"		//Set to 1 to stay in warmup indefinitely. Set to 0 to resume the timer.");
	WriteFileLine(file, "wm_round_money		\"0\"		//Enable or disable a client's team mates money to be displayed at the start of a round (to him only)");
	WriteFileLine(file, "sv_infinite_ammo		\"0\"		//Player's active weapon will never run out of ammo.");
	WriteFileLine(file, "sv_showimpacts		\"0\"			//Shows client (red) and server (blue) bullet impact point");
	WriteFileLine(file, "sv_cheats			\"0\"			//Allow cheats on server");
	WriteFileLine(file, "mp_buy_anywhere		\"0\"		//When set, players can buy anywhere, not only in buyzones");
	WriteFileLine(file, "mp_roundtime_defuse		\"1.75\"		//How many minutes each round of Bomb Defuse takes. If 0 then use mp_roundtime instead");
	WriteFileLine(file, "wm_active			\"1\"		//Enable or disable WarMod as active");
	WriteFileLine(file, "");
	WriteFileLine(file, "say WarMod [BFG] WarmUp Config Loaded", false); // no newline at the end
	CloseHandle(file);
}

static RuleSet_Practice(String:WM_VERSION[])
{
	decl String:cfgFile[PLATFORM_MAX_PATH];
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/practice.cfg");

	new Handle:file = OpenFile(cfgFile, "w");

	WriteFileLine(file, "// WarMod [BFG] - Practice Config");
	WriteFileLine(file, "// Created via [BFG] WarMod v%s", WM_VERSION);
	WriteFileLine(file, "");
	WriteFileLine(file, "// Change WarmUp commands");
	WriteFileLine(file, "wm_warmup_respawn		\"0\"		//Enable or disable the respawning of players in warmup");
	WriteFileLine(file, "wm_block_warm_up_grenades		\"0\"	//Enable or disable grenade blocking in warmup");
	WriteFileLine(file, "mp_buytime		\"120\"		//How many seconds after round start players can buy items for.");
	WriteFileLine(file, "mp_freezetime		\"0\"		//How many seconds to keep players frozen when the round starts");
	WriteFileLine(file, "mp_autokick		\"0\"		//Kick idle/team-killing/team-damaging players");
	WriteFileLine(file, "mp_startmoney		\"16000\"			//amount of money each player gets when they reset");
	WriteFileLine(file, "wm_round_money		\"0\"		//Enable or disable a client's team mates money to be displayed at the start of a round (to him only)");
	WriteFileLine(file, "sv_infinite_ammo		\"2\"		//Player's active weapon will never run out of ammo.");
	WriteFileLine(file, "sv_showimpacts		\"2\"			//Shows client (red) and server (blue) bullet impact point");
	WriteFileLine(file, "sv_cheats			\"1\"			//Allow cheats on server");
	WriteFileLine(file, "mp_buy_anywhere		\"1\"		//When set, players can buy anywhere, not only in buyzones");
	WriteFileLine(file, "mp_roundtime_defuse		\"9999\"		//How many minutes each round of Bomb Defuse takes. If 0 then use mp_roundtime instead");
	WriteFileLine(file, "bot_quota			\"0\"		//Determines the total number of bots in the game.");
	WriteFileLine(file, "wm_active			\"0\"		//Enable or disable WarMod as active");
	WriteFileLine(file, "");
	WriteFileLine(file, "say WarMod [BFG] Practice Config Loaded", false); // no newline at the end
	CloseHandle(file);
}

static RuleSet_OnMapLoad(String:WM_VERSION[])
{
	decl String:cfgFile[PLATFORM_MAX_PATH];
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/on_map_load.cfg");
	new Handle:file = OpenFile(cfgFile, "w");

	WriteFileLine(file, "// WarMod [BFG] - On Map Load Config");
	WriteFileLine(file, "// Created via [BFG] WarMod v%s", WM_VERSION);
	WriteFileLine(file, "// This config file is executed on every map change, including when the server first starts");
	WriteFileLine(file, "// Note: Plugins have been loaded by now");
	WriteFileLine(file, "");
	WriteFileLine(file, "//WarMod Updater");
	WriteFileLine(file, "");
	WriteFileLine(file, "sm_updater 			\"2\"		//Determines update functionality. (1 = Notify, 2 = Download, 3 = Include source code)");
	WriteFileLine(file, "");
	WriteFileLine(file, "//WarMod Configs");
	WriteFileLine(file, "wm_warmod_safemode		\"0\"		//This disables features that usually break on a CS:GO update");
	WriteFileLine(file, "wm_match_config			\"warmod/ruleset_default.cfg\"	//Sets the match config to load on Live on 3");
	WriteFileLine(file, "wm_default_config			\"warmod/ruleset_default.cfg\"	//Sets the match config to load when the default command is called");
	WriteFileLine(file, "wm_overtime_config			\"warmod/ruleset_overtime.cfg\"	//Sets the match config to load when the overtime command is called");
	WriteFileLine(file, "wm_playout_config			\"warmod/ruleset_playout.cfg\"	//Sets the match config to load when the play out command is called");
	WriteFileLine(file, "wm_prac_config			\"warmod/practice.cfg\"	//Loads when the practice command is called");
	WriteFileLine(file, "wm_reset_config			\"warmod/on_match_end.cfg\"	//Sets the config to load at the end/reset of a match");
	WriteFileLine(file, "");
	WriteFileLine(file, "// WarMod Stats");
	WriteFileLine(file, "");
	WriteFileLine(file, "wm_save_dir				\"warmod\"	//Directory to store SourceTV demos and WarMod logs");
	WriteFileLine(file, "wm_prefix_logs			\"1\"		//Enable or disable the prefixing of \"_\" to uncompleted match SourceTV demos and WarMod logs");
	WriteFileLine(file, "wm_stats_enabled			\"1\"		//Enable or disable statistical logging");
	WriteFileLine(file, "wm_stats_method			\"2\"		//Sets the stats logging method: 0 = UDP stream/server logs, 1 = WarMod logs, 2 = both");
	WriteFileLine(file, "wm_stats_trace			\"0\"		//Enable or disable updating all player positions, every wm_stats_trace_delay seconds");
	WriteFileLine(file, "wm_stats_trace_delay		\"5\"		//The ammount of time between sending player position updates");
	WriteFileLine(file, "mp_teamname_1 			\"\"		//A non-empty string overrides the first team's name");
	WriteFileLine(file, "mp_teamname_2 			\"\"		//A non-empty string overrides the second team's name");
	WriteFileLine(file, "mp_teamlogo_1 			\"\"		//Enter a team's shorthand image name to display their logo");
	WriteFileLine(file, "mp_teamlogo_2 			\"\"		//Enter a team's shorthand image name to display their logo");
	WriteFileLine(file, "wm_competition			\"WarMod BFG\"	//Name of host for a competition. eg. ESEA, Cybergamer, CEVO, ESL");
	WriteFileLine(file, "wm_event					\"Scrim\"		//Name of event. eg. Season #, ODC #, Ladder");
	WriteFileLine(file, "wm_chat_prefix			\"WarMod BFG\"	//Change the chat prefix. Default is WarMod_BFG");
	WriteFileLine(file, "");
	WriteFileLine(file, "// Stats Site");
	WriteFileLine(file, "");
	WriteFileLine(file, "wm_site_location			\"\"		//Location of where the stats site is uploaded for download. Do not have '/' at end of string. eg. www.warmod.com");
	WriteFileLine(file, "wm_site_data			\"warmod.bitbucket.org/stats\"		//Location of where the sites images, css and js files are. Do not have '/' at end of string. eg. warmod.bitbucket.org/stats");
	WriteFileLine(file, "wm_demo_location			\"\"		//Location of where the demo is uploaded for download. eg. www.warmod.com/demos/");
	WriteFileLine(file, "wm_forums_location			\"\"		//Location of where the community forums are. eg. www.warmod.com/forums/");
	WriteFileLine(file, "");
	WriteFileLine(file, "// FTP Upload");
	WriteFileLine(file, "");
	WriteFileLine(file, "wm_autodemoupload_enable				\"1\"			//Automatically upload demos when finished recording");
	WriteFileLine(file, "wm_autodemoupload_bzip2				\"9\"			//Compression level. If set > 0 demos will be compressed before uploading (Requires bzip2 extension)");
	WriteFileLine(file, "wm_autodemoupload_delete				\"0\"			//Delete the demo (and the bz2) if upload was successful");
	WriteFileLine(file, "wm_autodemoupload_ftptargetdemo			\"demos\"		//The ftp target to use for demo uploads");
	WriteFileLine(file, "wm_autodemoupload_ftptargetlog			\"logs\"		//The ftp target to use for log uploads");
	WriteFileLine(file, "wm_autodemoupload_ftptargetstats			\"stats\"		//The ftp target to use for stats site uploads");
	WriteFileLine(file, "wm_autodemoupload_completed			\"0\"			//Only upload demos when match is completed");
	WriteFileLine(file, "");
	WriteFileLine(file, "// Voice Communications");
	WriteFileLine(file, "");
	WriteFileLine(file, "sm_deadtalk					\"0\"			//Controls how dead communicate 0 - Off, 1 - Dead players ignore teams, 2 - Dead players talk to living teammates");
	WriteFileLine(file, "");
	WriteFileLine(file, "exec warmod/ruleset_warmup.cfg", false);// no newline at the end
	CloseHandle(file);
}

static RuleSet_OnMatchEnd(String:WM_VERSION[])
{
	decl String:cfgFile[PLATFORM_MAX_PATH];
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/on_match_end.cfg");
	new Handle:file = OpenFile(cfgFile, "w");

	WriteFileLine(file, "// WarMod [BFG] - On Match End Config");
	WriteFileLine(file, "// Created via [BFG] WarMod v%s", WM_VERSION);
	WriteFileLine(file, "// This config is executed at the end or reset of a match");
	WriteFileLine(file, "mp_teamname_1 			\"\"		//A non-empty string overrides the first team's name");
	WriteFileLine(file, "mp_teamname_2 			\"\"		//A non-empty string overrides the second team's name");
	WriteFileLine(file, "mp_teamlogo_1 			\"\"		//Enter a team's shorthand image name to display their logo");
	WriteFileLine(file, "mp_teamlogo_2 			\"\"		//Enter a team's shorthand image name to display their logo", false);
	CloseHandle(file);
}

static CreateTranslationFile()
{
	decl String:cfgFile[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, cfgFile, PLATFORM_MAX_PATH, "translations/warmod.phrases.txt");
	new Handle:file = OpenFile(cfgFile, "w");
	WriteFileLine(file, "\"Phrases\"");
	WriteFileLine(file, "{");
	WriteFileLine(file, "	\"Safe Mode\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Safe Mode Enabled. Feature is disabled.\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Match Reset\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Match Reset - Game is not live!\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Half Reset\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Match Half Reset - Game is not live!\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Half Time\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Half Time! Please swap teams...\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Half Time Auto Swap\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Half Time! Swapping teams...\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Full Time\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Full Time!\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Over Time\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"#format\"		\"{1:i}\"");
	WriteFileLine(file, "		\"en\"			\"Overtime! MR{1}\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Over Time Sudden Death\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Overtime! Sudden Death\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Playing Out Notice\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"#format\"		\"{1:i}\"");
	WriteFileLine(file, "		\"en\"			\"Note: All {1} rounds must be played out!\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Ready\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"You have been marked as ready\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Not Ready\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"You have been marked as not ready\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Score Overtime\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Overtime: \"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Score Overall\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Overall: \"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Knife Round Cancelled\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Knife Round cancelled - Not Live\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Knife Round Inactive\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Knife Round is not active\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Ready System Enabled\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Ready System - Enabled\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Ready System Disabled\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Ready System - Disabled\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Set Active\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Set to Active\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Set Inactive\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Set to Inactive\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Console Ready\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Console cannot be marked as ready\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Console Not Ready\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Console cannot be marked as not ready\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Not on Team\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"You are not on a team\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Already Ready\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"You have already been marked as ready\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Already Not Ready\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"You have already been marked as not ready\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Forced Ready\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Forced all players ready\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Forced Not Ready\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Forced all players unready\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Forced Spectate\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Forced all players to spectate\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Match Not In Progress\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Match is not in progress!\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"T Winning\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"#format\"		\"{1:s}\"");
	WriteFileLine(file, "		\"en\"			\"{1} are winning\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Tied\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Scores are tied\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"CT Winning\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"#format\"		\"{1:s}\"");
	WriteFileLine(file, "		\"en\"			\"{1} are winning\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Change Teams Midgame\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Blocked - Match is in progress\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Maximum Players\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Teams have reached the maximum player limit\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Nightvision Blocked\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Night vision is disabled\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Grenades Blocked\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Grenades in warmup are disabled\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Ready System\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Ready System\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Match Begin Msg\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"#format\"		\"{1:i}\"");
	WriteFileLine(file, "		\"en\"			\"Match will begin after {1} players are ready\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"No Players Found\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"No players found\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Info Not Ready\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Unready:\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Info Exit\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Exit\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Ready System Disabled2\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"The Ready System is not enabled\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"ShowInfo Disabled\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"The Ready System display is not enabled\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Match Is Live\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"The match is live\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"WarMod Inactive\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"WarMod is not active\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Change T Name\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"#format\"		\"{1:s}\"");
	WriteFileLine(file, "		\"en\"			\"Terrorists name set to '{1}'\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Change CT Name\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"#format\"		\"{1:s}\"");
	WriteFileLine(file, "		\"en\"			\"Counter-Terrorists name set to '{1}'\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Console\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Console: \"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Available Commands\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Available client commands\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"No Permission\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"You do not have permission to use this command\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Set Minready\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"#format\"		\"{1:i}\"");
	WriteFileLine(file, "		\"en\"			\"wm_min_ready set to {1}\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Set Maxrounds\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"#format\"		\"{1:i}\"");
	WriteFileLine(file, "		\"en\"			\"wm_max_rounds set to {1}\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"WarMod Rcon Only\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Admin commands have been restricted to RCON only\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Set Password\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"#format\"		\"{1:s}\"");
	WriteFileLine(file, "		\"en\"			\"sv_password set to '{1}'\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Autokick\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"You have been automatically kicked from the server\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Names Required\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Match will not lo3 until both team names have been set\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Pause Freeze Time\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Game will pause at freeze time\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Pause Round End\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Game will pause at the end of the round\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Pause Limit\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"You have used all your pauses already\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Pause Non-player\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"You must be on T or CT to use /pause\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Pause Offer\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"have asked for a Pause. Please type /pause to pause the match\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Pause Not Enabled\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"sv_pauseable is set to 0. Pause function not enabled\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Unpause Notice\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Match is now Paused. Please type /unpause to unpause the match\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Unpause Offer\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"have asked to unpause the game. Please type /unpause to unpause the match\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Unpaused Match\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"have unpaused the match\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Unpause Non-player\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"You must be on T or CT to use /unpause\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Pause Not Confirmed\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Pause offer was not confirmed by the other team\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Unpause Timer\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"seconds until game is auto unpaused\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Unpause Auto\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Match was auto Unpaused because time limit reached\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Paused Via Rcon\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Server is not paused or was paused via rcon\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Knife Vote Team\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"are voting to stay or switch teams\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Knife Vote\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Please type /stay or /switch\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Knife Stay\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"have voted to stay\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Knife Switch\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"have voted to switch teams\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Set Name CT\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"CT's please set team name\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Set Name T\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"T's please set team name\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Set Name Both\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Teams please set team name\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Set Name CMD\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"To set team name please type /name TeamName\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Live\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"The match is now LIVE!\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Live on 3\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Live on 3\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Live on 2\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Live on 2\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Live on 1\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Live on 1\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Knife On 3\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Knife on 3\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Knife on 2\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Knife on 2\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Knife on 1\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Knife on 1\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Knife\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"KNIFE!\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Zeus\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"ZEUS!\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Good Luck\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Good Luck, Have Fun!\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Powered By\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Powered by\"");
	WriteFileLine(file, "	}	");
	WriteFileLine(file, "	\"Admin_Menu WarMod Commands\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"WarMod Commands\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Admin_Menu Enable ReadyUp\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Enable ReadyUp\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Admin_Menu Disable ReadyUp\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Disable ReadyUp\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Admin_Menu Knife\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Knife\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Admin_Menu Force Start\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Force Start\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Admin_Menu Force End\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Force End\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Admin_Menu Cancel Half\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Cancel Half\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Admin_Menu Cancel Match\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Cancel Match\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Admin_Menu Cancel Knife\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Cancel Knife\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Admin_Menu ForceAllReady\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Force All Ready\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Admin_Menu ForceAllUnready\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Force All Unready\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Admin_Menu ForceAllSpectate\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Force All Spectate\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Admin_Menu Activate WarMod\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Activate WarMod\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Admin_Menu Deactivate WarMod\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Deactivate WarMod\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Warm Up Active\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Warm Up Active\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"FTP Upload Failed\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Failed uploading demo file. Check the server log files.\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"FTP Log Upload Successful\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Log file uploaded successfully\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"FTP Demo Upload Successful\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Demo uploaded successfully\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Veto Offer Not Confirmed\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Veto offer was not confirmed by the other team\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Veto Bo3 No Maps\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"No maps in bo3 list\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Veto Bo3 Map List\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"#format\"		\"{1:s},{2:s},{3:s}\"");
	WriteFileLine(file, "		\"en\"			\"First Map = {1}, Second Map = {2}, Third Map = {3}\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Veto Bo2 No Maps\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"No maps in bo2 list\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Veto Bo2 Map List\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"#format\"		\"{1:s},{2:s}\"");
	WriteFileLine(file, "		\"en\"			\"First Map = {1}, Second Map = {2}\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Veto Disabled\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Veto system is disabled\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Veto Non-player\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"You must be on Terrorist or Counter Terrorist to use !veto\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Veto Offer\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"have asked for a veto. Please type !veto to start\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Veto Captain\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"captain will be\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Non-player\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"You must be on Terrorist or Counter Terrorist to use this command\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Default Offer\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"have asked for a default match. Please type !default to accept\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"Default Offer Not Confirmed\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Default offer was not confirmed by the other team\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"PlayOut Offer\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"have asked for a play out match. Please type !playout to accept\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"PlayOut Offer Not Confirmed\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Play Out offer was not confirmed by the other team\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"OverTime Offer\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"have asked for a over time match. Please type !overtime to accept\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "	\"OverTime Offer Not Confirmed\"");
	WriteFileLine(file, "	{");
	WriteFileLine(file, "		\"en\"			\"Over Time offer was not confirmed by the other team\"");
	WriteFileLine(file, "	}");
	WriteFileLine(file, "}", false);
	CloseHandle(file);
}

static CreateVetoMapListFile()
{
	decl String:cfgFile[PLATFORM_MAX_PATH];
	Format(cfgFile, sizeof(cfgFile), "cfg/warmod/veto_maps_list.txt");
	new Handle:file = OpenFile(cfgFile, "w");

	WriteFileLine(file, "de_dust2");
	WriteFileLine(file, "de_inferno");
	WriteFileLine(file, "de_mirage");
	WriteFileLine(file, "de_train");
	WriteFileLine(file, "de_overpass");
	WriteFileLine(file, "de_cache");
	WriteFileLine(file, "de_cbble", false); // no newline at the end
	CloseHandle(file);
}