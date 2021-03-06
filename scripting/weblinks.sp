#include <sourcemod>
#include <steamworks>

#pragma semicolon 1
#pragma newdecls required

#define URLPath "https://redirect.hexa-core.eu"

#include "weblinks/globals.sp"
#include "weblinks/client.sp"
#include "weblinks/misc.sp"
#include "weblinks/steamworks.sp"

public Plugin myinfo =
{
  name = PLUGIN_NAME,
  version = PLUGIN_VERSION,
  author = PLUGIN_AUTHOR,
  description = "WebLinks is a Web Shortcuts replacement",
  url = PLUGIN_URL
};
public void OnPluginStart()
{
  arList_WebLinks = new ArrayList(64);
  arList_Param = new ArrayList(64);
  arList_Address = new ArrayList(512);
}
public void OnMapStart()
{
  AddServerToTracker();
  LoadWebLinks();
}
public Action OnClientSayCommand(int client, const char[] command, const char[] sArgs)
{
  if(IsValidClient(client))
  {
    if(StrEqual(command, "say") || StrEqual(command, "say_team"))
    {
      if(StrEqual(sArgs, "motd"))
      {
        return Plugin_Handled;
      }
      int iWebLinks = arList_WebLinks.FindString(sArgs);
      if(iWebLinks != -1)
      {
        char sz_Param[64];
        char sz_Address[512];
        arList_Param.GetString(iWebLinks, sz_Param, sizeof(sz_Param));
        arList_Address.GetString(iWebLinks, sz_Address, sizeof(sz_Address));
        WebLinks_Initialize(client, sz_Param, sz_Address, sizeof(sz_Address));
        return Plugin_Handled;
      }
    }
  }
  return Plugin_Continue;
}
