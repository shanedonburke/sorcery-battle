/// @description Insert description here
// You can write your code in this editor
global.network_type = "CLIENT";
global.my_steam_id = steam_get_user_steam_id();
global.lobby_avatars = ds_list_create();
global.characters_initialized = false;
global.characters = ds_map_create();
global.steam_id_u16_to_u64 = ds_map_create();
global.player_inputs = ds_map_create();
last_update_ms = 0;

//client_socket = network_create_socket(network_socket_udp);
//recv_buffer = buffer_create(16, buffer_grow, 1);

//var send_buffer = buffer_create(1024, buffer_fixed, 1);
//buffer_seek(send_buffer, buffer_seek_start, 0);
//buffer_write(send_buffer, buffer_u8, 0);
//buffer_write(send_buffer, buffer_string, "Hi");
//network_send_udp(client_socket, "127.0.0.1", 27888, send_buffer, buffer_tell(send_buffer));

handle_packet = function(buffer) {
	var msg_type = buffer_read(buffer, buffer_u8);
	switch (msg_type) {
		case message_types.GAME_INIT:
			//var buf_size = buffer_get_size(buffer);
			//global.character_init_buffer = buffer_create(buf_size, buffer_fixed, 1);
			//buffer_copy(buffer, 0, buf_size, global.character_init_buffer, 0);
			global.character_init_buffer = buffer;
			goto_game_room();
			return true;
		case message_types.LOADED:
			start_game_client();
			return true;
		case message_types.CHAR_UPDATE:
			if (!global.characters_initialized) {
				return true;
			}
			var timestamp = buffer_read(buffer, buffer_u32);
			if (timestamp < last_update_ms) {
				return true;
			}
			last_update_ms = timestamp;
			var num_players = buffer_read(buffer, buffer_u8);
			for (var i = 0; i < num_players; i++) {
				var steam_id = ds_map_find_value(
						global.steam_id_u16_to_u64,
						buffer_read(buffer, buffer_u16)
				);
				var char = ds_map_find_value(global.characters, steam_id);
				if (char != undefined) {
					var update = char_update_from_buffer(buffer, steam_id);
					ds_map_set(global.player_inputs, steam_id, update.input);
			
					if (steam_id != global.my_steam_id) {
						var char = ds_map_find_value(global.characters, steam_id);
						char.arm_direction = update.arm_direction;
						char.x = update.x;
						char.y = update.y;
					}
				} else {
					// buffer_seek(buffer, buffer_seek_relative, 12);
					show_debug_message("Undefined character with steam ID: " + string(steam_id));
				}
			}
			return true;
		default:
			show_debug_message("Default case for client packet; message type = " + string(msg_type));
			return false;
	}
}