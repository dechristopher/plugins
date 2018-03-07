#include <sourcemod>
#include <sdktools>
#include <cstrike>
#include <retakes>

#pragma newdecls required
#pragma semicolon 1

Bombsite g_iBombsite;

bool g_bBombDeleted;

ConVar g_cEnabled;
ConVar g_cFreezeTime;

float g_fBombPosition[3];

Handle g_hBombTimer;

int m_bBombTicking;

public Plugin myinfo =
{
    name = "[KIWI] Bomb Autoplant",
    author = "drop",
    description = "Autoplant the bomb on round start.",
    version = "1.5.0",
    url = "https://git.tetra.vodka/kiwi/plugin-autoplant"
};

public void OnPluginStart()
{
    g_cEnabled = CreateConVar("sm_autoplant_enabled", "1", "Whether or not the autoplanter is enabled/disabled", _, true, 0.0, true, 1.0);
    g_cFreezeTime = FindConVar("mp_freezetime");
    m_bBombTicking = FindSendPropInfo("CPlantedC4", "m_bBombTicking");
    HookEvent("round_start", OnRoundStart, EventHookMode_PostNoCopy);
    HookEvent("round_end", OnRoundEnd, EventHookMode_PostNoCopy);
}

public Action OnRoundStart(Event eEvent, const char[] sName, bool bDontBroadcast)
{
    g_bBombDeleted = false;

    if (!g_cEnabled.BoolValue)
    {
        return Plugin_Continue;
    }

    for (int i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && IsPlayerAlive(i) && GetPlayerWeaponSlot(i, 4) > 0)
        {
            int iBomb = GetPlayerWeaponSlot(i, 4);

            g_bBombDeleted = SafeRemoveWeapon(i, iBomb);

            GetClientAbsOrigin(i, g_fBombPosition);

            delete g_hBombTimer;

            g_hBombTimer = CreateTimer(g_cFreezeTime.FloatValue, PlantBomb, i);
        }
    }

    return Plugin_Continue;
}

public void OnRoundEnd(Event eEvent, const char[] sName, bool bDontBroadcast)
{
    delete g_hBombTimer;
    GameRules_SetProp("m_bBombPlanted", 0);
}

public Action PlantBomb(Handle hTimer, int iClient)
{
    g_hBombTimer = INVALID_HANDLE;

    if (IsClientInGame(iClient) || !g_bBombDeleted)
    {
        if (g_bBombDeleted)
        {
            int iBombEntity = CreateEntityByName("planted_c4");

            GameRules_SetProp("m_bBombPlanted", 1);

            SetEntData(iBombEntity, m_bBombTicking, 1, 1, true);

            SendBombPlanted(iClient);

            if (DispatchSpawn(iBombEntity))
            {
                ActivateEntity(iBombEntity);
                TeleportEntity(iBombEntity, g_fBombPosition, NULL_VECTOR, NULL_VECTOR);

                if (!(GetEntityFlags(iBombEntity) & FL_ONGROUND))
                {
                    float fDirection[3];
                    float fFloor[3];

                    Handle hTrace;

                    fDirection[0] = 89.0;

                    TR_TraceRay(g_fBombPosition, fDirection, MASK_PLAYERSOLID_BRUSHONLY, RayType_Infinite);

                    if (TR_DidHit(hTrace))
                    {
                        TR_GetEndPosition(fFloor, hTrace);

                        TeleportEntity(iBombEntity, fFloor, NULL_VECTOR, NULL_VECTOR);
                    }
                }
            }
        }
    }
    else
    {
        CS_TerminateRound(1.0, CSRoundEnd_Draw);
    }
}

public void SendBombPlanted(int iClient)
{
    Event eEvent = CreateEvent("bomb_planted");

    if (eEvent == null)
    {
        return;
    }

    eEvent.SetInt("userid", GetClientUserId(iClient));
    eEvent.SetInt("site", view_as<int>(g_iBombsite));
    eEvent.Fire();
}

public void Retakes_OnSitePicked(Bombsite& bSite)
{
    g_iBombsite = bSite;
}

stock bool SafeRemoveWeapon(int iClient, int iWeapon)
{
    if (!IsValidEntity(iWeapon) || !IsValidEdict(iWeapon))
    {
        return false;
    }

    if (!HasEntProp(iWeapon, Prop_Send, "m_hOwnerEntity"))
    {
        return false;
    }

    int iOwnerEntity = GetEntPropEnt(iWeapon, Prop_Send, "m_hOwnerEntity");

    if (iOwnerEntity != iClient)
    {
        SetEntPropEnt(iWeapon, Prop_Send, "m_hOwnerEntity", iClient);
    }

    CS_DropWeapon(iClient, iWeapon, false);

    if (HasEntProp(iWeapon, Prop_Send, "m_hWeaponWorldModel"))
    {
        int iWorldModel = GetEntPropEnt(iWeapon, Prop_Send, "m_hWeaponWorldModel");

        if (IsValidEdict(iWorldModel) && IsValidEntity(iWorldModel))
        {
            if (!AcceptEntityInput(iWorldModel, "Kill"))
            {
                return false;
            }
        }
    }

    if (!AcceptEntityInput(iWeapon, "Kill"))
    {
        return false;
    }

    return true;
}