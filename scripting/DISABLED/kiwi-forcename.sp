#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <basecomm>

#define PLUGIN_VERSION "1.0.0"

#define MODE_COMMAND 0
#define MODE_WITH 1
#define MODE_WITHOUT 2
#define MODE_ALL 3

new bool:g_bIgnoreChange[MAXPLAYERS + 1];
new bool:g_bHideChange[MAXPLAYERS + 1];
new bool:g_nameChangeSet[MAXPLAYERS +1];
new String:g_sName[MAXPLAYERS + 1][32];

new Handle:g_hEnabled = INVALID_HANDLE;
new Handle:g_hHideAll = INVALID_HANDLE;
new Handle:g_hRevertAll = INVALID_HANDLE;
new Handle:g_hHideGagged = INVALID_HANDLE;
new Handle:g_hRevertGagged = INVALID_HANDLE;
new Handle:g_hHideFlag = INVALID_HANDLE;

new bool:g_bLateLoad, bool:g_bEnabled, bool:g_bHideAll, bool:g_bRevertAll, bool:g_bHideGagged, bool:g_bRevertGagged;
new g_iFlag, UserMsg:g_umSayText2;
new String:g_sPrefixChat[32];

public Plugin:myinfo =
{
    name = "[KIWI] Name Forcer",
    author = "drop",
    description = "Forces player names to their KIWI account username.",
    version = PLUGIN_VERSION,
    url = "https://kiir.us"
};

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	g_bLateLoad = late;
	return APLRes_Success;
}

public OnPluginStart()
{	
	LoadTranslations("common.phrases");
	LoadTranslations("sm_hidename.phrases");

	CreateConVar("sm_hidename_version", PLUGIN_VERSION, "Hide Name Version", FCVAR_PLUGIN|FCVAR_SPONLY|FCVAR_REPLICATED|FCVAR_NOTIFY|FCVAR_DONTRECORD);
	g_hEnabled = CreateConVar("sm_hidename_enabled", "1", "Enables/disables all features of the plugin.", FCVAR_NONE, true, 0.0, true, 1.0);
	HookConVarChange(g_hEnabled, OnSettingsChange);
	g_hHideAll = CreateConVar("sm_hidename_hide_all", "1", "If enabled, players will have their name changes hidden from chat, regardless of other settings provided by this plugin. (0 = Disabled, 1 = Enabled)", FCVAR_NONE, true, 0.0, true, 1.0);
	HookConVarChange(g_hHideAll, OnSettingsChange);
	g_hRevertAll = CreateConVar("sm_hidename_revert_all", "1", "If enabled, players will be unable to change their name while in the server, regardless of other settings provided by this plugin. (0 = Disabled, 1 = Enabled)", FCVAR_NONE, true, 0.0, true, 1.0);
	HookConVarChange(g_hHideAll, OnSettingsChange);
	
	g_hHideGagged = CreateConVar("sm_hidename_hide_gagged", "1", "If enabled, players that are currently gagged will have their name changes hidden from chat. (0 = Disabled, 1 = Enabled)", FCVAR_NONE, true, 0.0, true, 1.0);
	HookConVarChange(g_hHideGagged, OnSettingsChange);
	g_hRevertGagged = CreateConVar("sm_hidename_revert_gagged", "1", "If enabled, players that are currently gagged will be unable to change their name while in the server. (0 = Disabled, 1 = Enabled)", FCVAR_NONE, true, 0.0, true, 1.0);
	HookConVarChange(g_hRevertGagged, OnSettingsChange);
	g_hHideFlag = CreateConVar("sm_hidename_hide_flag", "z", "Players that possess this flag, or the \"hide_name_changes\" override, will have their name changes hidden from chat. (\"\" = Disabled)", FCVAR_NONE);
	HookConVarChange(g_hHideFlag, OnSettingsChange);
	AutoExecConfig(true, "plugin.kiwi-forcename");

	HookEvent("player_changename", Event_OnNameChange);
	RegAdminCmd("sm_hidename", Command_Hide, ADMFLAG_KICK);

	g_umSayText2 = GetUserMessageId("SayText2");
	HookUserMessage(g_umSayText2, UserMessageHook, true);

	Void_SetDefaults();
}

