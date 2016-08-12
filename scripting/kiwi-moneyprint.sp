//PrintToChatAll("\x01\x0B\x01 1,\x02 2,\x03 3,\x04 4,\x05 5,\x06 6,\x07 7");  
//https://forums.alliedmods.net/showpost.php?p=1910049&postcount=8

#pragma semicolon 1

#include <sourcemod>
#include <sdktools>
#include <cstrike>

// Offsets
new g_iAccount = -1;

ConVar g_hEnabled;

public Plugin:myinfo = {
    name = "[KIWI] Round Money",
    author = "drop",
    description = "Displays the team's money on round start.",
    version = "1.0.0",
    url = "https://kiir.us"
};

public OnPluginStart()
{
    g_hEnabled = CreateConVar("sm_moneyprint_enabled", "1", "Whether or not team money is printed at the start of a round.");
    AutoExecConfig();

    HookEvent("round_start", Event_Round_Start);
    g_iAccount = FindSendPropOffs("CCSPlayer", "m_iAccount");
}

public Event_Round_Start(Handle:event, const String:name[], bool:dontBroadcast)
{
    if (g_hEnabled.IntValue == 0)
        return;

    new the_money[MAXPLAYERS + 1];
    new num_players;
    
    // sort by money
    for (new i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) > 1)
        {
            the_money[num_players] = i;
            num_players++;
        }
    }
    
    SortCustom1D(the_money, num_players, SortMoney);
    
    new String:player_name[64];
    new String:player_money[10];
    //new String:has_weapon[3];
    new String:money_color[1];
    new pri_weapon;
    
    // display team players money
    for (new i = 1; i <= MaxClients; i++)
    {
        if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) > 1)
        {
            //PrintToChat(i, "\x01[\x05KIWI\x01] Team Money");
        }
        for (new x = 0; x < num_players; x++)
        {
            GetClientName(the_money[x], player_name, sizeof(player_name));
            if (IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == GetClientTeam(the_money[x]))
            {
                //Paint money WHITE if NOT GREAT eco ( x < $6000 )
                if(GetEntData(the_money[x], g_iAccount) < 6000)
                {
                    money_color = "\x01";
                }
                //Paint money ORANGE if GOOD eco ( $6000 <= x < 10000 )
                //else if(GetEntData(the_money[x], g_iAccount) >= 6000 && GetEntData(the_money[x], g_iAccount) < 10000)
                //{
                    //money_color = "\x09";
                //}
                //Paint the money GREEN if GREAT eco ( x >= 10000 )
                else
                {
                    money_color = "\x04";
                }

                //Check if user has a primary and print output depending on if they do or not
                pri_weapon = GetPlayerWeaponSlot(the_money[x], 0);
                if (pri_weapon == -1)
                {
                    //No primary
                    //has_weapon = "\x06";
                    IntToMoney(GetEntData(the_money[x], g_iAccount), player_money, sizeof(player_money));
                    PrintToChat(i, "\x01[\x09KIWI\x01] \x01(%s$%s\x01) --\x06> \x03%s", money_color, player_money, player_name);
                }
                else
                {
                    //Has primary
                    //has_weapon = "\x06";
                    IntToMoney(GetEntData(the_money[x], g_iAccount), player_money, sizeof(player_money));
                    PrintToChat(i, "\x01[\x09KIWI\x01] \x01(%s$%s\x01) \x06> \x03%s", money_color, player_money, player_name);
                }
            }
        }
    }
}

/**
 *  get the comma'd string version of an integer
 * 
 * @param  OldMoney            the integer to convert
 * @param  String:NewMoney     the buffer to save the string in
 * @param  size                the size of the buffer
 * @noreturn
 */

stock IntToMoney(OldMoney, String:NewMoney[], size)
{
    new String:Temp[32];
    new String:OldMoneyStr[32];
    new tempChar;
    new RealLen = 0;

    IntToString(OldMoney, OldMoneyStr, sizeof(OldMoneyStr));

    for (new i = strlen(OldMoneyStr) - 1; i >= 0; i--)
    {
        if (RealLen % 3 == 0 && RealLen != strlen(OldMoneyStr) && i != strlen(OldMoneyStr)-1)
        {
            tempChar = OldMoneyStr[i];
            Format(Temp, sizeof(Temp), "%s,%s", tempChar, Temp);
        }
        else
        {
            tempChar = OldMoneyStr[i];
            Format(Temp, sizeof(Temp), "%s%s", tempChar, Temp);
        }
        RealLen++;
    }
    Format(NewMoney, size, "%s", Temp);
}

public SortMoney(elem1, elem2, const array[], Handle:hndl)
{
    new money1 = GetEntData(elem1, g_iAccount);
    new money2 = GetEntData(elem2, g_iAccount);
    
    if (money1 > money2)
    {
        return -1;
    }
    else if (money1 == money2)
    {
        return 0;
    }
    else
    {
        return 1;
    }
}  