/*
 * =============================================================================
 * MOTDgd In-Game Advertisements
 * Displays MOTDgd Related In-Game Advertisements
 *
 * Copyright (C)2013-2015 MOTDgd Ltd. All rights reserved.
 * =============================================================================
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License, version 3.0, as published by the
 * Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
 * details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program. If not, see <http://www.gnu.org/licenses/>.
*/

// ====[ INCLUDES | DEFINES ]============================================================
#pragma semicolon 1
#include <sourcemod>
#include <zephstocks>
#include <EasyHTTP>

#define DEBUG 0

#define STRING(%1) %1, sizeof(%1)

#define PLUGIN_VERSION "2.4.90"
 
// ====[ HANDLES | CVARS | VARIABLES ]===================================================
new Handle:g_motdID;
new Handle:g_OnConnect;
new Handle:g_immunity;
new Handle:g_OnOther;
new Handle:g_Review;
new Handle:g_forced;
new Handle:g_autoClose;
new Handle:g_ipOverride;

new const String:g_GamesSupported[][] = {
	"tf",
	"csgo",
	"cstrike",
	"dod",
	"nucleardawn",
	"hl2mp",
	"left4dead",
	"left4dead2",
	"nmrih",
	"fof",
	"insurgency"
};
new String:gameDir[255];
new String:g_serverIP[16];

new g_serverPort;
new g_shownTeamVGUI[MAXPLAYERS+1] = { false, ... };
new g_lastView[MAXPLAYERS+1];
new Handle:g_Whitelist = INVALID_HANDLE;

new bool:VGUICaught[MAXPLAYERS+1];
new bool:CanReview;
new bool:LateLoad;
new bool:IsKiwiAd;

new adCounter = 0;

// ====[ PLUGIN | FORWARDS ]========================================================================
public Plugin:myinfo =
{
	name = "[KIWI] Adverts",
	author = "drop",
	description = "Displays MOTDgd and KIWI In-Game Advertisements",
	version = PLUGIN_VERSION,
	url = "https://kiir.us"
}

public OnPluginStart()
{
	if(g_bL4D || g_bL4D2 || g_bND) {

	}

	// Global Server Variables //
	new bool:exists = false;
	GetGameFolderName(gameDir, sizeof(gameDir));
	for (new i = 0; i < sizeof(g_GamesSupported); i++)
	{
		if (StrEqual(g_GamesSupported[i], gameDir))
		{
			exists = true;
			break;
		}
	}
	if (!exists)
		SetFailState("The game '%s' isn't currently supported by the MOTDgd plugin!", gameDir);
	exists = false;
	
	// Plugin ConVars // 
	CreateConVar("sm_motdgd_version", PLUGIN_VERSION, "[SM] MOTDgd Plugin Version", FCVAR_NOTIFY|FCVAR_DONTRECORD);

	g_motdID = CreateConVar("sm_motdgd_userid", "6297", "MOTDgd User ID. This number can be found at: http://motdgd.com/portal/", FCVAR_NOTIFY);
	g_immunity = CreateConVar("sm_motdgd_immunity", "0", "Enable/Disable advert immunity");
	g_OnConnect = CreateConVar("sm_motdgd_onconnect", "1", "Enable/Disable advert on connect");

	if (!StrEqual(gameDir, "tf")) {
		g_autoClose = CreateConVar("sm_motdgd_auto_close", "0.0", "Set time (in seconds) to automatically close the MOTD window.", _, true, 50.0);
	}

	g_ipOverride = CreateConVar("sm_motdgd_ip", "", "Your server IP. Use this if your server IP is not identified properly automatically.");
	// Global Server Variables //
	
	if (!StrEqual(gameDir, "left4dead2") && !StrEqual(gameDir, "left4dead"))
	{
		HookEventEx("arena_win_panel", Event_End);
		HookEventEx("cs_win_panel_round", Event_End);
		HookEventEx("dod_round_win", Event_End);
		HookEventEx("player_death", Event_Death);
		HookEventEx("round_start", Event_Start);
		HookEventEx("round_win", Event_End);
		HookEventEx("teamplay_win_panel", Event_End);
		
		g_OnOther = CreateConVar("sm_motdgd_onother", "7", "Set 0 to disable, 1 to show on round end, 2 to show on player death, 4 to show on round start, 3=1+2, 5=1+4, 6=2+4, 7=1+2+4");
		g_Review = CreateConVar("sm_motdgd_review", "7.0", "Set time (in minutes) to re-display the ad. ConVar sm_motdgd_onother must be configured", _, true, 5.0);
	}

	if (!StrEqual(gameDir, "left4dead2") && !StrEqual(gameDir, "left4dead") && !StrEqual(gameDir, "csgo"))
	{
		g_forced = CreateConVar("sm_motdgd_forced_duration", "5", "Number of seconds to force an ad view for (except in CS:GO, L4D, L4D2)");
	}
	// Plugin ConVars //

	// MOTDgd MOTD Stuff //
	new UserMsg:datVGUIMenu = GetUserMessageId("VGUIMenu");
	if (datVGUIMenu == INVALID_MESSAGE_ID)
		SetFailState("The game '%s' doesn't support VGUI menus.", gameDir);
	HookUserMessage(datVGUIMenu, OnVGUIMenu, true);
	AddCommandListener(ClosedMOTD, "closed_htmlpage");
	
	HookEventEx("player_transitioned", Event_PlayerTransitioned);
	// MOTDgd MOTD Stuff //
	
	AutoExecConfig(true);

	RegConsoleCmd("sm_ad", Command_AdvertisementTest, "Displays a test advertisement to ensure the ShowMOTDScreen stock works.");

	LoadWhitelist(); 

	if(LateLoad) 
	{
		for(new i=1;i<=MaxClients;i++) 
		{
			if(IsClientInGame(i))
				g_lastView[i] = GetTime();
		}
	}

	GetIP();
}

