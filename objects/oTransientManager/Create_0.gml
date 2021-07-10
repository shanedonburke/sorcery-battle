/// @description Insert description here
// You can write your code in this editor

global.transients = ds_map_create();
for (var i = 0; i < steam_lobby_get_member_count(); i++) {
	var steam_id = steam_lobby_get_member_id(i);
	var player_map = ds_map_create();
	ds_map_set(player_map, transient_types.ORB, ds_map_create());
	ds_map_set(player_map, transient_types.MIRROR, undefined);
	ds_map_set(global.transients, steam_id, player_map);
}