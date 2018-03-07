public PlVers:__version =
{
	version = 5,
	filevers = "1.7.2",
	date = "08/02/2016",
	time = "13:00:49"
};
new Float:NULL_VECTOR[3];
new String:NULL_STRING[4];
public Extension:__ext_core =
{
	name = "Core",
	file = "core",
	autoload = 0,
	required = 0,
};
new MaxClients;
public Extension:__ext_regex =
{
	name = "Regex Extension",
	file = "regex.ext",
	autoload = 1,
	required = 1,
};
public Extension:__ext_sdktools =
{
	name = "SDKTools",
	file = "sdktools.ext",
	autoload = 1,
	required = 1,
};
new g_eCvars[128][132];
new g_iCvars;
new String:g_szModelExts[7][16] =
{
	".phy",
	".sw.vtx",
	".dx80.vtx",
	".dx90.vtx",
	".vtx",
	".xbox.vtx",
	".vvd"
};
new String:g_szMaterialKeys[3][64] =
{
	"$baseTexture",
	"$bumpmap",
	"$lightwarptexture"
};
new Handle:g_hCachedFiles;
new Handle:g_hCachedNums;
new Handle:g_hCustomFiles;
new bool:g_bCSGO;
new bool:g_bCSS;
new bool:g_bDOD;
new bool:g_bGames;
new bool:g_bL4D;
new bool:g_bTF;
new Handle:g_hNormalTrie;
new Handle:g_hRGBTrie;
new bool:g_bL4D2;
new bool:g_bND;
public Extension:__ext_curl =
{
	name = "curl",
	file = "curl.ext",
	autoload = 1,
	required = 0,
};
public Extension:__ext_smsock =
{
	name = "Socket",
	file = "socket.ext",
	autoload = 1,
	required = 0,
};
public Extension:__ext_SteamTools =
{
	name = "SteamTools",
	file = "steamtools.ext",
	autoload = 1,
	required = 0,
};
public Extension:__ext_SteamWorks =
{
	name = "SteamWorks",
	file = "SteamWorks.ext",
	autoload = 1,
	required = 0,
};
new bool:g_bExtensions;
new bool:g_bCURL;
new bool:g_bSteamTools;
new bool:g_bSockets;
new bool:g_bSteamWorks;
new String:g_szInterfaceIP[16];
new Handle:g_motdID;
new Handle:g_OnConnect;
new Handle:g_immunity;
new Handle:g_OnOther;
new Handle:g_Review;
new Handle:g_forced;
new Handle:g_autoClose;
new Handle:g_ipOverride;
new String:g_GamesSupported[11][0];
new String:gameDir[256];
new String:g_serverIP[16];
new g_serverPort;
new g_shownTeamVGUI[66];
new g_lastView[66];
new Handle:g_Whitelist;
new bool:VGUICaught[66];
new bool:CanReview;
new bool:LateLoad;
public Plugin:myinfo =
{
	name = "MOTDgd Adverts",
	description = "Displays MOTDgd In-Game Advertisements",
	author = "Blackglade and Ixel",
	version = "2.4.87",
	url = "http://motdgd.com"
};
public __ext_core_SetNTVOptional()
{
	MarkNativeAsOptional("GetFeatureStatus");
	MarkNativeAsOptional("RequireFeature");
	MarkNativeAsOptional("AddCommandListener");
	MarkNativeAsOptional("RemoveCommandListener");
	MarkNativeAsOptional("BfWriteBool");
	MarkNativeAsOptional("BfWriteByte");
	MarkNativeAsOptional("BfWriteChar");
	MarkNativeAsOptional("BfWriteShort");
	MarkNativeAsOptional("BfWriteWord");
	MarkNativeAsOptional("BfWriteNum");
	MarkNativeAsOptional("BfWriteFloat");
	MarkNativeAsOptional("BfWriteString");
	MarkNativeAsOptional("BfWriteEntity");
	MarkNativeAsOptional("BfWriteAngle");
	MarkNativeAsOptional("BfWriteCoord");
	MarkNativeAsOptional("BfWriteVecCoord");
	MarkNativeAsOptional("BfWriteVecNormal");
	MarkNativeAsOptional("BfWriteAngles");
	MarkNativeAsOptional("BfReadBool");
	MarkNativeAsOptional("BfReadByte");
	MarkNativeAsOptional("BfReadChar");
	MarkNativeAsOptional("BfReadShort");
	MarkNativeAsOptional("BfReadWord");
	MarkNativeAsOptional("BfReadNum");
	MarkNativeAsOptional("BfReadFloat");
	MarkNativeAsOptional("BfReadString");
	MarkNativeAsOptional("BfReadEntity");
	MarkNativeAsOptional("BfReadAngle");
	MarkNativeAsOptional("BfReadCoord");
	MarkNativeAsOptional("BfReadVecCoord");
	MarkNativeAsOptional("BfReadVecNormal");
	MarkNativeAsOptional("BfReadAngles");
	MarkNativeAsOptional("BfGetNumBytesLeft");
	MarkNativeAsOptional("BfWrite.WriteBool");
	MarkNativeAsOptional("BfWrite.WriteByte");
	MarkNativeAsOptional("BfWrite.WriteChar");
	MarkNativeAsOptional("BfWrite.WriteShort");
	MarkNativeAsOptional("BfWrite.WriteWord");
	MarkNativeAsOptional("BfWrite.WriteNum");
	MarkNativeAsOptional("BfWrite.WriteFloat");
	MarkNativeAsOptional("BfWrite.WriteString");
	MarkNativeAsOptional("BfWrite.WriteEntity");
	MarkNativeAsOptional("BfWrite.WriteAngle");
	MarkNativeAsOptional("BfWrite.WriteCoord");
	MarkNativeAsOptional("BfWrite.WriteVecCoord");
	MarkNativeAsOptional("BfWrite.WriteVecNormal");
	MarkNativeAsOptional("BfWrite.WriteAngles");
	MarkNativeAsOptional("BfRead.ReadBool");
	MarkNativeAsOptional("BfRead.ReadByte");
	MarkNativeAsOptional("BfRead.ReadChar");
	MarkNativeAsOptional("BfRead.ReadShort");
	MarkNativeAsOptional("BfRead.ReadWord");
	MarkNativeAsOptional("BfRead.ReadNum");
	MarkNativeAsOptional("BfRead.ReadFloat");
	MarkNativeAsOptional("BfRead.ReadString");
	MarkNativeAsOptional("BfRead.ReadEntity");
	MarkNativeAsOptional("BfRead.ReadAngle");
	MarkNativeAsOptional("BfRead.ReadCoord");
	MarkNativeAsOptional("BfRead.ReadVecCoord");
	MarkNativeAsOptional("BfRead.ReadVecNormal");
	MarkNativeAsOptional("BfRead.ReadAngles");
	MarkNativeAsOptional("BfRead.GetNumBytesLeft");
	MarkNativeAsOptional("PbReadInt");
	MarkNativeAsOptional("PbReadFloat");
	MarkNativeAsOptional("PbReadBool");
	MarkNativeAsOptional("PbReadString");
	MarkNativeAsOptional("PbReadColor");
	MarkNativeAsOptional("PbReadAngle");
	MarkNativeAsOptional("PbReadVector");
	MarkNativeAsOptional("PbReadVector2D");
	MarkNativeAsOptional("PbGetRepeatedFieldCount");
	MarkNativeAsOptional("PbSetInt");
	MarkNativeAsOptional("PbSetFloat");
	MarkNativeAsOptional("PbSetBool");
	MarkNativeAsOptional("PbSetString");
	MarkNativeAsOptional("PbSetColor");
	MarkNativeAsOptional("PbSetAngle");
	MarkNativeAsOptional("PbSetVector");
	MarkNativeAsOptional("PbSetVector2D");
	MarkNativeAsOptional("PbAddInt");
	MarkNativeAsOptional("PbAddFloat");
	MarkNativeAsOptional("PbAddBool");
	MarkNativeAsOptional("PbAddString");
	MarkNativeAsOptional("PbAddColor");
	MarkNativeAsOptional("PbAddAngle");
	MarkNativeAsOptional("PbAddVector");
	MarkNativeAsOptional("PbAddVector2D");
	MarkNativeAsOptional("PbRemoveRepeatedFieldValue");
	MarkNativeAsOptional("PbReadMessage");
	MarkNativeAsOptional("PbReadRepeatedMessage");
	MarkNativeAsOptional("PbAddMessage");
	MarkNativeAsOptional("Protobuf.ReadInt");
	MarkNativeAsOptional("Protobuf.ReadFloat");
	MarkNativeAsOptional("Protobuf.ReadBool");
	MarkNativeAsOptional("Protobuf.ReadString");
	MarkNativeAsOptional("Protobuf.ReadColor");
	MarkNativeAsOptional("Protobuf.ReadAngle");
	MarkNativeAsOptional("Protobuf.ReadVector");
	MarkNativeAsOptional("Protobuf.ReadVector2D");
	MarkNativeAsOptional("Protobuf.GetRepeatedFieldCount");
	MarkNativeAsOptional("Protobuf.SetInt");
	MarkNativeAsOptional("Protobuf.SetFloat");
	MarkNativeAsOptional("Protobuf.SetBool");
	MarkNativeAsOptional("Protobuf.SetString");
	MarkNativeAsOptional("Protobuf.SetColor");
	MarkNativeAsOptional("Protobuf.SetAngle");
	MarkNativeAsOptional("Protobuf.SetVector");
	MarkNativeAsOptional("Protobuf.SetVector2D");
	MarkNativeAsOptional("Protobuf.AddInt");
	MarkNativeAsOptional("Protobuf.AddFloat");
	MarkNativeAsOptional("Protobuf.AddBool");
	MarkNativeAsOptional("Protobuf.AddString");
	MarkNativeAsOptional("Protobuf.AddColor");
	MarkNativeAsOptional("Protobuf.AddAngle");
	MarkNativeAsOptional("Protobuf.AddVector");
	MarkNativeAsOptional("Protobuf.AddVector2D");
	MarkNativeAsOptional("Protobuf.RemoveRepeatedFieldValue");
	MarkNativeAsOptional("Protobuf.ReadMessage");
	MarkNativeAsOptional("Protobuf.ReadRepeatedMessage");
	MarkNativeAsOptional("Protobuf.AddMessage");
	VerifyCoreVersion();
	return 0;
}

Float:operator*(Float:,_:)(Float:oper1, oper2)
{
	return oper1 * float(oper2);
}

bool:operator>(Float:,_:)(Float:oper1, oper2)
{
	return oper1 > float(oper2);
}

bool:operator>=(_:,Float:)(oper1, Float:oper2)
{
	return float(oper1) >= oper2;
}

bool:StrEqual(String:str1[], String:str2[], bool:caseSensitive)
{
	return strcmp(str1, str2, caseSensitive) == 0;
}

FindCharInString(String:str[], String:c, bool:reverse)
{
	new len = strlen(str);
	if (!reverse)
	{
		new i;
		while (i < len)
		{
			if (c == str[i])
			{
				return i;
			}
			i++;
		}
	}
	else
	{
		new i = len + -1;
		while (0 <= i)
		{
			if (c == str[i])
			{
				return i;
			}
			i--;
		}
	}
	return -1;
}

ReadFileCell(Handle:hndl, &data, size)
{
	new ret;
	new array[1];
	if ((ret = ReadFile(hndl, array, 1, size)) == 1)
	{
		data = array[0];
	}
	return ret;
}

bool:WriteFileCell(Handle:hndl, data, size)
{
	new array[1];
	array[0] = data;
	return WriteFile(hndl, array, 1, size);
}

PrintCenterTextAll(String:format[])
{
	decl String:buffer[192];
	new i = 1;
	while (i <= MaxClients)
	{
		if (IsClientInGame(i))
		{
			SetGlobalTransTarget(i);
			VFormat(buffer, 192, format, 2);
			PrintCenterText(i, "%s", buffer);
		}
		i++;
	}
	return 0;
}

AddFileToDownloadsTable(String:filename[])
{
	static table = -1;
	if (table == -1)
	{
		table = FindStringTable("downloadables");
	}
	new bool:save = LockStringTables(false);
	AddToStringTable(table, filename, "", -1);
	LockStringTables(save);
	return 0;
}