//!ad command
public Action Command_AdvertisementTest(int client, int args) {
	g_lastView[client] = GetTime();
	CreateTimer(0.1, PreMotdTimer, GetClientUserId(client));
}

public OnConfigsExecuted() {
	GetIP();
}

public OnLibraryAdded(const String:name[]) {
	if(strcmp(name, "SteamWorks")==0) {
		GetIP();
	}
}

public SteamWorks_SteamServersConnected()
{
	GetIP();
}

public bool:IsLocal(ip)
{
	if(167772160 <= ip <= 184549375 ||
		2886729728 <= ip <= 2887778303 ||
		3232235520 <= ip <= 3232301055)	
		return true;
	return false;
}

public GetIP()
{	
	if(GetIP_Method1())
		return;

	if(GetIP_Method2())
		return;

	if(GetIP_Method3())
		return;

	if(GetIP_Method4())
		return;
}

public bool:GetIP_Method1()
{
	new String:tmp[64];
	GetConVarString(g_ipOverride, tmp, sizeof(tmp));

	new idx = StrContains(tmp, ":");
	if(idx == -1) {
		new Handle:serverPort = FindConVar("hostport");
		if (serverPort == INVALID_HANDLE)
			return false;
		g_serverPort = GetConVarInt(serverPort);
	} else {
		tmp[idx]=0;
		strcopy(g_serverIP, sizeof(g_serverIP), tmp);
		g_serverPort = StringToInt(tmp[idx+1]);
	}

	return strcmp(g_serverIP, "")!=0;
}

public bool:GetIP_Method2()
{
	new Handle:serverIP = FindConVar("hostip");
	new Handle:serverPort = FindConVar("hostport");
	if (serverIP == INVALID_HANDLE || serverPort == INVALID_HANDLE)
		return false;

	new IP = GetConVarInt(serverIP);
	g_serverPort = GetConVarInt(serverPort);

	Format(g_serverIP, sizeof(g_serverIP), "%d.%d.%d.%d", IP >>> 24 & 255, IP >>> 16 & 255, IP >>> 8 & 255, IP & 255);

	return !IsLocal(IP);
}

public bool:GetIP_Method3()
{
	if(!LibraryExists("SteamWorks"))
		return false;

	new IP = SteamWorks_GetPublicIPCell();
	Format(g_serverIP, sizeof(g_serverIP), "%d.%d.%d.%d", IP >>> 24 & 255, IP >>> 16 & 255, IP >>> 8 & 255, IP & 255);

	return IP!=0;
}

public bool:GetIP_Method4()
{
	return EasyHTTP("http://ipinfo.io/ip", GET, INVALID_HANDLE, IPReceived, _);
}