public OnConfigsExecuted()
{
	if(g_bEnabled)
	{
		Format(g_sPrefixChat, sizeof(g_sPrefixChat), "%T", "Prefix_Chat", LANG_SERVER);

		if(g_bLateLoad)
		{
			for(new i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i))
				{
					if(CheckCommandAccess(i, "hide_name_changes", ADMFLAG_ROOT))
						g_bHideChange[i] = true;
					else
					{
						new _iBits = GetUserFlagBits(i);
						if(_iBits && _iBits & g_iFlag)
							g_bHideChange[i] = true;
					}

					GetClientName(i, g_sName[i], sizeof(g_sName[]));
				}
			}
			
			g_bLateLoad = false;
		}
	}
}

public OnClientPostAdminCheck(client)
{
	if(IsFakeClient(client)) return;

	if(client && g_bEnabled)
	{
		g_bHideChange[client] = true;
	}

	//SET NAME FROM FILE
    char buffer[PLATFORM_MAX_PATH];
    BuildPath(Path_SM, buffer, sizeof(buffer), "data/kiwi-names.txt");

    if(!FileExists(buffer)) return;


    KeyValues kv = new KeyValues("data");
    if(kv.ImportFromFile(buffer))
    {
        if(GetClientAuthId(client, AuthId_Engine, buffer, sizeof(buffer), true) && kv.JumpToKey(buffer, false))
        {
            kv.GetString("name", buffer, sizeof(buffer), NULL_STRING);

            if(!StrEqual(buffer, NULL_STRING, false))
            {
                SetClientName(client, buffer);
                PrintToServer("[KIWI] Changing to: %s", buffer);
                PrintToServer("[KIWI] Force changed name.");
            }
        }
    }
    delete kv;

    g_nameChangeSet[client] = true;
}

public OnClientConnected(client)
{
	if(client && g_bEnabled)
	{
		GetClientName(client, g_sName[client], sizeof(g_sName[]));
	}
}

public OnClientDisconnect(client)
{
	if(client && g_bEnabled)
	{
		g_bHideChange[client] = false;
		g_bIgnoreChange[client] = false;
		g_nameChangeSet[client] = false;
	}
}

public Action:Event_OnNameChange(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	if(g_bEnabled)
	{
		if(client <= 0 || !IsClientInGame(client))
			return Plugin_Continue;

		if(g_bRevertAll)
			return Plugin_Continue;
		else if(g_bRevertGagged && BaseComm_IsClientGagged(client))
		{
			if(g_bHideGagged)
				return Plugin_Handled;
			else
				return Plugin_Continue;
		}

		GetEventString(event, "newname", g_sName[client], 32);
	}

	if(IsClientInGame(client) && g_nameChangeSet[client] == true)
	{
	    if(IsFakeClient(client)) return Plugin_Handled;

	    char buffer[PLATFORM_MAX_PATH];
	    BuildPath(Path_SM, buffer, sizeof(buffer), "data/kiwi-names.txt");

	    if(!FileExists(buffer)) return Plugin_Handled;


	    KeyValues kv = new KeyValues("data");
	    if(kv.ImportFromFile(buffer))
	    {
	        if(GetClientAuthId(client, AuthId_Engine, buffer, sizeof(buffer), true) && kv.JumpToKey(buffer, false))
	        {
	            kv.GetString("name", buffer, sizeof(buffer), NULL_STRING);

	            if(!StrEqual(buffer, NULL_STRING, false))
	            {
	                SetClientName(client, buffer);
	                PrintToServer("[KIWI] Changing to: %s", buffer);
	                PrintToServer("[KIWI] Force changed name.");
	            }
	        }
	    }
	    delete kv;
	}

    return Plugin_Handled;

	//return Plugin_Continue;
}

