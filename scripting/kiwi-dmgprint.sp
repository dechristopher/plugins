#include <cstrike>
#include <sourcemod>

#include "include/common.inc"
#include "include/csgo_common.inc"

#pragma semicolon 1
#pragma newdecls required

ConVar g_hEnabled;
ConVar g_hAllowDmgCommand; 
ConVar g_hTitleFormat;
ConVar g_hMessageFormat;

int g_DamageDone[MAXPLAYERS+1][MAXPLAYERS+1];
int g_DamageDoneHits[MAXPLAYERS+1][MAXPLAYERS+1];

public Plugin myinfo = {
    name = "[KIWI] Damage Printer",
    author = "drop",
    description = "Writes out player damage on round end or when .dmg is used",
    version = "1.0.0",
    url = "https://kiir.us"
};

public void OnPluginStart() {
    g_hEnabled = CreateConVar("sm_damageprint_enabled", "1", "Whether the plugin is enabled");
    g_hAllowDmgCommand = CreateConVar("sm_damageprint_allow_dmg_command", "0", "Whether players can type .dmg to see damage done");
    g_hTitleFormat = CreateConVar("sm_damageprint_title_format", "[{ORANGE}KIWI{NORMAL}] Damage Outline", "Format of the title above the damage output.");
    g_hMessageFormat = CreateConVar("sm_damageprint_format", "--> ({GREEN}{DMG_TO}{NORMAL} dmg / {HITS_TO} hits) to {NAME} ({RED}{HEALTH}{NORMAL} HP)", "Format of the damage output string. Avaliable tags are in the default, color tags such as {LIGHT_RED} and {GREEN} also work.");

    AutoExecConfig();
    RegConsoleCmd("sm_dmg", Command_Damage, "Displays damage done");

    HookEvent("round_start", Event_RoundStart);
    HookEvent("player_hurt", Event_DamageDealt, EventHookMode_Pre);
    HookEvent("round_end", Event_RoundEnd, EventHookMode_Post);
}

static void PrintDamageInfo(int client) {
    if (!IsValidClient(client))
        return;

    int team = GetClientTeam(client);
    if (team != CS_TEAM_T && team != CS_TEAM_CT)
        return;

    char message[256];

    char title[256];
    g_hTitleFormat.GetString(title, sizeof(title));
    Colorize(title, sizeof(title));
    PrintToChat(client, title);

    int otherTeam = (team == CS_TEAM_T) ? CS_TEAM_CT : CS_TEAM_T;
    for (int i = 1; i <= MaxClients; i++) {
        if (IsValidClient(i) && GetClientTeam(i) == otherTeam) {
            int health = IsPlayerAlive(i) ? GetClientHealth(i) : 0;
            char name[64];
            GetClientName(i, name, sizeof(name));

            g_hMessageFormat.GetString(message, sizeof(message));
            ReplaceStringWithInt(message, sizeof(message), "{DMG_TO}", g_DamageDone[client][i], false);
            ReplaceStringWithInt(message, sizeof(message), "{HITS_TO}", g_DamageDoneHits[client][i], false);
            ReplaceStringWithInt(message, sizeof(message), "{DMG_FROM}", g_DamageDone[i][client], false);
            ReplaceStringWithInt(message, sizeof(message), "{HITS_FROM}", g_DamageDoneHits[i][client], false);
            ReplaceString(message, sizeof(message), "{NAME}", name, false);
            ReplaceStringWithInt(message, sizeof(message), "{HEALTH}", health, false);

            Colorize(message, sizeof(message));
            PrintToChat(client, message);
        }
    }
}

public Action Command_Damage(int client, int args) {
    if (g_hEnabled.IntValue == 0 || g_hAllowDmgCommand.IntValue == 0)
        return;

    if (IsPlayerAlive(client)) {
        ReplyToCommand(client, "[KIWI] You cannot use that command when alive.");
        return;
    }

    PrintDamageInfo(client);
}

public Action Event_RoundEnd(Event event, const char[] name, bool dontBroadcast) {
    if (g_hEnabled.IntValue == 0)
        return;

    for (int i = 1; i <= MaxClients; i++) {
        if (IsValidClient(i)) {
            PrintDamageInfo(i);
        }
    }
}

public Action Event_RoundStart(Event event, const char[] name, bool dontBroadcast) {
    for (int i = 1; i <= MaxClients; i++) {
        for (int j = 1; j <= MaxClients; j++) {
            g_DamageDone[i][j] = 0;
            g_DamageDoneHits[i][j] = 0;
        }
    }
}

public Action Event_DamageDealt(Event event, const char[] name, bool dontBroadcast) {
    int attacker = GetClientOfUserId(event.GetInt("attacker"));
    int victim = GetClientOfUserId(event.GetInt("userid"));
    bool validAttacker = IsValidClient(attacker);
    bool validVictim = IsValidClient(victim);

    if (validAttacker && validVictim) {
        int preDamageHealth = GetClientHealth(victim);
        int damage = event.GetInt("dmg_health");
        int postDamageHealth = event.GetInt("health");

        // this maxes the damage variables at 100,
        // so doing 50 damage when the player had 2 health
        // only counts as 2 damage.
        if (postDamageHealth == 0) {
            damage += preDamageHealth;
        }

        g_DamageDone[attacker][victim] += damage;
        g_DamageDoneHits[attacker][victim]++;
    }
}