public IPReceived(any:data, const String:buffer[], bool:success)
{
	if(!success)
	{
		return;
	}

	strcopy(g_serverIP, sizeof(g_serverIP), buffer);
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	EasyHTTP_MarkNatives();
}

public bool:OnClientConnect(client, String:rejectmsg[], maxlen)
{
	// Set the expected defaults for the client
	VGUICaught[client] = false;
	g_shownTeamVGUI[client] = false;
	g_lastView[client] = 0;
	
	if (!StrEqual(gameDir, "left4dead2") && !StrEqual(gameDir, "left4dead"))
		CanReview = true;
	
	return true;
}

public OnClientPutInServer(client)
{
	// Load the advertisement via conventional means
	if (StrEqual(gameDir, "left4dead2") && GetConVarBool(g_OnConnect))
	{
		CreateTimer(0.1, PreMotdTimer, GetClientUserId(client));
	}
}

public OnMapStart() {

	LoadWhitelist();
}

// ====[ FUNCTIONS ]=====================================================================

public LoadWhitelist() {

	if(g_Whitelist != INVALID_HANDLE) {
		ClearArray(g_Whitelist);
	} else {
		g_Whitelist = CreateArray(32);
	}

	new String:Path[PLATFORM_MAX_PATH];
	BuildPath(Path_SM, STRING(Path), "configs/motdgd_whitelist.cfg");
	new Handle:hFile = OpenFile(Path, "r");
	if(!hFile) {
		return;
	}

	new String:SteamID[32];
	while(ReadFileLine(hFile, STRING(SteamID))) {

		PushArrayString(g_Whitelist, SteamID[8]);
	}

	CloseHandle(hFile);
}

public Action:Event_End(Handle:event, const String:name[], bool:dontBroadcast)
{
	//new client = GetClientOfUserId(GetEventInt(event, "userid"));

	for(new i=1;i<=MaxClients;i++) 
	{
		if(IsClientInGame(i)){
			#if DEBUG
		        //PrintToChat(client, "[debug] Checking round end ad check");
		        PrintToServer("[debug] [%i] Checking round end ad check: %i seconds since last served ad", i, (GetTime() - g_lastView[i]));
		    #endif
			
			// Re-view minutes must be 10 or higher, re-view mode (onother) for this event
			if (GetConVarFloat(g_Review) < 4.0 || (g_OnOther && GetConVarInt(g_OnOther) != 1 && GetConVarInt(g_OnOther) != 3 && GetConVarInt(g_OnOther) != 5 && GetConVarInt(g_OnOther) != 7)){
				#if DEBUG
			        //PrintToChat(client, "[debug] Checking round end ad check");
			        PrintToServer("[debug] Check round end: RETURN IMPROPER CONFIG: %i", GetConVarInt(g_OnOther));
			    #endif
				return Plugin_Continue;
			}
			
			// Only process the re-view event if the client is valid and is eligible to view another advertisement
			if (IsValidClient(i) && CanReview && GetTime() - g_lastView[i] >= GetConVarFloat(g_Review) * 60)
			{
				#if DEBUG
		        	//PrintToChat(client, "[debug] Sending round end ad");
		        	PrintToServer("[debug] [%i] Sending round end ad", i);
		    	#endif
				g_lastView[i] = GetTime();
				CreateTimer(0.1, PreMotdTimer, GetClientUserId(i));
			} else if(IsValidClient(i) && CanReview) {
				#if DEBUG
			        //PrintToChat(client, "[debug] Sending player death ad");
			        PrintToServer("[debug] [%i] Client not yet eligible: %i/600", i, (GetTime() - g_lastView[i]));
			    #endif
			} else{
				PrintToServer("%b, %b", IsValidClient(i), CanReview);
			}
		}
	}

	return Plugin_Continue;
}

public Action:Event_Death(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	if(!client)
		return Plugin_Continue;

	CreateTimer(0.5, CheckPlayerDeath, GetClientUserId(client));
	
	return Plugin_Continue;
}

