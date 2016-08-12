#include <cstrike>
#include <sourcemod>

#include "include/common.inc"
#include "include/csgo_common.inc"

#pragma semicolon 1
#pragma newdecls required

ConVar g_Enabled;

public Plugin myinfo = {
    name = "[KIWI] Radio command blocker",
    author = "dorp",
    description = "Blocks radio commands from players",
    version = VERSION,
    url = "https://kiir.us"
};

public void OnPluginStart() {
    g_Enabled = CreateConVar("sm_blockradio_enabled", "1", "Whether radio commands are blocked");
    AutoExecConfig();

    char radioCommands[][] = {
        "go", "cheer", "fallback", "sticktog", "holdpos", "followme",
        "roger", "negative", "cheer", "compliment", "thanks",
        "enemyspot", "needbackup", "takepoint", "sectorclear", "inposition",
        "takingfire", "reportingin", "getout", "enemydown", "coverme", "regroup",
    };

    for (int i = 0; i < sizeof(radioCommands); i++) {
        AddCommandListener(BlockedCommand, radioCommands[i]);
    }
}

public Action BlockedCommand(int client, const char[] command, int argc) {
    if (g_Enabled.IntValue == 0) {
        return Plugin_Continue;
    } else {
        return Plugin_Handled;
    }
}