public GlobalConVarChanged(Handle:convar, String:oldValue[], String:newValue[])
{
	new i;
	while (i < g_iCvars)
	{
		if (convar == g_eCvars[i][0])
		{
			CacheCvarValue(i);
			if (g_eCvars[i][131] != -1)
			{
				Call_StartFunction(Handle:0, g_eCvars[i][131]);
				Call_PushCell(i);
				Call_Finish(0);
			}
			return 0;
		}
		i++;
	}
	return 0;
}

public CacheCvarValue(index)
{
	GetConVarString(g_eCvars[index][0], g_eCvars[index][3], 128);
	if (g_eCvars[index][1])
	{
		if (g_eCvars[index][1] == 1)
		{
			g_eCvars[index][2] = GetConVarFloat(g_eCvars[index][0]);
		}
		if (g_eCvars[index][1] == 3)
		{
			g_eCvars[index][2] = ReadFlagString(g_eCvars[index][3], 0);
		}
	}
	else
	{
		g_eCvars[index][2] = GetConVarInt(g_eCvars[index][0]);
	}
	return 0;
}

public SQLCallback_Void(Handle:owner, Handle:hndl, String:error[], any:suspend_errors)
{
	new var1;
	if (hndl && !suspend_errors)
	{
		LogError("SQL error happened. Error: %s", error);
	}
	return 0;
}

public SQLCallback_Void_PrintQuery(Handle:owner, Handle:hndl, String:error[], any:data)
{
	if (!hndl)
	{
		new String:query[2048];
		ReadPackString(data, query, 2048);
		LogError("SQL error happened.\nQuery: %s\nError: %s", query, error);
	}
	CloseHandle(data);
	return 0;
}

public SQL_TVoid(Handle:db, String:query[])
{
	new Handle:data = CreateDataPack();
	WritePackString(data, query);
	ResetPack(data, false);
	SQL_TQuery(db, SQLCallback_Void_PrintQuery, query, data, DBPriority:1);
	return 0;
}

public SQLCallback_NoError(Handle:owner, Handle:hndl, String:error[], any:suspend_errors)
{
	return 0;
}

public MenuHandler_CloseClientMenu(Handle:menu, MenuAction:action, client, param2)
{
	if (action == MenuAction:16)
	{
		CloseHandle(menu);
	}
	return 0;
}

public bool:TraceRayDontHitSelf(entity, mask, any:data)
{
	if (data == entity)
	{
		return false;
	}
	return true;
}

public bool:TraceRayDontHitPlayers(entity, mask, any:data)
{
	if (0 < entity <= MaxClients)
	{
		return false;
	}
	return true;
}

public CreateCountdown(client, seconds, String:format[])
{
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, GetClientUserId(client));
	WritePackCell(pack, seconds);
	WritePackString(pack, format);
	ResetPack(pack, false);
	CreateTimer(0.0, Timer_Countdown, pack, 0);
	return 0;
}

public CreateCountdownAll(seconds, String:format[])
{
	new Handle:pack = CreateDataPack();
	WritePackCell(pack, any:0);
	WritePackCell(pack, seconds);
	WritePackString(pack, format);
	ResetPack(pack, false);
	CreateTimer(0.0, Timer_Countdown, pack, 0);
	return 0;
}

public Action:Timer_Countdown(Handle:timer, any:pack)
{
	new userid = ReadPackCell(pack);
	decl client;
	if (userid)
	{
		client = GetClientOfUserId(userid);
		if (!client)
		{
			CloseHandle(pack);
			return Action:4;
		}
	}
	new seconds = ReadPackCell(pack);
	decl String:format[192];
	ReadPackString(pack, format, 192);
	if (userid)
	{
		PrintCenterText(client, "%t", format, seconds);
	}
	else
	{
		PrintCenterTextAll("%t", format, seconds);
	}
	if (seconds != 1)
	{
		ResetPack(pack, false);
		ReadPackCell(pack);
		WritePackCell(pack, seconds + -1);
		ResetPack(pack, false);
		CreateTimer(1.0, Timer_Countdown, pack, 0);
	}
	else
	{
		CloseHandle(pack);
	}
	return Action:4;
}

Downloader_ParseMDL(String:model[], String:internal[], maxlen1, String:files[][], maxsize, maxlen2)
{
	if (!FileExists2(model))
	{
		return 0;
	}
	new m_iID;
	new m_iVersion;
	new m_iNum;
	new m_iDirNum;
	new m_iOffset;
	new m_iDirOffset;
	new m_iNameOffset;
	new m_iIdx;
	new Handle:m_hFile = OpenFile2(model, "rb");
	if (m_hFile)
	{
		ReadFileCell(m_hFile, m_iID, 4);
		ReadFileCell(m_hFile, m_iVersion, 4);
		FileSeek(m_hFile, 4, 1);
		ReadFileString(m_hFile, internal, maxlen1, -1);
		FileSeek(m_hFile, 204, 0);
		ReadFileCell(m_hFile, m_iNum, 4);
		ReadFileCell(m_hFile, m_iOffset, 4);
		ReadFileCell(m_hFile, m_iDirNum, 4);
		ReadFileCell(m_hFile, m_iDirOffset, 4);
		new String:m_szPath[256];
		if (m_iDirNum)
		{
			FileSeek(m_hFile, m_iDirOffset, 0);
			ReadFileCell(m_hFile, m_iDirOffset, 4);
			FileSeek(m_hFile, m_iDirOffset, 0);
			ReadFileString(m_hFile, m_szPath, 256, -1);
		}
		new String:m_szMaterial[256];
		m_iIdx = 0;
		while (m_iIdx < m_iNum)
		{
			FileSeek(m_hFile, m_iIdx * 64 + m_iOffset, 0);
			ReadFileCell(m_hFile, m_iNameOffset, 4);
			FileSeek(m_hFile, m_iNameOffset + -4, 1);
			ReadFileString(m_hFile, m_szMaterial, 256, -1);
			Format(files[m_iIdx], maxlen2, "materials\%s%s.vmt", m_szPath, m_szMaterial);
			m_iIdx++;
		}
		return m_iNum;
	}
	return 0;
}

Downloader_GetModelFiles(String:model[], String:internal[], String:files[][], maxsize, maxlen)
{
	decl String:m_szRawPath1[256];
	decl String:m_szRawPath2[256];
	strcopy(m_szRawPath1, 256, model);
	Format(m_szRawPath2, 256, "models/%s", internal);
	new m_iDot = FindCharInString(m_szRawPath1, String:46, true);
	if (m_iDot == -1)
	{
		return 0;
	}
	m_szRawPath1[m_iDot] = MissingTAG:0;
	m_iDot = FindCharInString(m_szRawPath2, String:46, true);
	if (m_iDot == -1)
	{
		return 0;
	}
	m_szRawPath2[m_iDot] = MissingTAG:0;
	new m_iNum;
	new i;
	while (i < 7)
	{
		if (!(maxsize == m_iNum))
		{
			Format(files[m_iNum], maxlen, "%s%s", m_szRawPath1, g_szModelExts[i]);
			if (FileExists2(files[m_iNum]))
			{
				m_iNum++;
			}
			else
			{
				Format(files[m_iNum], maxlen, "%s%s", m_szRawPath2, g_szModelExts[i]);
				if (FileExists2(files[m_iNum]))
				{
					m_iNum++;
				}
			}
			i++;
		}
		return m_iNum;
	}
	return m_iNum;
}

Downloader_GetMaterialsFromVMT(String:vmt[], String:materials[][], maxsize, maxlen)
{
	if (!FileExists2(vmt))
	{
		return 0;
	}
	decl String:m_szLine[512];
	new Handle:m_hFile = OpenFile2(vmt, "r");
	new bool:m_bFound[3];
	decl m_iPos;
	decl m_iLast;
	new m_iNum;
	while (ReadFileLine(m_hFile, m_szLine, 512))
	{
		new var1;
		if (!(m_iNum == 3 || m_iNum != maxsize))
		{
			new i;
			while (i < 3)
			{
				if (!m_bFound[i])
				{
					if (0 < (m_iPos = StrContains(m_szLine, g_szMaterialKeys[i], false)))
					{
						m_bFound[i] = true;
						while (m_szLine[m_iPos] != '"' && m_szLine[m_iPos] != ' ' && m_szLine[m_iPos] != '	')
						{
							m_iPos++;
						}
						while (m_szLine[m_iPos] == ' ' || m_szLine[m_iPos] == '	' || m_szLine[m_iPos] == '"')
						{
							m_iPos++;
						}
						m_iLast = m_iPos;
' && m_szLine[m_iLast] != '
' && m_szLine[m_iLast] != ' ' && m_szLine[m_iLast] != '	' && m_szLine[m_iLast])
						{
							m_iLast++;
						}
						m_szLine[m_iLast] = MissingTAG:0;
						strcopy(materials[m_iNum], maxlen, m_szLine[m_iPos]);
						m_iNum++;
					}
				}
				i++;
			}
		}
		CloseHandle(m_hFile);
		return m_iNum;
	}
	CloseHandle(m_hFile);
	return m_iNum;
}

Downloader_AddFileToDownloadsTable(String:filename[])
{
	if (!FileExists2(filename))
	{
		return 0;
	}
	if (!g_hCachedNums)
	{
		g_hCachedNums = CreateTrie();
		g_hCachedFiles = CreateArray(256, 0);
	}
	AddFileToDownloadsTable(filename);
	decl m_iValue;
	if (GetTrieValue(g_hCachedNums, filename, m_iValue))
	{
		new m_iStart = FindStringInArray(g_hCachedFiles, filename) + 1;
		decl String:m_szFile[256];
		new i = m_iStart - m_iValue + -1;
		while (m_iStart + -1 > i)
		{
			if (!(0 > i))
			{
				GetArrayString(g_hCachedFiles, i, m_szFile, 256);
				AddFileToDownloadsTable(m_szFile);
				i++;
			}
			return 1;
		}
		return 1;
	}
	decl String:m_szExt[16];
	new m_iDot = FindCharInString(filename, String:46, true);
	if (m_iDot == -1)
	{
		return 1;
	}
	new m_iNumFiles;
	strcopy(m_szExt, 16, filename[m_iDot]);
	new String:m_szMaterials[32][256] = "�";
	decl m_iNum;
	if (strcmp(m_szExt, ".mdl", true))
	{
		if (!(strcmp(m_szExt, ".vmt", true)))
		{
			m_iNum = Downloader_GetMaterialsFromVMT(filename, m_szMaterials, 32, 256);
			decl String:m_szMaterial[256];
			new i;
			while (i < m_iNum)
			{
				Format(m_szMaterial, 256, "materials\%s.vtf", m_szMaterials[i]);
				if (FileExists2(m_szMaterial))
				{
					m_iNumFiles = Downloader_AddFileToDownloadsTable(m_szMaterial) + 1 + m_iNumFiles;
				}
				i++;
			}
		}
	}
	else
	{
		new String:m_szFiles[7][256] = "";
		new String:m_szInternal[64];
		m_iNum = Downloader_ParseMDL(filename, m_szInternal, 64, m_szMaterials, 32, 256);
		new i;
		while (i < m_iNum)
		{
			if (FileExists2(m_szMaterials[i]))
			{
				m_iNumFiles = Downloader_AddFileToDownloadsTable(m_szMaterials[i]) + 1 + m_iNumFiles;
			}
			i++;
		}
		m_iNum = Downloader_GetModelFiles(filename, m_szInternal, m_szFiles, 7, 256);
		new i;
		while (i < m_iNum)
		{
			m_iNumFiles = Downloader_AddFileToDownloadsTable(m_szFiles[i]) + 1 + m_iNumFiles;
			i++;
		}
	}
	PushArrayString(g_hCachedFiles, filename);
	SetTrieValue(g_hCachedNums, filename, m_iNumFiles, true);
	return m_iNumFiles;
}

public CacheCustomDirectory()
{
	g_hCustomFiles = CreateTrie();
	new Handle:m_hDir = OpenDirectory("custom", false, "GAME");
	if (m_hDir)
	{
		new String:m_szDirectory[256] = "custom/";
		decl FileType:m_eType;
		new m_unLen = strlen(m_szDirectory);
		while (ReadDirEntry(m_hDir, m_szDirectory[m_unLen], 256 - m_unLen, m_eType))
		{
			if (!(m_eType != FileType:1))
			{
				new var1;
				if (!(strcmp(m_szDirectory[m_unLen], ".", true) && strcmp(m_szDirectory[m_unLen], "..", true)))
				{
					CacheDirectory(m_szDirectory);
				}
			}
		}
		CloseHandle(m_hDir);
		return 0;
	}
	return 0;
}