public Action:Event_Start(Handle:event, const String:name[], bool:dontBroadcast)
{
	//new client = GetClientOfUserId(GetEventInt(event, "userid"));

	for(new i=1;i<=MaxClients;i++) 
	{
		if(IsClientInGame(i)){
			#if DEBUG
		        // PrintToChat(client, "[debug] Checking round start ad check");
		        PrintToServer("[debug] [%i] Checking round start ad check: %i seconds since last served ad", i, (GetTime() - g_lastView[i]));
		    #endif
			
			// Re-view minutes must be 10 or higher, re-view mode (onother) for this event
			if (GetConVarFloat(g_Review) < 4.0 || (g_OnOther && GetConVarInt(g_OnOther) != 4 && GetConVarInt(g_OnOther) != 5 && GetConVarInt(g_OnOther) != 6 && GetConVarInt(g_OnOther) != 7)){
				#if DEBUG
			        //PrintToChat(client, "[debug] Checking round end ad check");
			        PrintToServer("[debug] Check round start: RETURN IMPROPER CONFIG: %i", GetConVarInt(g_OnOther));
			    #endif
				return Plugin_Continue;
			}
			
			// Only process the re-view event if the client is valid and is eligible to view another advertisement
			if (IsValidClient(i) && CanReview && GetTime() - g_lastView[i] >= GetConVarFloat(g_Review) * 60)
			{
				#if DEBUG
			        // PrintToChat(client, "[debug] Sending round start ad");
			        PrintToServer("[debug] [%i] Sending round start ad, i");
			    #endif
				g_lastView[i] = GetTime();
				CreateTimer(0.1, PreMotdTimer, GetClientUserId(i));
			} else if(IsValidClient(i) && CanReview) {
				#if DEBUG
			        //PrintToChat(client, "[debug] Sending player death ad");
			        PrintToServer("[debug] [%i] Client not yet eligible: %i/600", i, (GetTime() - g_lastView[i]));
			    #endif
			} else{
				PrintToServer("%b, %b", IsValidClient(i), CanReview);
			}
		}
	}

	return Plugin_Continue;
}

public Action:CheckPlayerDeath(Handle:timer, any:userid)
{
	new client=GetClientOfUserId(userid);

	#if DEBUG
       	//PrintToChat(client, "[debug] Checking player death ad check");
       	PrintToServer("[debug] [%i] Checking player death ad check %i seconds since last served ad", client, (GetTime() - g_lastView[client]));
    #endif

	if(!client)
		return Plugin_Stop;

	// Check if client is valid
	if (!IsValidClient(client))
		return Plugin_Stop;
	
	// We don't want TF2's Dead Ringer triggering a false re-view event
	if (IsPlayerAlive(client))
		return Plugin_Stop;
	
	// Re-view minutes must be 10 or higher, re-view mode (onother) for this event
	if (GetConVarFloat(g_Review) < 4.0 || (g_OnOther && GetConVarInt(g_OnOther) != 2 && GetConVarInt(g_OnOther) != 3 && GetConVarInt(g_OnOther) != 6 && GetConVarInt(g_OnOther) != 7)){
		#if DEBUG
	        //PrintToChat(client, "[debug] Checking round end ad check");
	        PrintToServer("[debug] Check player death: RETURN IMPROPER CONFIG: %i", GetConVarInt(g_OnOther));
	    #endif
		return Plugin_Stop;
	}
	
	// Only process the re-view event if the client is valid and is eligible to view another advertisement
	if (IsValidClient(client) && CanReview && GetTime() - g_lastView[client] >= GetConVarFloat(g_Review) * 60)
	{
		#if DEBUG
	        //PrintToChat(client, "[debug] Sending player death ad");
	        PrintToServer("[debug] [%i] Sending player death ad", client);
	    #endif
		g_lastView[client] = GetTime();
		CreateTimer(0.1, PreMotdTimer, GetClientUserId(client));
	} else if(IsValidClient(client) && CanReview) {
		#if DEBUG
	        //PrintToChat(client, "[debug] Sending player death ad");
	        PrintToServer("[debug] [%i] Client not yet eligible: %i/600", client, (GetTime() - g_lastView[client]));
	    #endif
	}
	
	return Plugin_Stop;
}

public Action:Event_PlayerTransitioned(Handle:event, const String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid"));

	if (IsValidClient(client) && GetConVarBool(g_OnConnect))
		CreateTimer(0.1, PreMotdTimer, GetClientUserId(client));

	return Plugin_Continue;
}

