/// @description Insert description here
// You can write your code in this editor
switch (async_load[? "event_type"]) {
	case "lobby_join_requested":
		steam_lobby_join_id(steam_id_create(
		    async_load[? "lobby_id_high"],
		    async_load[? "lobby_id_low"]
		));
		break;
    case "lobby_joined":
		show_debug_message("Joined lobby");
		var send_buffer = buffer_create(1024, buffer_fixed, 1);
		buffer_write(send_buffer, buffer_u8, 0);
		buffer_write(send_buffer, buffer_u64, steam_get_user_steam_id());
		steam_net_packet_send(steam_lobby_get_owner_id(), send_buffer, 9, steam_net_packet_type_reliable);
		get_lobby_avatars();
		room_goto(rLobby);
		break;
}