/// @description Insert description here
// You can write your code in this editor
global.network_type = "CLIENT";
global.my_steam_id = steam_get_user_steam_id();
global.lobby_avatars = ds_list_create();
global.characters_initialized = false;
global.characters = ds_map_create();
global.steam_id_u16_to_u64 = ds_map_create();
global.player_inputs = ds_map_create();

//client_socket = network_create_socket(network_socket_udp);
//recv_buffer = buffer_create(16, buffer_grow, 1);

//var send_buffer = buffer_create(1024, buffer_fixed, 1);
//buffer_seek(send_buffer, buffer_seek_start, 0);
//buffer_write(send_buffer, buffer_u8, 0);
//buffer_write(send_buffer, buffer_string, "Hi");
//network_send_udp(client_socket, "127.0.0.1", 27888, send_buffer, buffer_tell(send_buffer));

handle_packet = function(buffer) {
	//show_debug_message(buffer);
	var msg_type = buffer_read(buffer, buffer_u8);
	switch (msg_type) {
		case 1:
			//start_game_client();
			return true;
		case 2:
			global.character_init_buffer = buffer;
			start_game_client();
			return true;
		case 3:
			if (!global.characters_initialized) {
				return true;	
			}
			var num_players = buffer_read(buffer, buffer_u8);
			//show_debug_message("Num characters = " + string(ds_map_size(global.characters)));
			for (var i = 0; i < num_players; i++) {
				var steam_id_low = buffer_read(buffer, buffer_u16);
				var steam_id = ds_map_find_value(
						global.steam_id_u16_to_u64,
						steam_id_low
				);
				//show_debug_message(string(steam_id_low));
				if (steam_id != global.my_steam_id) {
					var char = ds_map_find_value(global.characters, steam_id);
					if (char != undefined) {
						show_debug_message("Char defined");
						ds_map_set(global.player_inputs, steam_id, buffer_read(buffer, buffer_u8));
						char.x = buffer_read(buffer, buffer_f32);
						char.y = buffer_read(buffer, buffer_f32);
						// show_debug_message(string(char.x) + ", " + string(char.y));
						char.arm_direction = buffer_read(buffer, buffer_u16);
					} else {
						//buffer_seek(buffer, buffer_seek_relative, 12);
						//buffer_read(buffer, buffer_u8);
						//buffer_read(buffer, buffer_f32);
						//buffer_read(buffer, buffer_f32);
						//buffer_read(buffer, buffer_u16);
					}
				} else {
					//buffer_read(buffer, buffer_u8);
					//buffer_read(buffer, buffer_f32);
					//buffer_read(buffer, buffer_f32);
					//buffer_read(buffer, buffer_u16);
					buffer_seek(buffer, buffer_seek_start, 16);
				}
			}
			return true;
		default:
			show_debug_message("Default case for client packet; message type = " + string(msg_type));
			return false;
	}
}