public CacheDirectory(String:directory[])
{
	new Handle:m_hDir = OpenDirectory(directory, false, "GAME");
	decl String:m_szPath[256];
	decl FileType:m_eType;
	Format(m_szPath, 256, "%s/", directory);
	new m_unLen = strlen(m_szPath);
	new m_unOffset = FindCharInString(m_szPath, String:47, false) + 1;
	m_unOffset = FindCharInString(m_szPath[m_unOffset], String:47, false) + 1 + m_unOffset;
	while (ReadDirEntry(m_hDir, m_szPath[m_unLen], 256 - m_unLen, m_eType))
	{
		new var1;
		if (!(strcmp(m_szPath[m_unLen], ".", true) && strcmp(m_szPath[m_unLen], "..", true)))
		{
			if (m_eType == FileType:1)
			{
				CacheDirectory(m_szPath);
			}
			else
			{
				if (m_eType == FileType:2)
				{
					SetTrieString(g_hCustomFiles, m_szPath[m_unOffset], m_szPath, true);
				}
			}
		}
	}
	CloseHandle(m_hDir);
	return 0;
}

Handle:OpenFile2(String:file[], String:mode[])
{
	if (!g_hCustomFiles)
	{
		CacheCustomDirectory();
	}
	decl String:m_szPath[256];
	if (!GetTrieString(g_hCustomFiles, file, m_szPath, 256, 0))
	{
		strcopy(m_szPath, 256, file);
	}
	return OpenFile(m_szPath, mode, false, "GAME");
}

bool:FileExists2(String:file[])
{
	if (!g_hCustomFiles)
	{
		CacheCustomDirectory();
	}
	decl String:m_szPath[256];
	if (!GetTrieString(g_hCustomFiles, file, m_szPath, 256, 0))
	{
		return FileExists(file, false, "GAME");
	}
	return FileExists(m_szPath, false, "GAME");
}

public __ext_curl_SetNTVOptional()
{
	MarkNativeAsOptional("curl_easy_init");
	MarkNativeAsOptional("curl_easy_setopt_string");
	MarkNativeAsOptional("curl_easy_setopt_int");
	MarkNativeAsOptional("curl_easy_setopt_int_array");
	MarkNativeAsOptional("curl_easy_setopt_int64");
	MarkNativeAsOptional("curl_OpenFile");
	MarkNativeAsOptional("curl_httppost");
	MarkNativeAsOptional("curl_slist");
	MarkNativeAsOptional("curl_easy_setopt_handle");
	MarkNativeAsOptional("curl_easy_setopt_function");
	MarkNativeAsOptional("curl_load_opt");
	MarkNativeAsOptional("curl_easy_perform");
	MarkNativeAsOptional("curl_easy_perform_thread");
	MarkNativeAsOptional("curl_easy_send_recv");
	MarkNativeAsOptional("curl_send_recv_Signal");
	MarkNativeAsOptional("curl_send_recv_IsWaiting");
	MarkNativeAsOptional("curl_set_send_buffer");
	MarkNativeAsOptional("curl_set_receive_size");
	MarkNativeAsOptional("curl_set_send_timeout");
	MarkNativeAsOptional("curl_set_recv_timeout");
	MarkNativeAsOptional("curl_get_error_buffer");
	MarkNativeAsOptional("curl_easy_getinfo_string");
	MarkNativeAsOptional("curl_easy_getinfo_int");
	MarkNativeAsOptional("curl_easy_escape");
	MarkNativeAsOptional("curl_easy_unescape");
	MarkNativeAsOptional("curl_easy_strerror");
	MarkNativeAsOptional("curl_version");
	MarkNativeAsOptional("curl_protocols");
	MarkNativeAsOptional("curl_features");
	MarkNativeAsOptional("curl_OpenFile");
	MarkNativeAsOptional("curl_httppost");
	MarkNativeAsOptional("curl_formadd");
	MarkNativeAsOptional("curl_slist");
	MarkNativeAsOptional("curl_slist_append");
	MarkNativeAsOptional("curl_hash_file");
	MarkNativeAsOptional("curl_hash_string");
	return 0;
}

public __ext__smsock_SetNTVOptional()
{
	MarkNativeAsOptional("SocketIsConnected");
	MarkNativeAsOptional("SocketCreate");
	MarkNativeAsOptional("SocketBind");
	MarkNativeAsOptional("SocketConnect");
	MarkNativeAsOptional("SocketDisconnect");
	MarkNativeAsOptional("SocketListen");
	MarkNativeAsOptional("SocketSend");
	MarkNativeAsOptional("SocketSendTo");
	MarkNativeAsOptional("SocketSetOption");
	MarkNativeAsOptional("SocketSetReceiveCallback");
	MarkNativeAsOptional("SocketSetSendqueueEmptyCallback");
	MarkNativeAsOptional("SocketSetDisconnectCallback");
	MarkNativeAsOptional("SocketSetErrorCallback");
	MarkNativeAsOptional("SocketSetArg");
	MarkNativeAsOptional("SocketGetHostName");
	return 0;
}

public __ext_SteamTools_SetNTVOptional()
{
	MarkNativeAsOptional("Steam_IsVACEnabled");
	MarkNativeAsOptional("Steam_GetPublicIP");
	MarkNativeAsOptional("Steam_RequestGroupStatus");
	MarkNativeAsOptional("Steam_RequestGameplayStats");
	MarkNativeAsOptional("Steam_RequestServerReputation");
	MarkNativeAsOptional("Steam_IsConnected");
	MarkNativeAsOptional("Steam_SetRule");
	MarkNativeAsOptional("Steam_ClearRules");
	MarkNativeAsOptional("Steam_ForceHeartbeat");
	MarkNativeAsOptional("Steam_AddMasterServer");
	MarkNativeAsOptional("Steam_RemoveMasterServer");
	MarkNativeAsOptional("Steam_GetNumMasterServers");
	MarkNativeAsOptional("Steam_GetMasterServerAddress");
	MarkNativeAsOptional("Steam_SetGameDescription");
	MarkNativeAsOptional("Steam_RequestStats");
	MarkNativeAsOptional("Steam_GetStat");
	MarkNativeAsOptional("Steam_GetStatFloat");
	MarkNativeAsOptional("Steam_IsAchieved");
	MarkNativeAsOptional("Steam_GetNumClientSubscriptions");
	MarkNativeAsOptional("Steam_GetClientSubscription");
	MarkNativeAsOptional("Steam_GetNumClientDLCs");
	MarkNativeAsOptional("Steam_GetClientDLC");
	MarkNativeAsOptional("Steam_GetCSteamIDForClient");
	MarkNativeAsOptional("Steam_SetCustomSteamID");
	MarkNativeAsOptional("Steam_GetCustomSteamID");
	MarkNativeAsOptional("Steam_RenderedIDToCSteamID");
	MarkNativeAsOptional("Steam_CSteamIDToRenderedID");
	MarkNativeAsOptional("Steam_GroupIDToCSteamID");
	MarkNativeAsOptional("Steam_CSteamIDToGroupID");
	MarkNativeAsOptional("Steam_CreateHTTPRequest");
	MarkNativeAsOptional("Steam_SetHTTPRequestNetworkActivityTimeout");
	MarkNativeAsOptional("Steam_SetHTTPRequestHeaderValue");
	MarkNativeAsOptional("Steam_SetHTTPRequestGetOrPostParameter");
	MarkNativeAsOptional("Steam_SendHTTPRequest");
	MarkNativeAsOptional("Steam_DeferHTTPRequest");
	MarkNativeAsOptional("Steam_PrioritizeHTTPRequest");
	MarkNativeAsOptional("Steam_GetHTTPResponseHeaderSize");
	MarkNativeAsOptional("Steam_GetHTTPResponseHeaderValue");
	MarkNativeAsOptional("Steam_GetHTTPResponseBodySize");
	MarkNativeAsOptional("Steam_GetHTTPResponseBodyData");
	MarkNativeAsOptional("Steam_WriteHTTPResponseBody");
	MarkNativeAsOptional("Steam_ReleaseHTTPRequest");
	MarkNativeAsOptional("Steam_GetHTTPDownloadProgressPercent");
	return 0;
}

public __ext_SteamWorks_SetNTVOptional()
{
	MarkNativeAsOptional("SteamWorks_IsVACEnabled");
	MarkNativeAsOptional("SteamWorks_GetPublicIP");
	MarkNativeAsOptional("SteamWorks_GetPublicIPCell");
	MarkNativeAsOptional("SteamWorks_IsLoaded");
	MarkNativeAsOptional("SteamWorks_SetGameDescription");
	MarkNativeAsOptional("SteamWorks_IsConnected");
	MarkNativeAsOptional("SteamWorks_SetRule");
	MarkNativeAsOptional("SteamWorks_ClearRules");
	MarkNativeAsOptional("SteamWorks_ForceHeartbeat");
	MarkNativeAsOptional("SteamWorks_GetUserGroupStatus");
	MarkNativeAsOptional("SteamWorks_GetUserGroupStatusAuthID");
	MarkNativeAsOptional("SteamWorks_HasLicenseForApp");
	MarkNativeAsOptional("SteamWorks_HasLicenseForAppId");
	MarkNativeAsOptional("SteamWorks_GetClientSteamID");
	MarkNativeAsOptional("SteamWorks_RequestStatsAuthID");
	MarkNativeAsOptional("SteamWorks_RequestStats");
	MarkNativeAsOptional("SteamWorks_GetStatCell");
	MarkNativeAsOptional("SteamWorks_GetStatAuthIDCell");
	MarkNativeAsOptional("SteamWorks_GetStatFloat");
	MarkNativeAsOptional("SteamWorks_GetStatAuthIDFloat");
	MarkNativeAsOptional("SteamWorks_SendMessageToGC");
	MarkNativeAsOptional("SteamWorks_CreateHTTPRequest");
	MarkNativeAsOptional("SteamWorks_SetHTTPRequestContextValue");
	MarkNativeAsOptional("SteamWorks_SetHTTPRequestNetworkActivityTimeout");
	MarkNativeAsOptional("SteamWorks_SetHTTPRequestHeaderValue");
	MarkNativeAsOptional("SteamWorks_SetHTTPRequestGetOrPostParameter");
	MarkNativeAsOptional("SteamWorks_SetHTTPCallbacks");
	MarkNativeAsOptional("SteamWorks_SendHTTPRequest");
	MarkNativeAsOptional("SteamWorks_SendHTTPRequestAndStreamResponse");
	MarkNativeAsOptional("SteamWorks_DeferHTTPRequest");
	MarkNativeAsOptional("SteamWorks_PrioritizeHTTPRequest");
	MarkNativeAsOptional("SteamWorks_GetHTTPResponseHeaderSize");
	MarkNativeAsOptional("SteamWorks_GetHTTPResponseHeaderValue");
	MarkNativeAsOptional("SteamWorks_GetHTTPResponseBodySize");
	MarkNativeAsOptional("SteamWorks_GetHTTPResponseBodyData");
	MarkNativeAsOptional("SteamWorks_GetHTTPStreamingResponseBodyData");
	MarkNativeAsOptional("SteamWorks_GetHTTPDownloadProgressPct");
	MarkNativeAsOptional("SteamWorks_SetHTTPRequestRawPostBody");
	MarkNativeAsOptional("SteamWorks_GetHTTPResponseBodyCallback");
	MarkNativeAsOptional("SteamWorks_WriteHTTPResponseBodyToFile");
	return 0;
}

EasyHTTPCheckExtensions()
{
	g_bExtensions = true;
	new var1;
	if (GetExtensionFileStatus("socket.ext", "", 0) == 1)
	{
		var1 = 1;
	}
	else
	{
		var1 = 0;
	}
	g_bSockets = var1;
	new var2;
	if (GetExtensionFileStatus("curl.ext", "", 0) == 1)
	{
		var2 = 1;
	}
	else
	{
		var2 = 0;
	}
	g_bCURL = var2;
	new var3;
	if (GetExtensionFileStatus("steamtools.ext", "", 0) == 1)
	{
		var3 = 1;
	}
	else
	{
		var3 = 0;
	}
	g_bSteamTools = var3;
	new var4;
	if (GetExtensionFileStatus("SteamWorks.ext", "", 0) == 1)
	{
		var4 = 1;
	}
	else
	{
		var4 = 0;
	}
	g_bSteamWorks = var4;
	return 0;
}