public Action:Command_Hide(client, args)
{
	if(g_bEnabled)
	{
		if(args < 2)
		{
			ReplyToCommand(client, "%s%t", g_sPrefixChat, "Phrase_Missing_Parameters");
			return Plugin_Handled;
		}

		new _iTargets[64], bool:_bTemp;
		decl String:_sTargets[64], String:_sBuffer[64], String:_sState[4];
		GetCmdArg(1, _sTargets, sizeof(_sTargets));
		GetCmdArg(2, _sState, sizeof(_sState));
		new bool:_bStatus = StringToInt(_sState) ? true : false;

		new _iTemp = ProcessTargetString(_sTargets, client, _iTargets, sizeof(_iTargets), 0, _sBuffer, sizeof(_sBuffer), _bTemp);
		for (new i = 0; i < _iTemp; i++)
		{
			if(IsClientInGame(_iTargets[i]))
			{
				if(!CanUserTarget(client, _iTargets[i]))
					ReplyToCommand(client, "%s%t", g_sPrefixChat, "Phrase_Target_Immunity");
				else
				{
					if(_bStatus)
					{
						if(g_bHideChange[_iTargets[i]])
							ReplyToCommand(client, "%s%t", g_sPrefixChat, "Phrase_Changes_Already_Hidden", _iTargets[i]);
						else
						{
							g_bHideChange[_iTargets[i]] = _bStatus;
							ShowActivity2(client, g_sPrefixChat, "%t", "Phrase_Changes_Now_Hidden", _iTargets[i]);
						}
					}
					else
					{
						if(!g_bHideChange[_iTargets[i]])
							ReplyToCommand(client, "%s%t", g_sPrefixChat, "Phrase_Changes_Already_Visible", _iTargets[i]);
						else
						{
							g_bHideChange[_iTargets[i]] = _bStatus;
							ShowActivity2(client, g_sPrefixChat, "%t", "Phrase_Changes_Now_Visible", _iTargets[i]);
						}
					}
				}
			}
		}
	}

	return Plugin_Handled;
}

public Action:UserMessageHook(UserMsg:msg_hd, Handle:pb, const players[], playersNum, bool:reliable, bool:init)
{
	if(g_bEnabled)
	{
		new bool:_bHideRevert = false;
		decl String:_sMessage[96];
		PbReadString(pb, "params", _sMessage, sizeof(_sMessage), 0);
		PbReadString(pb, "params", _sMessage, sizeof(_sMessage), 0);

		if(StrContains(_sMessage, "Name_Change") != -1)
		{
			PbReadString(pb, "params", _sMessage, sizeof(_sMessage), 0);
	
			for(new i = 1; i <= MaxClients; i++)
			{
				if(IsClientInGame(i) && StrEqual(_sMessage, g_sName[i]))
				{
					new bool:_bActiveGag = BaseComm_IsClientGagged(i);
					if(g_bIgnoreChange[i])
					{
						_bHideRevert = true;
						g_bIgnoreChange[i] = false;
					}
					else if((g_bRevertAll || g_bRevertGagged && _bActiveGag))
					{
						_bHideRevert = true;
						CreateTimer(0.1, Timer_Revert, i, TIMER_FLAG_NO_MAPCHANGE);
					}

					if(g_bHideAll || g_bHideGagged && _bActiveGag || g_bHideChange[i] || _bHideRevert)
						return Plugin_Handled;

					return Plugin_Continue;
				}
			}
		}
	}

	return Plugin_Continue;
}

public Action:Timer_Revert(Handle:timer, any:client)
{
	g_bIgnoreChange[client] = true;

	SetClientInfo(client, "name", g_sName[client]);
	SetEntPropString(client, Prop_Data, "m_szNetname", g_sName[client]);
}

Void_SetDefaults()
{
	g_bEnabled = GetConVarInt(g_hEnabled) ? true : false;
	g_bHideAll = GetConVarInt(g_hHideAll) ? true : false;
	g_bRevertAll = GetConVarInt(g_hRevertAll) ? true : false;
	g_bHideGagged = GetConVarInt(g_hHideGagged) ? true : false;
	g_bRevertGagged = GetConVarInt(g_hRevertGagged) ? true : false;
	
	decl String:_sBuffer[32];
	GetConVarString(g_hHideFlag, _sBuffer, sizeof(_sBuffer));
	g_iFlag = ReadFlagString(_sBuffer);
}

public OnSettingsChange(Handle:cvar, const String:oldvalue[], const String:newvalue[])
{
	if(cvar == g_hEnabled)
		g_bEnabled = StringToInt(newvalue) ? true : false;
	else if(cvar == g_hHideAll)
		g_bHideAll = StringToInt(newvalue) ? true : false;
	else if(cvar == g_hRevertAll)
		g_bRevertAll = StringToInt(newvalue) ? true : false;
	else if(cvar == g_hHideFlag)
		g_iFlag = ReadFlagString(newvalue);
	else if(cvar == g_hHideGagged)
		g_bHideGagged = StringToInt(newvalue) ? true : false;
	else if(cvar == g_hRevertGagged)
		g_bRevertGagged = StringToInt(newvalue) ? true : false;
}