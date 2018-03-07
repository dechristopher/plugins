/** Double-include prevention */
#if defined _kiwiclantags_included_
  #endinput
#endif
#define _kiwiclantags_included_

/**
 * Check if plugin is using mysql setups (else cfg file).
 * 
 * @return 1 if using mysql, 0 otherwise.
 */
native int KIWIClanTags_UsingMysql();

/**
 * Reloads clan tags plugin.
 * 
 * @return None.
 */
native void KIWIClanTags_Reload();

/**
 * Apply an extra chat tag to the client.
 *
 * @param	client			Client index
 * @param	sExtTag			String to use as tag text
 * 
 * @return true if tags applied successfully.
 * @error if invalid client (not in game or invalid index).
 */
native bool KIWIClanTags_SetExtTag(int client, char[] sExtTag);

/**
 * Notify clan tags plugin to reload.
 * 
 * @param	client			Client index
 *
 * @return true if client tags reloaded successfully.
 * @error if invalid client (not in game or invalid index).
 */
native bool KIWIClanTags_ReloadPlayer(int client);

/**
 * Check if client has a clan tag set through the plugin, either through the main function or by an external plugin using natives.
 * 
 * @param	client			Client index
 *
 * @return true if client has a tag set, false if no tag is set by plugin.
 * @error if invalid client (not in game or invalid index).
 */
native bool KIWIClanTags_HasAnyTag(int client);

/**
 * Check if client has a clan tag set through the main plugin functions.
 * 
 * @param	client			Client index
 *
 * @return true if client has a tag set, false if no tag is set by plugin.
 * @error if invalid client (not in game or invalid index).
 */
native bool KIWIClanTags_HasMainTag(int client);

/**
 * Check if client has a clan tag set through the plugin by an external plugin.
 * 
 * @param	client			Client index
 *
 * @return true if client has a tag set, false if no tag is set by plugin.
 * @error if invalid client (not in game or invalid index).
 */
native bool KIWIClanTags_HasExtTag(int client);

/* 
 * Called on plugin load / reload.
 * 
 * @return	None.
 */ 
//forward void KIWIClanTagsLoaded();

/* 
 * Called when a client finishes loading.
 * 
 * @return	None.
 */ 
//forward void KIWIClanTagsClientLoaded(int client);

public SharedPlugin __pl_kiwiclantags =
{
	name = "kiwiclantags",
	file = "kiwi-clantags.smx",
#if defined REQUIRE_PLUGIN
	required = 1
#else
	required = 0
#endif
};

#if !defined REQUIRE_PLUGIN
public void __pl_kiwiclantags_SetNTVOptional()
{
	MarkNativeAsOptional("KIWIClanTags_SetExtTag");
	MarkNativeAsOptional("KIWIClanTags_Reload");
	MarkNativeAsOptional("KIWIClanTags_ReloadPlayer");
	MarkNativeAsOptional("KIWIClanTags_UsingMysql");
	MarkNativeAsOptional("KIWIClanTags_HasAnyTag");
	MarkNativeAsOptional("KIWIClanTags_HasMainTag");
	MarkNativeAsOptional("KIWIClanTags_HasExtTag");
}
#endif