EasyHTTP_QueryString(Handle:params, String:out[], maxlen)
{
	new m_szQuery[maxlen];
	new Handle:m_hKeys = ReadPackCell(params);
	new Handle:m_hValues = ReadPackCell(params);
	ResetPack(params, false);
	new m_unSize = GetArraySize(m_hKeys);
	new String:m_szKey[64];
	new String:m_szKeyEncoded[128];
	new String:m_szValue[256];
	new String:m_szValueEncoded[512];
	new idx;
	new i;
	while (i < m_unSize)
	{
		GetArrayString(m_hKeys, i, m_szKey, 64);
		if (GetTrieString(m_hValues, m_szKey, m_szValue, 256, 0))
		{
			EasyHTTP_URLEncode(m_szKey, m_szKeyEncoded, 128);
			EasyHTTP_URLEncode(m_szValue, m_szValueEncoded, 512);
			idx = Format(m_szQuery[idx], maxlen - idx, "&%s=%s", m_szKeyEncoded, m_szValueEncoded) + idx;
		}
		i++;
	}
	if (0 < idx)
	{
		strcopy(out, maxlen, m_szQuery[0]);
	}
	return 0;
}

bool:EasyHTTP(String:url[], EHTTPMethodInternal:method, Handle:params, EasyHTTPComplete:complete, any:data, String:path[])
{
	if (!g_bExtensions)
	{
		EasyHTTPCheckExtensions();
	}
	if (!g_szInterfaceIP[0])
	{
		new Handle:m_hHostIP = FindConVar("hostip");
		if (!m_hHostIP)
		{
			LogError("EasyHTTP can't determine IP address of the server.");
		}
		new m_iServerIP = GetConVarInt(m_hHostIP);
		Format(g_szInterfaceIP, 16, "%d.%d.%d.%d", m_iServerIP >> 24 & 255, m_iServerIP >> 16 & 255, m_iServerIP >> 8 & 255, m_iServerIP & 255);
	}
	new m_unURLSize = strlen(url) + 2048;
	new m_szURLNew[m_unURLSize];
	new String:m_szQuery[2048];
	if (params)
	{
		EasyHTTP_QueryString(params, m_szQuery, 2048);
	}
	if (method)
	{
		strcopy(m_szURLNew, m_unURLSize, url);
	}
	else
	{
		Format(m_szURLNew, m_unURLSize, "%s?%s", url, m_szQuery);
	}
	if (g_bCURL)
	{
		new Handle:m_hCurl = curl_easy_init();
		if (m_hCurl)
		{
			new CURL_Default_opt[4][2] = {16,20,24,28,43,1,13,30,78,60,41};
			new Handle:m_hData = CreateDataPack();
			new Handle:m_hContents;
			if (path[0])
			{
				m_hContents = OpenFile(path, "wb", false, "GAME");
				if (!m_hContents)
				{
					LogError("EasyHTTP OpenFile error.");
					return false;
				}
			}
			else
			{
				m_hContents = CreateDataPack();
				WritePackCell(m_hContents, any:0);
				WritePackCell(m_hContents, any:0);
				ResetPack(m_hContents, false);
			}
			WritePackFunction(m_hData, complete);
			WritePackCell(m_hData, data);
			WritePackString(m_hData, path);
			WritePackCell(m_hData, m_hContents);
			ResetPack(m_hData, false);
			curl_easy_setopt_int_array(m_hCurl, CURL_Default_opt, 4);
			curl_easy_setopt_string(m_hCurl, CURLoption:10002, m_szURLNew);
			curl_easy_setopt_function(m_hCurl, CURLoption:20011, EasyHTTP_CurlWrite, m_hData);
			curl_easy_setopt_int(m_hCurl, CURLoption:99, 1);
			if (method == EHTTPMethodInternal:1)
			{
				curl_easy_setopt_int(m_hCurl, CURLoption:47, 1);
				curl_easy_setopt_string(m_hCurl, CURLoption:10015, m_szQuery);
			}
			new CURLcode:m_iCode = curl_load_opt(m_hCurl);
			if (m_iCode)
			{
				CloseHandle(m_hCurl);
				CloseHandle(m_hContents);
				CloseHandle(m_hData);
				return false;
			}
			curl_easy_perform_thread(m_hCurl, EasyHTTP_CurlComplete, m_hData);
			return true;
		}
	}
	else
	{
		new var1;
		if (g_bSteamTools || g_bSteamWorks)
		{
			new Handle:m_hData = CreateDataPack();
			WritePackFunction(m_hData, complete);
			WritePackCell(m_hData, data);
			WritePackString(m_hData, path);
			ResetPack(m_hData, false);
			new m_iLength = strlen(m_szURLNew) + 8;
			decl m_szURL[m_iLength];
			if (StrContains(m_szURLNew, "http://", true) == -1)
			{
				strcopy(m_szURL, m_iLength, "http://");
				strcopy(m_szURL[1], m_iLength + -7, m_szURLNew);
			}
			else
			{
				strcopy(m_szURL, m_iLength, m_szURLNew);
			}
			decl Handle:m_hRequestWorks;
			decl HTTPRequestHandle:m_hRequestTools;
			if (g_bSteamWorks)
			{
				m_hRequestWorks = SteamWorks_CreateHTTPRequest(EHTTPMethod:1, m_szURL);
			}
			else
			{
				m_hRequestTools = Steam_CreateHTTPRequest(HTTPMethod:1, m_szURL);
			}
			if (method == EHTTPMethodInternal:1)
			{
				new Handle:m_hKeys = ReadPackCell(params);
				new Handle:m_hValues = ReadPackCell(params);
				ResetPack(params, false);
				new m_unSize = GetArraySize(m_hKeys);
				new String:m_szKey[64];
				new String:m_szValue[256];
				new i;
				while (i < m_unSize)
				{
					GetArrayString(m_hKeys, i, m_szKey, 64);
					if (GetTrieString(m_hValues, m_szKey, m_szValue, 256, 0))
					{
						if (g_bSteamWorks)
						{
							SteamWorks_SetHTTPRequestGetOrPostParameter(m_hRequestWorks, m_szKey, m_szValue);
						}
						Steam_SetHTTPRequestGetOrPostParameter(m_hRequestTools, m_szKey, m_szValue);
					}
					i++;
				}
			}
			if (g_bSteamWorks)
			{
				SteamWorks_SetHTTPRequestContextValue(m_hRequestWorks, m_hData, any:0);
				SteamWorks_SetHTTPCallbacks(m_hRequestWorks, SteamWorksHTTPRequestCompleted:33, SteamWorksHTTPHeadersReceived:-1, SteamWorksHTTPDataReceived:-1, Handle:0);
				SteamWorks_SendHTTPRequest(m_hRequestWorks);
			}
			else
			{
				Steam_SendHTTPRequest(m_hRequestTools, EasyHTTP_SteamToolsComplete, m_hData);
			}
			return true;
		}
		if (g_bSockets)
		{
			new Handle:m_hData = CreateDataPack();
			new Handle:m_hContents;
			if (path[0])
			{
				m_hContents = OpenFile(path, "wb", false, "GAME");
				if (!m_hContents)
				{
					LogError("EasyHTTP OpenFile error.");
					return false;
				}
			}
			else
			{
				m_hContents = CreateDataPack();
				WritePackCell(m_hContents, any:0);
				WritePackCell(m_hContents, any:0);
				ResetPack(m_hContents, false);
			}
			new m_iLength = strlen(m_szURLNew) + 1;
			new m_szBaseURL[m_iLength];
			EasyHTTP_GetBaseURL(m_szURLNew, m_szBaseURL, m_iLength, false, false);
			new m_iPos;
			if (StrContains(m_szURLNew, "http://", true) != -1)
			{
				m_iPos = 7;
			}
			m_iPos = FindCharInString(m_szURLNew[m_iPos], String:47, false) + m_iPos;
			WritePackCell(m_hData, method);
			if (m_iPos == -1)
			{
				WritePackCell(m_hData, any:1);
				WritePackString(m_hData, "/");
			}
			else
			{
				WritePackCell(m_hData, strlen(m_szURLNew[m_iPos]));
				WritePackString(m_hData, m_szURLNew[m_iPos]);
			}
			WritePackCell(m_hData, strlen(m_szBaseURL));
			WritePackString(m_hData, m_szBaseURL);
			if (method == EHTTPMethodInternal:1)
			{
				WritePackCell(m_hData, strlen(m_szQuery));
				WritePackString(m_hData, m_szQuery);
			}
			else
			{
				WritePackCell(m_hData, any:0);
				WritePackString(m_hData, "");
			}
			WritePackFunction(m_hData, complete);
			WritePackCell(m_hData, data);
			WritePackString(m_hData, path);
			WritePackCell(m_hData, m_hContents);
			WritePackCell(m_hData, any:0);
			ResetPack(m_hData, false);
			new Handle:m_hSocket = SocketCreate(SocketType:1, EasyHTTP_SocketError);
			SocketSetArg(m_hSocket, m_hData);
			if (strncmp(m_szBaseURL, "www.", 4, true))
			{
				SocketConnect(m_hSocket, EasyHTTP_SocketConnected, EasyHTTP_SocketReceive, EasyHTTP_SocketDisconnected, m_szBaseURL, 80);
			}
			else
			{
				SocketConnect(m_hSocket, EasyHTTP_SocketConnected, EasyHTTP_SocketReceive, EasyHTTP_SocketDisconnected, m_szBaseURL[1], 80);
			}
			return true;
		}
	}
	return false;
}

EasyHTTP_GetBaseURL(String:url[], String:output[], maxlen, bool:protocol, bool:pathinfo)
{
	new m_iPos;
	if (!protocol)
	{
		if (!(strncmp(url, "http://", 7, true)))
		{
			m_iPos = 7;
		}
	}
	decl m_iLength;
	new var1;
	if (pathinfo)
	{
		var1 = MissingTAG:63;
	}
	else
	{
		var1 = MissingTAG:47;
	}
	m_iLength = FindCharInString(url[m_iPos], var1, false) + 1;
	if (m_iLength == -1)
	{
		m_iLength = maxlen;
	}
	else
	{
		if (m_iLength > maxlen)
		{
			m_iLength = maxlen;
		}
	}
	strcopy(output, m_iLength, url[m_iPos]);
	if (output[m_iLength + -1] == '/')
	{
		output[m_iLength + -1] = MissingTAG:0;
	}
	return 0;
}

public EasyHTTP_CurlWrite(Handle:hndl, String:buffer[], bytes, nmemb, any:data)
{
	ReadPackFunction(data);
	ReadPackCell(data);
	decl String:m_szPath[256];
	ReadPackString(data, m_szPath, 256);
	decl bool:m_bFile;
	new var1;
	if (m_szPath[0])
	{
		var1 = 1;
	}
	else
	{
		var1 = 0;
	}
	m_bFile = var1;
	new Handle:m_hData = ReadPackCell(data);
	ResetPack(data, false);
	if (m_bFile)
	{
		new m_iIdx;
		while (m_iIdx < nmemb)
		{
			m_iIdx++;
			WriteFileCell(m_hData, buffer[m_iIdx], 1);
		}
	}
	else
	{
		new m_iBytes = ReadPackCell(m_hData);
		new m_iStrings = ReadPackCell(m_hData);
		ResetPack(m_hData, false);
		WritePackCell(m_hData, nmemb + m_iBytes);
		WritePackCell(m_hData, m_iStrings + 1);
		decl String:m_szTmp[1024];
		new i;
		while (i < m_iStrings)
		{
			ReadPackString(m_hData, m_szTmp, 1024);
			i++;
		}
		WritePackString(m_hData, buffer);
		ResetPack(m_hData, false);
	}
	return nmemb * bytes;
}

