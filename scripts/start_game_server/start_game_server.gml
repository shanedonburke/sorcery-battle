// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function start_game_server(){
	var buf = buffer_create(1, buffer_fixed, 1);
	buffer_write(buf, buffer_u8, message_types.LOADED);
	for (var i = 0; i < steam_lobby_get_member_count(); i++) {
		var steam_id = steam_lobby_get_member_id(i);
		if (steam_id != global.my_steam_id) {
			steam_net_packet_send(steam_id, buf, 1, steam_net_packet_type_reliable);	
		}
	}
	buffer_delete(buf);
	start_game_client();
}