public Action:OnVGUIMenu(UserMsg:msg_id, Handle:bf, const players[], playersNum, bool:reliable, bool:init)
{
	if(!(playersNum > 0))
		return Plugin_Handled;
	new client = players[0];
	
	if (playersNum > 1 || !IsValidClient(client) || VGUICaught[client] || !GetConVarBool(g_OnConnect))
		return Plugin_Continue;

	VGUICaught[client] = true;
	
	g_lastView[client] = GetTime();
	
	CreateTimer(0.1, PreMotdTimer, GetClientUserId(client));
	
	return Plugin_Handled;
}

public Action:ClosedMOTD(client, const String:command[], argc)
{
	if (!IsValidClient(client))
		return Plugin_Handled;
	
	if(g_forced != INVALID_HANDLE && GetConVarInt(g_forced) != 0 && g_lastView[client] != 0 && (g_lastView[client]+GetConVarInt(g_forced) >= GetTime()))
	{
		new timeRemaining = ( ( g_lastView[client]+GetConVarInt(g_forced) )-GetTime() ) + 1;
		
		if (timeRemaining == 1)
		{
			PrintCenterText(client, "Please wait %i second", timeRemaining);
		}
		else
		{
			PrintCenterText(client, "Please wait %i seconds", timeRemaining);
		}
		
		if (StrEqual(gameDir, "cstrike"))
			ShowMOTDScreen(client, "", false);
		else
			ShowMOTDScreen(client, "http://", false);
	}
	else
	{
        if (StrEqual(gameDir, "cstrike") || StrEqual(gameDir, "csgo") || StrEqual(gameDir, "insurgency"))
            FakeClientCommand(client, "joingame");
        else if (StrEqual(gameDir, "nucleardawn") || StrEqual(gameDir, "dod"))
            ClientCommand(client, "changeteam");
	}
	
	return Plugin_Handled;
}

public Action:PreMotdTimer(Handle:timer, any:userid)
{
	new client=GetClientOfUserId(userid);
	if(!client)
		return Plugin_Stop;

	if (!IsValidClient(client))
		return Plugin_Stop;
	
	decl String:kiwimsg[255];
	decl String:normmsg[255];
	
	decl String:url[255];
	decl String:kiwiurl[255];

	decl String:steamid[255];
	decl String:name[MAX_NAME_LENGTH];
	decl String:name_encoded[MAX_NAME_LENGTH*2];
	GetClientName(client, name, sizeof(name));
	urlencode(name, name_encoded, sizeof(name_encoded));

	Format(kiwiurl, sizeof(kiwiurl), "https://kiir.us/ad.php?id=1337");
	Format(kiwimsg, sizeof(kiwimsg), "Playing KIWI ad");
	Format(normmsg, sizeof(normmsg), "Playing normal ad");

	if (GetClientAuthId(client, AuthId_Steam2, steamid, sizeof(steamid)))
		Format(url, sizeof(url), "http://motdgd.com/motd/?user=%d&ip=%s&pt=%d&v=%s&st=%s&gm=%s&name=%s", GetConVarInt(g_motdID), g_serverIP, g_serverPort, PLUGIN_VERSION, steamid, gameDir, name_encoded);
	else
		Format(url, sizeof(url), "http://motdgd.com/motd/?user=%d&ip=%s&pt=%d&v=%s&st=NULL&gm=%s&name=%s", GetConVarInt(g_motdID), g_serverIP, g_serverPort, PLUGIN_VERSION, gameDir, name_encoded);
	
	if(FindStringInArray(g_Whitelist, steamid[8])!=-1) {
		return Plugin_Stop;
	}

	if(g_forced != INVALID_HANDLE && GetConVarInt(g_forced) != 0)
	{
		CreateTimer(0.2, RefreshMotdTimer, userid);
	}

	if(g_autoClose != INVALID_HANDLE) {
		new Float:close = GetConVarFloat(g_autoClose);
		if(close > 0) {
			CreateTimer(close, AutoCloseTimer, userid);
		}
	}

	adCounter++;

	//Toggle KIWI ad every 10 ads
	if(adCounter == 10){
		IsKiwiAd = true;
		adCounter = 0;
	}
	
	if(!IsKiwiAd){
		ShowMOTDScreen(client, url, false); // False means show, true means hide
		#if DEBUG
			PrintToChat(client, normmsg);
			PrintToServer("MOTDgd Ad: %s", url);
		#endif
	} else {
		IsKiwiAd = false;
		ShowMOTDScreen(client, kiwiurl, false); // False means show, true means hide
		#if DEBUG
			PrintToChat(client, kiwimsg);
			PrintToServer("KIWI Ad: %s", kiwiurl);
		#endif
	}
	
	return Plugin_Stop;
}

