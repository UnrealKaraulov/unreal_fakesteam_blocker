#include <amxmodx>
#include <reapi>

#define _easy_cfg_internal
#include <easy_cfg>

#pragma ctrlchar '\'

new const PLUGIN_VERSION[] = "1.2";
new const PLUGIN_NAME[] = "BLOCK FAKE STEAMID";
new const PLUGIN_AUTHOR[] = "Karaulov";

new QueryFileHook:g_hFiles[2];
new bool:g_bIsUserSteam[MAX_PLAYERS + 1];

new g_sClientDropString[MAX_PLAYERS + 1][256];
new g_sFakeSteamBanString[256] = "amx_ban #[userid] 1000 'Fake Steam client emulator detected'";
new g_sFakeSteamHelloString[256] = "User '[username]' join with FakeSteam client";
new g_sFakeSteamDropString[256] = "Please close Steam or use original Steam cs 1.6 client";
new g_sFakeNoSteamBanString[256] = "amx_ban #[userid] 1000 'SteamID Changer detected'";
new g_sFakeNoSteamHelloString[256] = "User '[username]' join with SteamID Changer";
new g_sFakeNoSteamDropString[256] = "Please remove SteamID Changer and use original Steam cs 1.6 client";



public plugin_precache()
{
	register_plugin(PLUGIN_NAME, PLUGIN_VERSION, PLUGIN_AUTHOR);
	create_cvar("no_fake_steamid", PLUGIN_VERSION, FCVAR_SERVER | FCVAR_SPONLY);

	cfg_set_path("plugins/unreal_nosteam_blocker.cfg");
	
	new tmp_cfgdir[512];
	cfg_get_path(tmp_cfgdir,charsmax(tmp_cfgdir));
	trim_to_dir(tmp_cfgdir);

	if (!dir_exists(tmp_cfgdir))
	{
		log_amx("Warning config dir not found: %s",tmp_cfgdir);
		if (mkdir(tmp_cfgdir) < 0)
		{
			log_error(AMX_ERR_NOTFOUND, "Can't create %s dir",tmp_cfgdir);
			set_fail_state("Fail while create %s dir",tmp_cfgdir);
			return;
		}
		else 
		{
			log_amx("Config dir %s created!",tmp_cfgdir);
		}
	}

	new bool:tmpBool = false;
	cfg_read_bool("general", "ban_fake_steam", tmpBool, tmpBool);
	cfg_read_str("general", "ban_fake_steam_string", g_sFakeSteamBanString, g_sFakeSteamBanString, charsmax(g_sFakeSteamBanString));

	if (!tmpBool)
	{
		g_sFakeSteamBanString[0] = EOS;
	}

	tmpBool = false;
	cfg_read_bool("general", "drop_fake_steam", tmpBool, tmpBool);
	cfg_read_str("general", "drop_fake_steam_string", g_sFakeSteamDropString, g_sFakeSteamDropString, charsmax(g_sFakeSteamDropString));
	if (!tmpBool) 
	{
		g_sFakeSteamDropString[0] = EOS;
	}

	tmpBool = true;
	cfg_read_bool("general", "hello_fake_steam", tmpBool, tmpBool);
	cfg_read_str("general", "hello_fake_steam_string", g_sFakeSteamHelloString, g_sFakeSteamHelloString, charsmax(g_sFakeSteamHelloString));
	if (!tmpBool) 
	{
		g_sFakeSteamHelloString[0] = EOS;
	}

	tmpBool = true;
	cfg_read_bool("general", "ban_fake_nosteam", tmpBool, tmpBool);
	cfg_read_str("general", "ban_fake_nosteam_string", g_sFakeNoSteamBanString, g_sFakeNoSteamBanString, charsmax(g_sFakeNoSteamBanString));
	if (!tmpBool) 
	{
		g_sFakeNoSteamBanString[0] = EOS;
	}

	tmpBool = true;
	cfg_read_bool("general", "drop_fake_nosteam", tmpBool, tmpBool);
	cfg_read_str("general", "drop_fake_nosteam_string", g_sFakeNoSteamDropString, g_sFakeNoSteamDropString, charsmax(g_sFakeNoSteamDropString));
	if (!tmpBool) 
	{
		g_sFakeNoSteamDropString[0] = EOS;
	}

	tmpBool = true;
	cfg_read_bool("general", "hello_fake_nosteam", tmpBool, tmpBool);
	cfg_read_str("general", "hello_fake_nosteam_string", g_sFakeNoSteamHelloString, g_sFakeNoSteamHelloString, charsmax(g_sFakeNoSteamHelloString));
	if (!tmpBool) 
	{
		g_sFakeNoSteamHelloString[0] = EOS;
	}


	g_hFiles[0] = RegisterQueryFile("./../../../appmanifest_10.acf", "steam_found", RES_TYPE_HASH_ANY);
	g_hFiles[1] = RegisterQueryFile("./../../../appmanifest_10.acf", "steam_not_found", RES_TYPE_MISSING);
}

public plugin_end()
{
	UnRegisterQueryFile(g_hFiles[0]);
	UnRegisterQueryFile(g_hFiles[1]);
}

public client_authorized(id)
{
	g_bIsUserSteam[id] = is_user_steam(id);
}

public client_disconnected(id)
{
	remove_task(id);
}

