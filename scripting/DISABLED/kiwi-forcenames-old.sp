#include <sdktools>

public Plugin:myinfo =
{
    name = "[KIWI] Name Forcer",
    author = "drop",
    description = "Forces player names to their KIWI account username.",
    version = SOURCEMOD_VERSION,
    url = "https://kiir.us"
};

public OnPluginStart()
{
    HookEvent("player_changename", Event_OnNameChange);
}

public void OnClientPostAdminCheck(client)
{
    if(IsFakeClient(client)) return;

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
}

/*public void OnClientSettingsChanged(client)
{
    if(IsFakeClient(client)) return;

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
}*/

public Action:Event_OnNameChange(Handle:event, const String:name[], bool:dontBroadcast)
{
    new client = GetClientOfUserId(GetEventInt(event, "userid"));

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

    return Plugin_Handled;
}