public Action:AutoCloseTimer(Handle:timer, any:userid)
{
	new client=GetClientOfUserId(userid);
	
	if(!client)
		return Plugin_Stop;

	ShowMOTDScreen(client, "http://", true);
	ClosedMOTD(client, "", 0);

	return Plugin_Stop;
}

public Action:RefreshMotdTimer(Handle:timer, any:userid)
{
	new client=GetClientOfUserId(userid);
	
	if(!client)
		return Plugin_Stop;

	if (!IsValidClient(client))
		return Plugin_Stop;

	if(g_forced != INVALID_HANDLE && GetConVarInt(g_forced) != 0 && g_lastView[client] != 0 && (g_lastView[client]+GetConVarInt(g_forced)) >= GetTime())
	{
		CreateTimer(0.3, RefreshMotdTimer, userid);
	}

	ShowMOTDScreen(client, "http://", false);

	return Plugin_Stop;
}

stock ShowMOTDScreen(client, String:url[], bool:hidden)
{
	if (!IsValidClient(client))
		return;
	
	new Handle:kv = CreateKeyValues("data");

	if (StrEqual(gameDir, "left4dead") || StrEqual(gameDir, "left4dead2"))
		KvSetString(kv, "cmd", "closed_htmlpage");
	else
		KvSetNum(kv, "cmd", 5);

	KvSetString(kv, "msg", url);
	KvSetString(kv, "title", "MOTDgd AD");
	KvSetNum(kv, "type", MOTDPANEL_TYPE_URL);
	ShowVGUIPanel(client, "info", kv, !hidden);
	CloseHandle(kv);
}

stock GetRealPlayerCount()
{
	new players;
	for (new i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && !IsFakeClient(i))
			players++;
	}
	return players;
}

stock bool:IsValidClient(i){
	if (i == 0){
		#if DEBUG
	        //PrintToServer("[debug] IVC: i=0");
	    #endif
		return false;
	}
	if(!IsClientInGame(i)){
		#if DEBUG
	        //PrintToServer("[debug] IVC: !IsClientInGame(i)");
	    #endif
		return false;
	}
	if(IsClientSourceTV(i)){
		#if DEBUG
	        //PrintToServer("[debug] IVC: IsClientSourceTV(i)");
	    #endif
		return false;
	}
	if(IsClientReplay(i)){
		#if DEBUG
	        //PrintToServer("[debug] IVC: IsClientReplay(i)");
	    #endif
		return false;
	}
	if(IsFakeClient(i)){
		#if DEBUG
	        //PrintToServer("[debug] IVC: IsFakeClient(i)");
	    #endif
		return false;
	}
	if(!IsClientConnected(i)){
		#if DEBUG
	        //PrintToServer("[debug] IVC: !IsClientConnected(i)");
	    #endif
		return false;
	}
	if (!GetConVarBool(g_immunity)){
		#if DEBUG
	        //PrintToServer("[debug] IVC: true - immunity off");
	    #endif
		return true;
	}
	//if (CheckCommandAccess(i, "MOTDGD_Immunity", ADMFLAG_RESERVATION)){
		//return false;
	//}
	#if DEBUG
        //PrintToServer("[debug] IVC: true");
    #endif
	return true;
}

stock urlencode(const String:sString[], String:sResult[], len)
{
	new String:sHexTable[] = "0123456789abcdef";
	new from, c;
	new to;

	while(from < len)
	{
		c = sString[from++];
		if(c == 0)
		{
			sResult[to++] = c;
			break;
		}
		else if(c == ' ')
		{
			sResult[to++] = '+';
		}
		else if((c < '0' && c != '-' && c != '.') ||
				(c < 'A' && c > '9') ||
				(c > 'Z' && c < 'a' && c != '_') ||
				(c > 'z'))
		{
			if((to + 3) > len)
			{
				sResult[to] = 0;
				break;
			}
			sResult[to++] = '%';
			sResult[to++] = sHexTable[c >> 4];
			sResult[to++] = sHexTable[c & 15];
		}
		else
		{
			sResult[to++] = c;
		}
	}
}  