public EasyHTTP_CurlComplete(Handle:hndl, CURLcode:code, any:data)
{
	CloseHandle(hndl);
	new EasyHTTPComplete:m_fnCallback = ReadPackFunction(data);
	new any:m_aData = ReadPackCell(data);
	decl String:m_szPath[256];
	ReadPackString(data, m_szPath, 256);
	decl bool:m_bFile;
	new var1;
	if (m_szPath[0])
	{
		var1 = 1;
	}
	else
	{
		var1 = 0;
	}
	m_bFile = var1;
	new Handle:m_hData = ReadPackCell(data);
	CloseHandle(data);
	if (code)
	{
		new String:err[256];
		curl_get_error_buffer(hndl, err, 256);
		LogError("CURL error received: %d (%s)", code, err);
		if (m_fnCallback != EasyHTTPComplete:-1)
		{
			Call_StartFunction(Handle:0, m_fnCallback);
			Call_PushCell(m_aData);
			Call_PushString("");
			Call_PushCell(any:0);
			Call_Finish(0);
		}
		return 0;
	}
	if (m_fnCallback != EasyHTTPComplete:-1)
	{
		Call_StartFunction(Handle:0, m_fnCallback);
		Call_PushCell(m_aData);
		new m_iBytes = 1;
		new m_iStrings;
		if (!m_bFile)
		{
			m_iBytes = ReadPackCell(m_hData);
			m_iStrings = ReadPackCell(m_hData);
		}
		new m_szBuffer[m_iBytes + 1];
		if (!m_bFile)
		{
			new m_iPos;
			new i;
			while (i < m_iStrings)
			{
				ReadPackString(m_hData, m_szBuffer[m_iPos], m_iBytes + 1 - m_iPos);
				m_iPos = strlen(m_szBuffer);
				i++;
			}
		}
		Call_PushString(m_szBuffer);
		Call_PushCell(any:1);
		Call_Finish(0);
	}
	CloseHandle(m_hData);
	return 0;
}

public EasyHTTP_SteamWorksComplete(Handle:request, bool:failure, bool:successful, EHTTPStatusCode:code, any:data)
{
	new EasyHTTPComplete:m_fnCallback = ReadPackFunction(data);
	new any:m_aData = ReadPackCell(data);
	decl String:m_szPath[256];
	ReadPackString(data, m_szPath, 256);
	CloseHandle(data);
	if (!successful)
	{
		CloseHandle(request);
		LogError("Request failed. HTTP status: %d", code);
		if (m_fnCallback != EasyHTTPComplete:-1)
		{
			Call_StartFunction(Handle:0, m_fnCallback);
			Call_PushCell(m_aData);
			Call_PushString("");
			Call_PushCell(any:0);
			Call_Finish(0);
		}
		return 0;
	}
	new m_iLength = 1;
	if (!m_szPath[0])
	{
		SteamWorks_GetHTTPResponseBodySize(request, m_iLength);
	}
	decl m_szBuffer[m_iLength + 1];
	if (m_szPath[0])
	{
		SteamWorks_WriteHTTPResponseBodyToFile(request, m_szPath);
	}
	else
	{
		SteamWorks_GetHTTPResponseBodyData(request, m_szBuffer, m_iLength);
		m_szBuffer[m_iLength] = MissingTAG:0;
	}
	if (m_fnCallback != EasyHTTPComplete:-1)
	{
		Call_StartFunction(Handle:0, m_fnCallback);
		Call_PushCell(m_aData);
		Call_PushString(m_szBuffer);
		Call_PushCell(any:1);
		Call_Finish(0);
	}
	CloseHandle(request);
	return 0;
}

public EasyHTTP_SteamToolsComplete(HTTPRequestHandle:request, bool:successful, HTTPStatusCode:code, any:data)
{
	new EasyHTTPComplete:m_fnCallback = ReadPackFunction(data);
	new any:m_aData = ReadPackCell(data);
	decl String:m_szPath[256];
	ReadPackString(data, m_szPath, 256);
	CloseHandle(data);
	if (!successful)
	{
		Steam_ReleaseHTTPRequest(request);
		LogError("Request failed. HTTP status: %d", code);
		if (m_fnCallback != EasyHTTPComplete:-1)
		{
			Call_StartFunction(Handle:0, m_fnCallback);
			Call_PushCell(m_aData);
			Call_PushString("");
			Call_PushCell(any:0);
			Call_Finish(0);
		}
		return 0;
	}
	new m_iLength = 1;
	if (!m_szPath[0])
	{
		m_iLength = Steam_GetHTTPResponseBodySize(request);
	}
	decl m_szBuffer[m_iLength + 1];
	if (m_szPath[0])
	{
		Steam_WriteHTTPResponseBody(request, m_szPath);
	}
	else
	{
		Steam_GetHTTPResponseBodyData(request, m_szBuffer, m_iLength);
		m_szBuffer[m_iLength] = MissingTAG:0;
	}
	if (m_fnCallback != EasyHTTPComplete:-1)
	{
		Call_StartFunction(Handle:0, m_fnCallback);
		Call_PushCell(m_aData);
		Call_PushString(m_szBuffer);
		Call_PushCell(any:1);
		Call_Finish(0);
	}
	Steam_ReleaseHTTPRequest(request);
	return 0;
}

public EasyHTTP_SocketConnected(Handle:socket, any:data)
{
	new EHTTPMethodInternal:method = ReadPackCell(data);
	new m_iGETLength = ReadPackCell(data);
	decl m_szGET[m_iGETLength + 1];
	ReadPackString(data, m_szGET, m_iGETLength + 1);
	new m_iURLLength = ReadPackCell(data);
	decl m_szURL[m_iURLLength + 1];
	ReadPackString(data, m_szURL, m_iURLLength + 1);
	new m_iQueryLength = ReadPackCell(data);
	decl m_szQueryString[m_iQueryLength + 1];
	ReadPackString(data, m_szQueryString, m_iQueryLength + 1);
	ResetPack(data, false);
	new String:m_szMethod[32];
	if (method)
	{
		if (method == EHTTPMethodInternal:1)
		{
			strcopy(m_szMethod, 32, "POST");
		}
		if (method == EHTTPMethodInternal:2)
		{
			strcopy(m_szMethod, 32, "DELETE");
		}
	}
	else
	{
		strcopy(m_szMethod, 32, "GET");
	}
	decl m_szRequest[m_iURLLength + m_iGETLength + 64];
	Format(m_szRequest, m_iURLLength + m_iGETLength + m_iQueryLength + 256, "%s %s HTTP/1.0\r\nHost: %s\r\nConnection: close\r\nContent-Length: %d\r\nContent-Type: application/x-www-form-urlencoded\r\n\r\n%s", m_szMethod, m_szGET, m_szURL, m_iQueryLength, m_szQueryString);
	SocketSend(socket, m_szRequest, -1);
	return 0;
}

public EasyHTTP_SocketReceive(Handle:socket, String:receiveData[], dataSize, any:data)
{
	ReadPackCell(data);
	decl String:m_szHelper[4];
	ReadPackCell(data);
	ReadPackString(data, m_szHelper, 1);
	ReadPackCell(data);
	ReadPackString(data, m_szHelper, 1);
	ReadPackCell(data);
	ReadPackString(data, m_szHelper, 1);
	ReadPackFunction(data);
	ReadPackCell(data);
	decl String:m_szPath[256];
	ReadPackString(data, m_szPath, 256);
	decl bool:m_bFile;
	new var1;
	if (m_szPath[0])
	{
		var1 = 1;
	}
	else
	{
		var1 = 0;
	}
	m_bFile = var1;
	new Handle:m_hData = ReadPackCell(data);
	new m_iHeaders = GetPackPosition(data);
	new bool:m_bHeaders = ReadPackCell(data);
	ResetPack(data, false);
	new m_iPos;
	if (!m_bHeaders)
	{
		if ((m_iPos = StrContains(receiveData, "\r\n\r\n", true)) == -1)
		{
			m_iPos = 0;
		}
		m_iPos += 4;
		SetPackPosition(data, m_iHeaders);
		WritePackCell(data, any:1);
		ResetPack(data, false);
	}
	if (m_bFile)
	{
		new m_iIdx = m_iPos;
		while (m_iIdx < dataSize)
		{
			m_iIdx++;
			WriteFileCell(m_hData, receiveData[m_iIdx], 1);
		}
	}
	else
	{
		new m_iBytes = ReadPackCell(m_hData);
		new m_iStrings = ReadPackCell(m_hData);
		ResetPack(m_hData, false);
		WritePackCell(m_hData, dataSize + m_iBytes);
		WritePackCell(m_hData, m_iStrings + 1);
		decl String:m_szTmp[4096];
		new i;
		while (i < m_iStrings)
		{
			ReadPackString(m_hData, m_szTmp, 4096);
			i++;
		}
		WritePackString(m_hData, receiveData[m_iPos]);
		ResetPack(m_hData, false);
	}
	return 0;
}

public EasyHTTP_SocketDisconnected(Handle:socket, any:data)
{
	ReadPackCell(data);
	decl String:m_szHelper[4];
	ReadPackCell(data);
	ReadPackString(data, m_szHelper, 1);
	ReadPackCell(data);
	ReadPackString(data, m_szHelper, 1);
	ReadPackCell(data);
	ReadPackString(data, m_szHelper, 1);
	new EasyHTTPComplete:m_fnCallback = ReadPackFunction(data);
	new any:m_aData = ReadPackCell(data);
	decl String:m_szPath[256];
	ReadPackString(data, m_szPath, 256);
	decl bool:m_bFile;
	new var1;
	if (m_szPath[0])
	{
		var1 = 1;
	}
	else
	{
		var1 = 0;
	}
	m_bFile = var1;
	new Handle:m_hData = ReadPackCell(data);
	CloseHandle(data);
	if (m_fnCallback != EasyHTTPComplete:-1)
	{
		Call_StartFunction(Handle:0, m_fnCallback);
		Call_PushCell(m_aData);
		new m_iBytes = 1;
		new m_iStrings;
		if (!m_bFile)
		{
			m_iBytes = ReadPackCell(m_hData);
			m_iStrings = ReadPackCell(m_hData);
		}
		new m_szBuffer[m_iBytes + 1];
		if (!m_bFile)
		{
			new m_iPos;
			new i;
			while (i < m_iStrings)
			{
				ReadPackString(m_hData, m_szBuffer[m_iPos], m_iBytes + 1 - m_iPos);
				m_iPos = strlen(m_szBuffer);
				i++;
			}
		}
		Call_PushString(m_szBuffer);
		Call_PushCell(any:1);
		Call_Finish(0);
	}
	CloseHandle(m_hData);
	CloseHandle(socket);
	return 0;
}

public EasyHTTP_SocketError(Handle:socket, errorType, errorNum, any:data)
{
	ReadPackCell(data);
	decl String:m_szHelper[4];
	ReadPackCell(data);
	ReadPackString(data, m_szHelper, 1);
	ReadPackCell(data);
	ReadPackString(data, m_szHelper, 1);
	ReadPackCell(data);
	ReadPackString(data, m_szHelper, 1);
	new EasyHTTPComplete:m_fnCallback = ReadPackFunction(data);
	new any:m_aData = ReadPackCell(data);
	CloseHandle(data);
	LogError("Request failed. Error type: %d Num: %d", errorType, errorNum);
	if (m_fnCallback != EasyHTTPComplete:-1)
	{
		Call_StartFunction(Handle:0, m_fnCallback);
		Call_PushCell(m_aData);
		Call_PushString("");
		Call_PushCell(any:0);
		Call_Finish(0);
	}
	CloseHandle(socket);
	return 0;
}

EasyHTTP_URLEncode(String:szInput[], String:szOutput[], iLen)
{
	static HEXCHARS[16] =
	{
		48, 49, 50, 51, 52, 53, 54, 55, 56, 57, 97, 98, 99, 100, 101, 102
	};
	new iPos;
	new cChar;
	new iFLen;
	while ((cChar = szInput[iPos]) && iFLen < iLen)
	{
		if (cChar == 32)
		{
			iFLen++;
			szOutput[iFLen] = MissingTAG:43;
		}
		else
		{
			new var2;
			if (!65 <= 90 >= cChar && !97 <= 122 >= cChar && !48 <= 57 >= cChar && cChar != 45 && cChar != 46 && cChar != 95)
			{
				if (!(iFLen + 3 > iLen))
				{
					new var3;
					if (cChar > 255 || cChar < 0)
					{
						cChar = 42;
					}
					iFLen++;
					szOutput[iFLen] = MissingTAG:37;
					iFLen++;
					szOutput[iFLen] = HEXCHARS[cChar >>> 4];
					iFLen++;
					szOutput[iFLen] = HEXCHARS[cChar & 15];
				}
				szOutput[iFLen] = MissingTAG:0;
				return iFLen;
			}
			iFLen++;
			szOutput[iFLen] = cChar;
		}
		iPos++;
	}
	szOutput[iFLen] = MissingTAG:0;
	return iFLen;
}

