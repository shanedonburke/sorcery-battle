/// @description Insert description here
// You can write your code in this editor
//clients = ds_list_create();
//server_socket = network_create_socket_ext(network_socket_udp, 27888);

// instance_create_depth(0, 0, 0, oClient);

steam_lobby_create(steam_lobby_type_public, 4);

send_buffer = buffer_create(16, buffer_grow, 1);
//global.player_positions = ds_map_create();

//process_packet_server = function(_async_load) {
//	var remote_port = _async_load[? "port"];
//	var remote_ip = string(_async_load[? "ip"]);
	
//	var buffer = _async_load[? "buffer"];
//	buffer_seek(buffer, buffer_seek_start, 0);
//	var msg_type = buffer_read(buffer, buffer_u8);
	
//	switch (msg_type) {
//		case 0:
//			ds_list_add(clients, [remote_ip, remote_port]);
//			var msg = buffer_read(buffer, buffer_string);
//			show_debug_message(msg);
//			// var new_player = instance_create_depth(200, 170, 0, oWizard);
			
//			var send_buffer = buffer_create(1024, buffer_fixed, 1);
//			buffer_seek(send_buffer, buffer_seek_start, 0);
//			buffer_write(send_buffer, buffer_u8, 1);
//			buffer_write(send_buffer, buffer_s16, 200);
//			buffer_write(send_buffer, buffer_s16, 170);
//			for (var i = 0; i < ds_list_size(clients); i += 1) {
//				var client = ds_list_find_value(clients, i);
//				network_send_udp(server_socket, client[0], client[1], send_buffer, buffer_tell(send_buffer));
//			}
//			break;
//	}
//}

handle_packet = function(buffer) {
	switch (buffer_read(buffer, buffer_u8)) {
		case 0:
			// var steam_id = buffer_read(recv_buffer, buffer_u64);
			get_lobby_avatars();
			return true;
		case 3:
			var steam_id = steam_net_packet_get_sender_id();
			var char = ds_map_find_value(global.characters, steam_id);
			ds_map_set(global.player_inputs, steam_id, buffer_read(buffer, buffer_u8));
			char.arm_direction = buffer_read(buffer, buffer_u16);
			char.x = buffer_read(buffer, buffer_f32);
			char.y = buffer_read(buffer, buffer_f32);
			break;
		default:
			return false;
	}
}

update = function() {
	if (global.characters_initialized) {
		var num_chars = ds_map_size(global.characters);
		if (num_chars > 0) {
			buffer_seek(send_buffer, buffer_seek_start, 0);
			buffer_write(send_buffer, buffer_u8, 3);
			buffer_write(send_buffer, buffer_u8, num_chars);
			var steam_id = ds_map_find_first(global.characters);
			for (var i = 0; i < num_chars; i++) {
				var char = ds_map_find_value(global.characters, steam_id);
				buffer_write(send_buffer, buffer_u16, steam_id & 0xffff);
				buffer_write(send_buffer, buffer_u8, ds_map_find_value(global.player_inputs, steam_id) || 0);
				buffer_write(send_buffer, buffer_f32, char.x);
				buffer_write(send_buffer, buffer_f32, char.y);
				buffer_write(send_buffer, buffer_u16, char.arm_direction);
				steam_id = ds_map_find_next(global.characters, steam_id);
			}
			for (var i = 0; i < num_chars; i++) {
				var steam_id = steam_lobby_get_member_id(i);
				if (steam_id != global.my_steam_id) {
					steam_net_packet_send(steam_id, send_buffer, 2 + (13 * num_chars), steam_net_packet_type_unreliable);
					//steam_net_packet_send(steam_id, send_buffer, 2 + (13 * num_chars), steam_net_packet_type_reliable);
				}
			}
		}	
	}
}