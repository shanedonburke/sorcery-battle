/// @description Insert description here
// You can write your code in this editor
var send_buffer = buffer_create(1, buffer_fixed, 1);
//buffer_write(send_buffer, buffer_u8, 1);

var num_members = steam_lobby_get_member_count();
//for (var i = 0; i < num_members; ++i) {
//    var steam_id = steam_lobby_get_member_id(i);
//	if (steam_id != steam_get_user_steam_id()) {
//		steam_net_packet_send(steam_id, send_buffer, 1, steam_net_packet_type_reliable);
//	}
//}

var send_buffer = buffer_create(2 + num_members * 16, buffer_fixed, 1);
buffer_write(send_buffer, buffer_u8, 2);
buffer_write(send_buffer, buffer_u8, num_members);
for (var i = 0; i < num_members; ++i) {
	buffer_write(send_buffer, buffer_u64, steam_lobby_get_member_id(i));
	buffer_write(send_buffer, buffer_f32, 200 + 10 * i);
	buffer_write(send_buffer, buffer_f32, 170);
}
//buffer_write(send_buffer, buffer_u8, 2);
for (var i = 0; i < num_members; ++i) {
	var steam_id = steam_lobby_get_member_id(i);
	if (steam_id != steam_get_user_steam_id()) {
		steam_net_packet_send(steam_id, send_buffer, 2 + num_members * 16, steam_net_packet_type_reliable);
	}
}
buffer_seek(send_buffer, buffer_seek_start, 1);
global.character_init_buffer = send_buffer;

start_game_client();