EasyHTTP_MarkNatives()
{
	MarkNativeAsOptional("SocketIsConnected");
	MarkNativeAsOptional("SocketCreate");
	MarkNativeAsOptional("SocketBind");
	MarkNativeAsOptional("SocketConnect");
	MarkNativeAsOptional("SocketDisconnect");
	MarkNativeAsOptional("SocketListen");
	MarkNativeAsOptional("SocketSend");
	MarkNativeAsOptional("SocketSendTo");
	MarkNativeAsOptional("SocketSetOption");
	MarkNativeAsOptional("SocketSetReceiveCallback");
	MarkNativeAsOptional("SocketSetSendqueueEmptyCallback");
	MarkNativeAsOptional("SocketSetDisconnectCallback");
	MarkNativeAsOptional("SocketSetErrorCallback");
	MarkNativeAsOptional("SocketSetArg");
	MarkNativeAsOptional("SocketGetHostName");
	MarkNativeAsOptional("SteamWorks_IsVACEnabled");
	MarkNativeAsOptional("SteamWorks_GetPublicIP");
	MarkNativeAsOptional("SteamWorks_GetPublicIPCell");
	MarkNativeAsOptional("SteamWorks_IsLoaded");
	MarkNativeAsOptional("SteamWorks_SetGameDescription");
	MarkNativeAsOptional("SteamWorks_IsConnected");
	MarkNativeAsOptional("SteamWorks_SetRule");
	MarkNativeAsOptional("SteamWorks_ClearRules");
	MarkNativeAsOptional("SteamWorks_ForceHeartbeat");
	MarkNativeAsOptional("SteamWorks_HasLicenseForApp");
	MarkNativeAsOptional("SteamWorks_GetClientSteamID");
	MarkNativeAsOptional("SteamWorks_RequestStatsAuthID");
	MarkNativeAsOptional("SteamWorks_RequestStats");
	MarkNativeAsOptional("SteamWorks_GetStatCell");
	MarkNativeAsOptional("SteamWorks_GetStatAuthIDCell");
	MarkNativeAsOptional("SteamWorks_GetStatFloat");
	MarkNativeAsOptional("SteamWorks_GetStatAuthIDFloat");
	MarkNativeAsOptional("SteamWorks_CreateHTTPRequest");
	MarkNativeAsOptional("SteamWorks_SetHTTPRequestContextValue");
	MarkNativeAsOptional("SteamWorks_SetHTTPRequestNetworkActivityTimeout");
	MarkNativeAsOptional("SteamWorks_SetHTTPRequestHeaderValue");
	MarkNativeAsOptional("SteamWorks_SetHTTPRequestGetOrPostParameter");
	MarkNativeAsOptional("SteamWorks_SetHTTPCallbacks");
	MarkNativeAsOptional("SteamWorks_SendHTTPRequest");
	MarkNativeAsOptional("SteamWorks_SendHTTPRequestAndStreamResponse");
	MarkNativeAsOptional("SteamWorks_DeferHTTPRequest");
	MarkNativeAsOptional("SteamWorks_PrioritizeHTTPRequest");
	MarkNativeAsOptional("SteamWorks_GetHTTPResponseHeaderSize");
	MarkNativeAsOptional("SteamWorks_GetHTTPResponseHeaderValue");
	MarkNativeAsOptional("SteamWorks_GetHTTPResponseBodySize");
	MarkNativeAsOptional("SteamWorks_GetHTTPResponseBodyData");
	MarkNativeAsOptional("SteamWorks_GetHTTPStreamingResponseBodyData");
	MarkNativeAsOptional("SteamWorks_GetHTTPDownloadProgressPct");
	MarkNativeAsOptional("SteamWorks_SetHTTPRequestRawPostBody");
	MarkNativeAsOptional("SteamWorks_GetHTTPResponseBodyCallback");
	MarkNativeAsOptional("SteamWorks_WriteHTTPResponseBodyToFile");
	MarkNativeAsOptional("Steam_IsVACEnabled");
	MarkNativeAsOptional("Steam_GetPublicIP");
	MarkNativeAsOptional("Steam_RequestGroupStatus");
	MarkNativeAsOptional("Steam_RequestGameplayStats");
	MarkNativeAsOptional("Steam_RequestServerReputation");
	MarkNativeAsOptional("Steam_IsConnected");
	MarkNativeAsOptional("Steam_SetRule");
	MarkNativeAsOptional("Steam_ClearRules");
	MarkNativeAsOptional("Steam_ForceHeartbeat");
	MarkNativeAsOptional("Steam_AddMasterServer");
	MarkNativeAsOptional("Steam_RemoveMasterServer");
	MarkNativeAsOptional("Steam_GetNumMasterServers");
	MarkNativeAsOptional("Steam_GetMasterServerAddress");
	MarkNativeAsOptional("Steam_SetGameDescription");
	MarkNativeAsOptional("Steam_RequestStats");
	MarkNativeAsOptional("Steam_GetStat");
	MarkNativeAsOptional("Steam_GetStatFloat");
	MarkNativeAsOptional("Steam_IsAchieved");
	MarkNativeAsOptional("Steam_GetNumClientSubscriptions");
	MarkNativeAsOptional("Steam_GetClientSubscription");
	MarkNativeAsOptional("Steam_GetNumClientDLCs");
	MarkNativeAsOptional("Steam_GetClientDLC");
	MarkNativeAsOptional("Steam_GetCSteamIDForClient");
	MarkNativeAsOptional("Steam_SetCustomSteamID");
	MarkNativeAsOptional("Steam_GetCustomSteamID");
	MarkNativeAsOptional("Steam_RenderedIDToCSteamID");
	MarkNativeAsOptional("Steam_CSteamIDToRenderedID");
	MarkNativeAsOptional("Steam_GroupIDToCSteamID");
	MarkNativeAsOptional("Steam_CSteamIDToGroupID");
	MarkNativeAsOptional("Steam_CreateHTTPRequest");
	MarkNativeAsOptional("Steam_SetHTTPRequestNetworkActivityTimeout");
	MarkNativeAsOptional("Steam_SetHTTPRequestHeaderValue");
	MarkNativeAsOptional("Steam_SetHTTPRequestGetOrPostParameter");
	MarkNativeAsOptional("Steam_SendHTTPRequest");
	MarkNativeAsOptional("Steam_DeferHTTPRequest");
	MarkNativeAsOptional("Steam_PrioritizeHTTPRequest");
	MarkNativeAsOptional("Steam_GetHTTPResponseHeaderSize");
	MarkNativeAsOptional("Steam_GetHTTPResponseHeaderValue");
	MarkNativeAsOptional("Steam_GetHTTPResponseBodySize");
	MarkNativeAsOptional("Steam_GetHTTPResponseBodyData");
	MarkNativeAsOptional("Steam_WriteHTTPResponseBody");
	MarkNativeAsOptional("Steam_ReleaseHTTPRequest");
	MarkNativeAsOptional("Steam_GetHTTPDownloadProgressPercent");
	MarkNativeAsOptional("curl_easy_init");
	MarkNativeAsOptional("curl_easy_setopt_string");
	MarkNativeAsOptional("curl_easy_setopt_int");
	MarkNativeAsOptional("curl_easy_setopt_int_array");
	MarkNativeAsOptional("curl_easy_setopt_int64");
	MarkNativeAsOptional("curl_OpenFile");
	MarkNativeAsOptional("curl_httppost");
	MarkNativeAsOptional("curl_slist");
	MarkNativeAsOptional("curl_easy_setopt_handle");
	MarkNativeAsOptional("curl_easy_setopt_functio	n");
	MarkNativeAsOptional("curl_load_opt");
	MarkNativeAsOptional("curl_easy_perform");
	MarkNativeAsOptional("curl_easy_perform_thread");
	MarkNativeAsOptional("curl_easy_send_recv");
	MarkNativeAsOptional("curl_send_recv_Signal");
	MarkNativeAsOptional("curl_send_recv_IsWaiting");
	MarkNativeAsOptional("curl_set_send_buffer");
	MarkNativeAsOptional("curl_set_receive_size");
	MarkNativeAsOptional("curl_set_send_timeout");
	MarkNativeAsOptional("curl_set_recv_timeout");
	MarkNativeAsOptional("curl_get_error_buffer");
	MarkNativeAsOptional("curl_easy_getinfo_string");
	MarkNativeAsOptional("curl_easy_getinfo_int");
	MarkNativeAsOptional("curl_easy_escape");
	MarkNativeAsOptional("curl_easy_unescape");
	MarkNativeAsOptional("curl_easy_strerror");
	MarkNativeAsOptional("curl_version");
	MarkNativeAsOptional("curl_protocols");
	MarkNativeAsOptional("curl_features");
	MarkNativeAsOptional("curl_OpenFile");
	MarkNativeAsOptional("curl_httppost");
	MarkNativeAsOptional("curl_formadd");
	MarkNativeAsOptional("curl_slist");
	MarkNativeAsOptional("curl_slist_append");
	MarkNativeAsOptional("curl_hash_file");
	MarkNativeAsOptional("curl_hash_string");
	return 0;
}

