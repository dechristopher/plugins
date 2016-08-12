//#pragma newdecls required
#pragma semicolon 1

#define DEBUG 0

#define PLUGIN_AUTHOR "drop"
#define PLUGIN_VERSION "0.01"

#include <sourcemod>
#include <sdktools>

#include "include/common.inc"
#include "include/csgo_common.inc"

bool g_Mute = true;

public Plugin myinfo = 
{
    name = "[KIWI] Death Mute",
    author = PLUGIN_AUTHOR, 
    description = "Mutes players shortly after death.",
    version = PLUGIN_VERSION, 
    url = "https://forums.alliedmods.net/showthread.php?t=265713"
};

Handle g_hCvarCalloutDuration;
ConVar g_hEnabled;
ConVar g_hMessageFormat;
ConVar g_hMutedMessageFormat;

public void OnPluginStart()
{
    g_hCvarCalloutDuration = CreateConVar("sm_deadmute_duration", "10.0", "Duration of the callout period.", FCVAR_PLUGIN | FCVAR_NOTIFY);
    g_hEnabled = CreateConVar("sm_deadmute_enabled", "1", "Whether the plugin is enabled.");
    g_hMessageFormat = CreateConVar("sm_deadmute_message_format", "[{ORANGE}KIWI{NORMAL}] You have {YELLOW}10 seconds{NORMAL} to make your final callout!", "Format of the callout warning.");
    g_hMutedMessageFormat = CreateConVar("sm_deadmute_muted_message_format", "[{ORANGE}KIWI{NORMAL}] Living players can no longer hear you.", "Format of the muted message.");

    AutoExecConfig();

    HookEvent("player_death", Event_PlayerDeath, EventHookMode_Post);
    HookEvent("round_end", Event_RoundEnd);
    HookEvent("round_start", Event_RoundStart);
}

public Action Event_PlayerDeath(Handle event, const char[] name, bool dontBroadcast)
{
    if(g_hEnabled.IntValue == 0)
        return;

    int client = GetClientOfUserId(GetEventInt(event, "userid"));
    CreateTimer(GetConVarFloat(g_hCvarCalloutDuration), Timer_Callout, client);

    char message[256];

    g_hMessageFormat.GetString(message, sizeof(message));
    Colorize(message, sizeof(message));
    PrintToChat(client, message);

}

public Action Event_RoundStart(Handle event, const char[] name, bool dontBroadcast)
{
    if(g_hEnabled.IntValue == 0)
        return;

    CreateTimer(10.0, Timer_EnableMuting);

    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i))
        {
            #if DEBUG
                PrintToChat(i, "[debug] You have been unmuted.");
            #endif

            SetClientListeningFlags(i, VOICE_NORMAL);
        }
    }
}  

public Action Event_RoundEnd(Handle event, const char[] name, bool dontBroadcast)
{
    if(g_hEnabled.IntValue == 0)
        return;

    g_Mute = false;

    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i))
        {
            #if DEBUG
                PrintToChat(i, "[debug] You have been unmuted.");
            #endif

            CreateTimer(12.0, Timer_Unmute, i);
            CreateTimer(11.0, Timer_Unmute, i);
            CreateTimer(GetConVarFloat(g_hCvarCalloutDuration), Timer_Unmute, i);
            CreateTimer(9.0, Timer_Unmute, i);
            CreateTimer(8.0, Timer_Unmute, i);
            CreateTimer(7.0, Timer_Unmute, i);
            CreateTimer(6.0, Timer_Unmute, i);
            CreateTimer(5.0, Timer_Unmute, i);
            CreateTimer(4.0, Timer_Unmute, i);
            CreateTimer(3.0, Timer_Unmute, i);
            CreateTimer(2.0, Timer_Unmute, i);
            CreateTimer(1.0, Timer_Unmute, i);

            SetClientListeningFlags(i, VOICE_NORMAL);
        }
    }
}  

public Action Timer_Callout(Handle timer, any client)
{
    if(g_Mute) {
        #if DEBUG
            PrintToChat(client, "[debug] You have been muted.");
        #endif

        char message[256];

        g_hMutedMessageFormat.GetString(message, sizeof(message));
        Colorize(message, sizeof(message));
        PrintToChat(client, message);

        SetClientListeningFlags(client, VOICE_MUTED + VOICE_LISTENTEAM);
    } else {
        #if DEBUG
            PrintToChat(client, "[debug] Mute sent but not needed.");
        #endif
    }
    
}

public Action Timer_Unmute(Handle timer, any client)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i))
        {
            #if DEBUG
                PrintToChat(i, "[debug] You have been unmuted.");
            #endif
        }
    }

    SetClientListeningFlags(client, VOICE_NORMAL);
}

public Action Timer_EnableMuting(Handle timer)
{
    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i))
        {
            #if DEBUG
            PrintToChat(i, "[debug] Muting is now enabled.");
            #endif
        }
    }

    g_Mute = true;
}