public steam_found(const id) 
{
	if (!g_bIsUserSteam[id])
	{
		static banstr[256];

		new userid[16];
		formatex(userid, charsmax(userid), "%i", get_user_userid(id));
		new username[33];
		get_user_name(id, username, charsmax(username));
		new userip[16];
		get_user_ip(id, userip, charsmax(userip), true);
		new userauth[64];
		get_user_authid(id, userauth, charsmax(userauth));
		log_to_file("unreal_fakesteamid_detector.log", "[LOG] User %s [steamid: %s] [ip: %s] [id: %s] connected with SteamId Changer", username, userid, userip, userid);
		
		if (g_sFakeNoSteamHelloString[0] != EOS)
		{
			copy(banstr,charsmax(banstr), g_sFakeNoSteamHelloString);
			replace_all(banstr,charsmax(banstr),"[userid]",userid);
			replace_all(banstr,charsmax(banstr),"[username]",username);
			replace_all(banstr,charsmax(banstr),"[ip]",userip);
			replace_all(banstr,charsmax(banstr),"[steamid]",userauth);
			fix_colors(banstr, charsmax(banstr));
			client_print_color(0, print_team_red, "%s", banstr);
		}

		if (g_sFakeNoSteamBanString[0] != EOS)
		{
			copy(banstr,charsmax(banstr), g_sFakeNoSteamBanString);
			replace_all(banstr,charsmax(banstr),"[userid]",userid);
			replace_all(banstr,charsmax(banstr),"[username]",username);
			replace_all(banstr,charsmax(banstr),"[ip]",userip);
			replace_all(banstr,charsmax(banstr),"[steamid]",userauth);
			server_cmd("%s", banstr);
			log_to_file("unreal_fakesteamid_detector.log", "[BAN] %s", banstr);
		}

		if (g_sFakeNoSteamDropString[0] != EOS)
		{
			copy(g_sClientDropString[id],charsmax(g_sClientDropString[]), g_sFakeNoSteamDropString);
			replace_all(g_sClientDropString[id],charsmax(g_sClientDropString[]),"[userid]",userid);
			replace_all(g_sClientDropString[id],charsmax(g_sClientDropString[]),"[username]",username);
			replace_all(g_sClientDropString[id],charsmax(g_sClientDropString[]),"[ip]",userip);
			replace_all(g_sClientDropString[id],charsmax(g_sClientDropString[]),"[steamid]",userauth);
			set_task(0.1, "drop_client_delayed", id);
			log_to_file("unreal_fakesteamid_detector.log", "[DROP] %s", g_sClientDropString[id]);
		}
	}
}

public steam_not_found(const id) 
{
	if (g_bIsUserSteam[id])
	{
		static banstr[256];

		new userid[16];
		formatex(userid, charsmax(userid), "%i", get_user_userid(id));
		new username[33];
		get_user_name(id, username, charsmax(username));
		new userip[16];
		get_user_ip(id, userip, charsmax(userip), true);
		new userauth[64];
		get_user_authid(id, userauth, charsmax(userauth));
		log_to_file("unreal_fakesteamid_detector.log", "[LOG] User %s [steamid: %s] [ip: %s] [id: %s] connected with FakeSteam client(emulate Steam)", username, userauth, userip, userid);
		
		if (g_sFakeSteamHelloString[0] != EOS)
		{
			copy(banstr,charsmax(banstr), g_sFakeSteamHelloString);
			replace_all(banstr,charsmax(banstr),"[userid]",userid);
			replace_all(banstr,charsmax(banstr),"[username]",username);
			replace_all(banstr,charsmax(banstr),"[ip]",userip);
			replace_all(banstr,charsmax(banstr),"[steamid]",userauth);
			fix_colors(banstr, charsmax(banstr));
			client_print_color(0, print_team_red, "%s", banstr);
		}

		if (g_sFakeSteamBanString[0] != EOS)
		{
			copy(banstr,charsmax(banstr), g_sFakeSteamBanString);
			replace_all(banstr,charsmax(banstr),"[userid]",userid);
			replace_all(banstr,charsmax(banstr),"[username]",username);
			replace_all(banstr,charsmax(banstr),"[ip]",userip);
			replace_all(banstr,charsmax(banstr),"[steamid]",userauth);
			server_cmd("%s", banstr);
			log_to_file("[BAN] %s", banstr);
		}

		if (g_sFakeSteamDropString[0] != EOS)
		{
			copy(g_sClientDropString[id],charsmax(g_sClientDropString[]), g_sFakeSteamDropString);
			replace_all(g_sClientDropString[id],charsmax(g_sClientDropString[]),"[userid]",userid);
			replace_all(g_sClientDropString[id],charsmax(g_sClientDropString[]),"[username]",username);
			replace_all(g_sClientDropString[id],charsmax(g_sClientDropString[]),"[ip]",userip);
			replace_all(g_sClientDropString[id],charsmax(g_sClientDropString[]),"[steamid]",userauth);
			set_task(0.1, "drop_client_delayed", id);
			log_to_file("unreal_fakesteamid_detector.log", "[DROP] %s", g_sClientDropString[id]);
		}
	}
}


public drop_client_delayed(id)
{
	if (is_user_connected(id))
	{
		static cheat[64];
		formatex(cheat, charsmax(cheat), "Error: %s", g_sClientDropString[id]);
		rh_drop_client(id, cheat);
	}
}


stock trim_to_dir(path[])
{
	new len = strlen(path);
	len--;
	for(; len >= 0; len--)
	{
		if(path[len] == '/' || path[len] == '\\')
		{
			path[len] = EOS;
			break;
		}
	}
}

stock fix_colors(str[], len)
{
	replace_all(str, len, "^1", "\x01");
	replace_all(str, len, "^2", "\x02");
	replace_all(str, len, "^3", "\x03");
	replace_all(str, len, "^4", "\x04");
}