public void:OnPluginStart()
{
	if (g_bCSGO)
	{
	}
	else
	{
		if (!g_bL4D2)
		{
			if (!g_bND)
			{
				new bool:exists;
				GetGameFolderName(gameDir, 255);
				new i;
				while (i < 11)
				{
					if (StrEqual(g_GamesSupported[i], gameDir, true))
					{
						exists = true;
						if (!exists)
						{
							SetFailState("The game '%s' isn't currently supported by the MOTDgd plugin!", gameDir);
						}
						exists = false;
						CreateConVar("sm_motdgd_version", "2.4.87", "[SM] MOTDgd Plugin Version", 131328, false, 0.0, false, 0.0);
						g_motdID = CreateConVar("sm_motdgd_userid", "0", "MOTDgd User ID. This number can be found at: http://motdgd.com/portal/", 256, false, 0.0, false, 0.0);
						g_immunity = CreateConVar("sm_motdgd_immunity", "0", "Enable/Disable advert immunity", 0, false, 0.0, false, 0.0);
						g_OnConnect = CreateConVar("sm_motdgd_onconnect", "1", "Enable/Disable advert on connect", 0, false, 0.0, false, 0.0);
						if (!StrEqual(gameDir, "tf", true))
						{
							g_autoClose = CreateConVar("sm_motdgd_auto_close", "0.0", "Set time (in seconds) to automatically close the MOTD window.", 0, true, 50.0, false, 0.0);
						}
						g_ipOverride = CreateConVar("sm_motdgd_ip", "", "Your server IP. Use this if your server IP is not identified properly automatically.", 0, false, 0.0, false, 0.0);
						new var1;
						if (!StrEqual(gameDir, "left4dead2", true) && !StrEqual(gameDir, "left4dead", true))
						{
							HookEventEx("arena_win_panel", Event_End, EventHookMode:1);
							HookEventEx("cs_win_panel_round", Event_End, EventHookMode:1);
							HookEventEx("dod_round_win", Event_End, EventHookMode:1);
							HookEventEx("player_death", Event_Death, EventHookMode:1);
							HookEventEx("round_start", Event_Start, EventHookMode:1);
							HookEventEx("round_win", Event_End, EventHookMode:1);
							HookEventEx("teamplay_win_panel", Event_End, EventHookMode:1);
							g_OnOther = CreateConVar("sm_motdgd_onother", "2", "Set 0 to disable, 1 to show on round end, 2 to show on player death, 4 to show on round start, 3=1+2, 5=1+4, 6=2+4, 7=1+2+4", 0, false, 0.0, false, 0.0);
							g_Review = CreateConVar("sm_motdgd_review", "15.0", "Set time (in minutes) to re-display the ad. ConVar sm_motdgd_onother must be configured", 0, true, 15.0, false, 0.0);
						}
						new var2;
						if (!StrEqual(gameDir, "left4dead2", true) && !StrEqual(gameDir, "left4dead", true) && !StrEqual(gameDir, "csgo", true))
						{
							g_forced = CreateConVar("sm_motdgd_forced_duration", "5", "Number of seconds to force an ad view for (except in CS:GO, L4D, L4D2)", 0, false, 0.0, false, 0.0);
						}
						new UserMsg:datVGUIMenu = GetUserMessageId("VGUIMenu");
						if (datVGUIMenu == UserMsg:-1)
						{
							SetFailState("The game '%s' doesn't support VGUI menus.", gameDir);
						}
						HookUserMessage(datVGUIMenu, OnVGUIMenu, true, MsgPostHook:-1);
						AddCommandListener(ClosedMOTD, "closed_htmlpage");
						HookEventEx("player_transitioned", Event_PlayerTransitioned, EventHookMode:1);
						AutoExecConfig(true, "", "sourcemod");
						LoadWhitelist();
						if (LateLoad)
						{
							new i = 1;
							while (i <= MaxClients)
							{
								if (IsClientInGame(i))
								{
									g_lastView[i] = GetTime({0,0});
								}
								i++;
							}
						}
						GetIP();
						return void:0;
					}
					i++;
				}
				if (!exists)
				{
					SetFailState("The game '%s' isn't currently supported by the MOTDgd plugin!", gameDir);
				}
				exists = false;
				CreateConVar("sm_motdgd_version", "2.4.87", "[SM] MOTDgd Plugin Version", 131328, false, 0.0, false, 0.0);
				g_motdID = CreateConVar("sm_motdgd_userid", "0", "MOTDgd User ID. This number can be found at: http://motdgd.com/portal/", 256, false, 0.0, false, 0.0);
				g_immunity = CreateConVar("sm_motdgd_immunity", "0", "Enable/Disable advert immunity", 0, false, 0.0, false, 0.0);
				g_OnConnect = CreateConVar("sm_motdgd_onconnect", "1", "Enable/Disable advert on connect", 0, false, 0.0, false, 0.0);
				if (!StrEqual(gameDir, "tf", true))
				{
					g_autoClose = CreateConVar("sm_motdgd_auto_close", "0.0", "Set time (in seconds) to automatically close the MOTD window.", 0, true, 50.0, false, 0.0);
				}
				g_ipOverride = CreateConVar("sm_motdgd_ip", "", "Your server IP. Use this if your server IP is not identified properly automatically.", 0, false, 0.0, false, 0.0);
				new var1;
				if (!StrEqual(gameDir, "left4dead2", true) && !StrEqual(gameDir, "left4dead", true))
				{
					HookEventEx("arena_win_panel", Event_End, EventHookMode:1);
					HookEventEx("cs_win_panel_round", Event_End, EventHookMode:1);
					HookEventEx("dod_round_win", Event_End, EventHookMode:1);
					HookEventEx("player_death", Event_Death, EventHookMode:1);
					HookEventEx("round_start", Event_Start, EventHookMode:1);
					HookEventEx("round_win", Event_End, EventHookMode:1);
					HookEventEx("teamplay_win_panel", Event_End, EventHookMode:1);
					g_OnOther = CreateConVar("sm_motdgd_onother", "2", "Set 0 to disable, 1 to show on round end, 2 to show on player death, 4 to show on round start, 3=1+2, 5=1+4, 6=2+4, 7=1+2+4", 0, false, 0.0, false, 0.0);
					g_Review = CreateConVar("sm_motdgd_review", "15.0", "Set time (in minutes) to re-display the ad. ConVar sm_motdgd_onother must be configured", 0, true, 15.0, false, 0.0);
				}
				new var2;
				if (!StrEqual(gameDir, "left4dead2", true) && !StrEqual(gameDir, "left4dead", true) && !StrEqual(gameDir, "csgo", true))
				{
					g_forced = CreateConVar("sm_motdgd_forced_duration", "5", "Number of seconds to force an ad view for (except in CS:GO, L4D, L4D2)", 0, false, 0.0, false, 0.0);
				}
				new UserMsg:datVGUIMenu = GetUserMessageId("VGUIMenu");
				if (datVGUIMenu == UserMsg:-1)
				{
					SetFailState("The game '%s' doesn't support VGUI menus.", gameDir);
				}
				HookUserMessage(datVGUIMenu, OnVGUIMenu, true, MsgPostHook:-1);
				AddCommandListener(ClosedMOTD, "closed_htmlpage");
				HookEventEx("player_transitioned", Event_PlayerTransitioned, EventHookMode:1);
				AutoExecConfig(true, "", "sourcemod");
				LoadWhitelist();
				if (LateLoad)
				{
					new i = 1;
					while (i <= MaxClients)
					{
						if (IsClientInGame(i))
						{
							g_lastView[i] = GetTime({0,0});
						}
						i++;
					}
				}
				GetIP();
				return void:0;
			}
		}
	}
	new bool:exists;
	GetGameFolderName(gameDir, 255);
	new i;
	while (i < 11)
	{
		if (StrEqual(g_GamesSupported[i], gameDir, true))
		{
			exists = true;
			if (!exists)
			{
				SetFailState("The game '%s' isn't currently supported by the MOTDgd plugin!", gameDir);
			}
			exists = false;
			CreateConVar("sm_motdgd_version", "2.4.87", "[SM] MOTDgd Plugin Version", 131328, false, 0.0, false, 0.0);
			g_motdID = CreateConVar("sm_motdgd_userid", "0", "MOTDgd User ID. This number can be found at: http://motdgd.com/portal/", 256, false, 0.0, false, 0.0);
			g_immunity = CreateConVar("sm_motdgd_immunity", "0", "Enable/Disable advert immunity", 0, false, 0.0, false, 0.0);
			g_OnConnect = CreateConVar("sm_motdgd_onconnect", "1", "Enable/Disable advert on connect", 0, false, 0.0, false, 0.0);
			if (!StrEqual(gameDir, "tf", true))
			{
				g_autoClose = CreateConVar("sm_motdgd_auto_close", "0.0", "Set time (in seconds) to automatically close the MOTD window.", 0, true, 50.0, false, 0.0);
			}
			g_ipOverride = CreateConVar("sm_motdgd_ip", "", "Your server IP. Use this if your server IP is not identified properly automatically.", 0, false, 0.0, false, 0.0);
			new var1;
			if (!StrEqual(gameDir, "left4dead2", true) && !StrEqual(gameDir, "left4dead", true))
			{
				HookEventEx("arena_win_panel", Event_End, EventHookMode:1);
				HookEventEx("cs_win_panel_round", Event_End, EventHookMode:1);
				HookEventEx("dod_round_win", Event_End, EventHookMode:1);
				HookEventEx("player_death", Event_Death, EventHookMode:1);
				HookEventEx("round_start", Event_Start, EventHookMode:1);
				HookEventEx("round_win", Event_End, EventHookMode:1);
				HookEventEx("teamplay_win_panel", Event_End, EventHookMode:1);
				g_OnOther = CreateConVar("sm_motdgd_onother", "2", "Set 0 to disable, 1 to show on round end, 2 to show on player death, 4 to show on round start, 3=1+2, 5=1+4, 6=2+4, 7=1+2+4", 0, false, 0.0, false, 0.0);
				g_Review = CreateConVar("sm_motdgd_review", "15.0", "Set time (in minutes) to re-display the ad. ConVar sm_motdgd_onother must be configured", 0, true, 15.0, false, 0.0);
			}
			new var2;
			if (!StrEqual(gameDir, "left4dead2", true) && !StrEqual(gameDir, "left4dead", true) && !StrEqual(gameDir, "csgo", true))
			{
				g_forced = CreateConVar("sm_motdgd_forced_duration", "5", "Number of seconds to force an ad view for (except in CS:GO, L4D, L4D2)", 0, false, 0.0, false, 0.0);
			}
			new UserMsg:datVGUIMenu = GetUserMessageId("VGUIMenu");
			if (datVGUIMenu == UserMsg:-1)
			{
				SetFailState("The game '%s' doesn't support VGUI menus.", gameDir);
			}
			HookUserMessage(datVGUIMenu, OnVGUIMenu, true, MsgPostHook:-1);
			AddCommandListener(ClosedMOTD, "closed_htmlpage");
			HookEventEx("player_transitioned", Event_PlayerTransitioned, EventHookMode:1);
			AutoExecConfig(true, "", "sourcemod");
			LoadWhitelist();
			if (LateLoad)
			{
				new i = 1;
				while (i <= MaxClients)
				{
					if (IsClientInGame(i))
					{
						g_lastView[i] = GetTime({0,0});
					}
					i++;
				}
			}
			GetIP();
			return void:0;
		}
		i++;
	}
	if (!exists)
	{
		SetFailState("The game '%s' isn't currently supported by the MOTDgd plugin!", gameDir);
	}
	exists = false;
	CreateConVar("sm_motdgd_version", "2.4.87", "[SM] MOTDgd Plugin Version", 131328, false, 0.0, false, 0.0);
	g_motdID = CreateConVar("sm_motdgd_userid", "0", "MOTDgd User ID. This number can be found at: http://motdgd.com/portal/", 256, false, 0.0, false, 0.0);
	g_immunity = CreateConVar("sm_motdgd_immunity", "0", "Enable/Disable advert immunity", 0, false, 0.0, false, 0.0);
	g_OnConnect = CreateConVar("sm_motdgd_onconnect", "1", "Enable/Disable advert on connect", 0, false, 0.0, false, 0.0);
	if (!StrEqual(gameDir, "tf", true))
	{
		g_autoClose = CreateConVar("sm_motdgd_auto_close", "0.0", "Set time (in seconds) to automatically close the MOTD window.", 0, true, 50.0, false, 0.0);
	}
	g_ipOverride = CreateConVar("sm_motdgd_ip", "", "Your server IP. Use this if your server IP is not identified properly automatically.", 0, false, 0.0, false, 0.0);
	new var1;
	if (!StrEqual(gameDir, "left4dead2", true) && !StrEqual(gameDir, "left4dead", true))
	{
		HookEventEx("arena_win_panel", Event_End, EventHookMode:1);
		HookEventEx("cs_win_panel_round", Event_End, EventHookMode:1);
		HookEventEx("dod_round_win", Event_End, EventHookMode:1);
		HookEventEx("player_death", Event_Death, EventHookMode:1);
		HookEventEx("round_start", Event_Start, EventHookMode:1);
		HookEventEx("round_win", Event_End, EventHookMode:1);
		HookEventEx("teamplay_win_panel", Event_End, EventHookMode:1);
		g_OnOther = CreateConVar("sm_motdgd_onother", "2", "Set 0 to disable, 1 to show on round end, 2 to show on player death, 4 to show on round start, 3=1+2, 5=1+4, 6=2+4, 7=1+2+4", 0, false, 0.0, false, 0.0);
		g_Review = CreateConVar("sm_motdgd_review", "15.0", "Set time (in minutes) to re-display the ad. ConVar sm_motdgd_onother must be configured", 0, true, 15.0, false, 0.0);
	}
	new var2;
	if (!StrEqual(gameDir, "left4dead2", true) && !StrEqual(gameDir, "left4dead", true) && !StrEqual(gameDir, "csgo", true))
	{
		g_forced = CreateConVar("sm_motdgd_forced_duration", "5", "Number of seconds to force an ad view for (except in CS:GO, L4D, L4D2)", 0, false, 0.0, false, 0.0);
	}
	new UserMsg:datVGUIMenu = GetUserMessageId("VGUIMenu");
	if (datVGUIMenu == UserMsg:-1)
	{
		SetFailState("The game '%s' doesn't support VGUI menus.", gameDir);
	}
	HookUserMessage(datVGUIMenu, OnVGUIMenu, true, MsgPostHook:-1);
	AddCommandListener(ClosedMOTD, "closed_htmlpage");
	HookEventEx("player_transitioned", Event_PlayerTransitioned, EventHookMode:1);
	AutoExecConfig(true, "", "sourcemod");
	LoadWhitelist();
	if (LateLoad)
	{
		new i = 1;
		while (i <= MaxClients)
		{
			if (IsClientInGame(i))
			{
				g_lastView[i] = GetTime({0,0});
			}
			i++;
		}
	}
	GetIP();
	return void:0;
}

public void:OnConfigsExecuted()
{
	GetIP();
	return void:0;
}

public void:OnLibraryAdded(String:name[])
{
	if (!(strcmp(name, "SteamWorks", true)))
	{
		GetIP();
	}
	return void:0;
}

public SteamWorks_SteamServersConnected()
{
	GetIP();
	return 0;
}

public bool:IsLocal(ip)
{
	new var1;
	if (167772160 <= 184549375 >= ip || -1408237568 <= -1407188993 >= ip || -1062731776 <= -1062666241 >= ip)
	{
		return true;
	}
	return false;
}

public GetIP()
{
	if (GetIP_Method1())
	{
		return 0;
	}
	if (GetIP_Method2())
	{
		return 0;
	}
	if (GetIP_Method3())
	{
		return 0;
	}
	if (GetIP_Method4())
	{
		return 0;
	}
	return 0;
}

