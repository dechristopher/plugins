#pragma semicolon 1
#define PLUGIN_VERSION "1.00"
#include <sourcemod>

public Plugin:myinfo = {
	name = "[KIWI] Suicide Block",
	author = "drop",
	description = "Add Cheat Flag to Kill.",
	version = PLUGIN_VERSION,
	url = "https://kiir.us"
};

public OnPluginStart()
{
	SetCommandFlags("kill", GetCommandFlags("kill")|FCVAR_CHEAT);
}

public OnPluginEnd()
{
	SetCommandFlags("kill", GetCommandFlags("kill") & ~(FCVAR_CHEAT));
}
//Just copy and paste this code into sourcemods compiler on their website.
//This will give you the .smx file to put into the plugins folder.