public bool:GetIP_Method1()
{
	new String:tmp[64];
	GetConVarString(g_ipOverride, tmp, 64);
	new idx = StrContains(tmp, ":", true);
	if (idx == -1)
	{
		new Handle:serverPort = FindConVar("hostport");
		if (serverPort)
		{
			g_serverPort = GetConVarInt(serverPort);
		}
		return false;
	}
	else
	{
		tmp[idx] = MissingTAG:0;
		strcopy(g_serverIP, 16, tmp);
		g_serverPort = StringToInt(tmp[idx + 1], 10);
	}
	return strcmp(g_serverIP, "", true) != 0;
}

public bool:GetIP_Method2()
{
	new Handle:serverIP = FindConVar("hostip");
	new Handle:serverPort = FindConVar("hostport");
	new var1;
	if (serverIP && serverPort)
	{
		return false;
	}
	new IP = GetConVarInt(serverIP);
	g_serverPort = GetConVarInt(serverPort);
	Format(g_serverIP, 16, "%d.%d.%d.%d", IP >> 24 & 255, IP >> 16 & 255, IP >> 8 & 255, IP & 255);
	return !IsLocal(IP);
}

public bool:GetIP_Method3()
{
	if (!LibraryExists("SteamWorks"))
	{
		return false;
	}
	new IP = SteamWorks_GetPublicIPCell();
	Format(g_serverIP, 16, "%d.%d.%d.%d", IP >> 24 & 255, IP >> 16 & 255, IP >> 8 & 255, IP & 255);
	return IP != 0;
}

public bool:GetIP_Method4()
{
	return EasyHTTP("http://ipinfo.io/ip", EHTTPMethodInternal:0, Handle:0, EasyHTTPComplete:55, any:0, "");
}

public IPReceived(any:data, String:buffer[], bool:success)
{
	if (!success)
	{
		return 0;
	}
	strcopy(g_serverIP, 16, buffer);
	return 0;
}

public APLRes:AskPluginLoad2(Handle:myself, bool:late, String:error[], err_max)
{
	EasyHTTP_MarkNatives();
	return APLRes:0;
}

public bool:OnClientConnect(client, String:rejectmsg[], maxlen)
{
	VGUICaught[client] = 0;
	g_shownTeamVGUI[client] = 0;
	g_lastView[client] = 0;
	new var1;
	if (!StrEqual(gameDir, "left4dead2", true) && !StrEqual(gameDir, "left4dead", true))
	{
		CanReview = true;
	}
	return true;
}

public void:OnClientPutInServer(client)
{
	new var1;
	if (StrEqual(gameDir, "left4dead2", true) && GetConVarBool(g_OnConnect))
	{
		CreateTimer(0.1, PreMotdTimer, GetClientUserId(client), 0);
	}
	return void:0;
}

public void:OnMapStart()
{
	LoadWhitelist();
	return void:0;
}

public LoadWhitelist()
{
	if (g_Whitelist)
	{
		ClearArray(g_Whitelist);
	}
	else
	{
		g_Whitelist = CreateArray(32, 0);
	}
	new String:Path[256];
	BuildPath(PathType:0, Path, 256, "configs/motdgd_whitelist.cfg");
	new Handle:hFile = OpenFile(Path, "r", false, "GAME");
	if (!hFile)
	{
		return 0;
	}
	new String:SteamID[32];
	while (ReadFileLine(hFile, SteamID, 32))
	{
		PushArrayString(g_Whitelist, SteamID[2]);
	}
	CloseHandle(hFile);
	return 0;
}

public Action:Event_End(Handle:event, String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid", 0));
	new var2;
	if (GetConVarFloat(g_Review) < 15.0 || (g_OnOther && GetConVarInt(g_OnOther) != 1 && GetConVarInt(g_OnOther) != 3 && GetConVarInt(g_OnOther) != 5 && GetConVarInt(g_OnOther) != 7))
	{
		return Action:0;
	}
	new var3;
	if (IsValidClient(client) && CanReview && GetTime({0,0}) - g_lastView[client] >= GetConVarFloat(g_Review) * 60)
	{
		g_lastView[client] = GetTime({0,0});
		CreateTimer(0.1, PreMotdTimer, GetClientUserId(client), 0);
	}
	return Action:0;
}

public Action:Event_Death(Handle:event, String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid", 0));
	if (!client)
	{
		return Action:0;
	}
	CreateTimer(0.5, CheckPlayerDeath, GetClientUserId(client), 0);
	return Action:0;
}

public Action:Event_Start(Handle:event, String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid", 0));
	new var2;
	if (GetConVarFloat(g_Review) < 15.0 || (g_OnOther && GetConVarInt(g_OnOther) != 4 && GetConVarInt(g_OnOther) != 5 && GetConVarInt(g_OnOther) != 6 && GetConVarInt(g_OnOther) != 7))
	{
		return Action:0;
	}
	new var3;
	if (IsValidClient(client) && CanReview && GetTime({0,0}) - g_lastView[client] >= GetConVarFloat(g_Review) * 60)
	{
		g_lastView[client] = GetTime({0,0});
		CreateTimer(0.1, PreMotdTimer, GetClientUserId(client), 0);
	}
	return Action:0;
}

public Action:CheckPlayerDeath(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (!client)
	{
		return Action:4;
	}
	if (!IsValidClient(client))
	{
		return Action:4;
	}
	if (IsPlayerAlive(client))
	{
		return Action:4;
	}
	new var2;
	if (GetConVarFloat(g_Review) < 15.0 || (g_OnOther && GetConVarInt(g_OnOther) != 2 && GetConVarInt(g_OnOther) != 3 && GetConVarInt(g_OnOther) != 6 && GetConVarInt(g_OnOther) != 7))
	{
		return Action:4;
	}
	new var3;
	if (CanReview && GetTime({0,0}) - g_lastView[client] >= GetConVarFloat(g_Review) * 60)
	{
		g_lastView[client] = GetTime({0,0});
		CreateTimer(0.1, PreMotdTimer, GetClientUserId(client), 0);
	}
	return Action:4;
}

public Action:Event_PlayerTransitioned(Handle:event, String:name[], bool:dontBroadcast)
{
	new client = GetClientOfUserId(GetEventInt(event, "userid", 0));
	new var1;
	if (IsValidClient(client) && GetConVarBool(g_OnConnect))
	{
		CreateTimer(0.1, PreMotdTimer, GetClientUserId(client), 0);
	}
	return Action:0;
}

public Action:OnVGUIMenu(UserMsg:msg_id, Handle:bf, players[], playersNum, bool:reliable, bool:init)
{
	if (!playersNum > 0)
	{
		return Action:3;
	}
	new client = players[0];
	new var1;
	if (playersNum > 1 || !IsValidClient(client) || VGUICaught[client] || !GetConVarBool(g_OnConnect))
	{
		return Action:0;
	}
	VGUICaught[client] = 1;
	g_lastView[client] = GetTime({0,0});
	CreateTimer(0.1, PreMotdTimer, GetClientUserId(client), 0);
	return Action:3;
}

public Action:ClosedMOTD(client, String:command[], argc)
{
	if (!IsValidClient(client))
	{
		return Action:3;
	}
	new var1;
	if (g_forced && GetConVarInt(g_forced) && g_lastView[client] && g_lastView[client][GetConVarInt(g_forced)] >= GetTime({0,0}))
	{
		new timeRemaining = g_lastView[client][GetConVarInt(g_forced)] - GetTime({0,0}) + 1;
		if (timeRemaining == 1)
		{
			PrintCenterText(client, "Please wait %i second", timeRemaining);
		}
		else
		{
			PrintCenterText(client, "Please wait %i seconds", timeRemaining);
		}
		if (StrEqual(gameDir, "cstrike", true))
		{
			ShowMOTDScreen(client, "", false);
		}
		else
		{
			ShowMOTDScreen(client, "http://", false);
		}
	}
	else
	{
		new var2;
		if (StrEqual(gameDir, "cstrike", true) || StrEqual(gameDir, "csgo", true) || StrEqual(gameDir, "insurgency", true))
		{
			FakeClientCommand(client, "joingame");
		}
		new var3;
		if (StrEqual(gameDir, "nucleardawn", true) || StrEqual(gameDir, "dod", true))
		{
			ClientCommand(client, "changeteam");
		}
	}
	return Action:3;
}

public Action:PreMotdTimer(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (!client)
	{
		return Action:4;
	}
	if (!IsValidClient(client))
	{
		return Action:4;
	}
	decl String:url[256];
	decl String:steamid[256];
	decl String:name[32];
	decl String:name_encoded[64];
	GetClientName(client, name, 32);
	urlencode(name, name_encoded, 64);
	if (GetClientAuthId(client, AuthIdType:1, steamid, 255, true))
	{
		Format(url, 255, "http://motdgd.com/motd/?user=%d&ip=%s&pt=%d&v=%s&st=%s&gm=%s&name=%s", GetConVarInt(g_motdID), g_serverIP, g_serverPort, "2.4.87", steamid, gameDir, name_encoded);
	}
	else
	{
		Format(url, 255, "http://motdgd.com/motd/?user=%d&ip=%s&pt=%d&v=%s&st=NULL&gm=%s&name=%s", GetConVarInt(g_motdID), g_serverIP, g_serverPort, "2.4.87", gameDir, name_encoded);
	}
	if (FindStringInArray(g_Whitelist, steamid[2]) != -1)
	{
		return Action:4;
	}
	new var1;
	if (g_forced && GetConVarInt(g_forced))
	{
		CreateTimer(0.2, RefreshMotdTimer, userid, 0);
	}
	if (g_autoClose)
	{
		new Float:close = GetConVarFloat(g_autoClose);
		if (close > 0.0)
		{
			CreateTimer(close, AutoCloseTimer, userid, 0);
		}
	}
	ShowMOTDScreen(client, url, false);
	return Action:4;
}

public Action:AutoCloseTimer(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (!client)
	{
		return Action:4;
	}
	ShowMOTDScreen(client, "http://", true);
	ClosedMOTD(client, "", 0);
	return Action:4;
}

public Action:RefreshMotdTimer(Handle:timer, any:userid)
{
	new client = GetClientOfUserId(userid);
	if (!client)
	{
		return Action:4;
	}
	if (!IsValidClient(client))
	{
		return Action:4;
	}
	new var1;
	if (g_forced && GetConVarInt(g_forced) && g_lastView[client] && g_lastView[client][GetConVarInt(g_forced)] >= GetTime({0,0}))
	{
		CreateTimer(0.3, RefreshMotdTimer, userid, 0);
	}
	ShowMOTDScreen(client, "http://", false);
	return Action:4;
}

ShowMOTDScreen(client, String:url[], bool:hidden)
{
	if (!IsValidClient(client))
	{
		return 0;
	}
	new Handle:kv = CreateKeyValues("data", "", "");
	new var1;
	if (StrEqual(gameDir, "left4dead", true) || StrEqual(gameDir, "left4dead2", true))
	{
		KvSetString(kv, "cmd", "closed_htmlpage");
	}
	else
	{
		KvSetNum(kv, "cmd", 5);
	}
	KvSetString(kv, "msg", url);
	KvSetString(kv, "title", "MOTDgd AD");
	KvSetNum(kv, "type", 2);
	ShowVGUIPanel(client, "info", kv, !hidden);
	CloseHandle(kv);
	return 0;
}

bool:IsValidClient(i)
{
	new var1;
	if (!i || !IsClientInGame(i) || IsClientSourceTV(i) || IsClientReplay(i) || IsFakeClient(i) || !IsClientConnected(i))
	{
		return false;
	}
	if (!GetConVarBool(g_immunity))
	{
		return true;
	}
	if (CheckCommandAccess(i, "MOTDGD_Immunity", 1, false))
	{
		return false;
	}
	return true;
}

urlencode(String:sString[], String:sResult[], len)
{
	new String:sHexTable[20] = "0123456789abcdef";
	new from;
	new c;
	new to;
	while (from < len)
	{
		from++;
		c = sString[from];
		if (c)
		{
			if (c == 32)
			{
				to++;
				sResult[to] = MissingTAG:43;
			}
			else
			{
				new var1;
				if ((c < 48 && c != 45 && c != 46) || (c < 65 && c > 57) || (c > 90 && c < 97 && c != 95) || c > 122)
				{
					if (to + 3 > len)
					{
						sResult[to] = MissingTAG:0;
						return 0;
					}
					to++;
					sResult[to] = MissingTAG:37;
					to++;
					sResult[to] = sHexTable[c >>> 4];
					to++;
					sResult[to] = sHexTable[c & 15];
				}
				to++;
				sResult[to] = c;
			}
		}
		to++;
		sResult[to] = c;
		return 0;
	}
	return 0;
}