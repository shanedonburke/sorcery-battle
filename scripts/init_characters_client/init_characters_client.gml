// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function init_characters_client() {
	var num_chars = buffer_read(global.character_init_buffer, buffer_u8);
	show_debug_message(string(num_chars) + " chars to be spawned");
	for (var i = 0; i < num_chars; i++) {
		show_debug_message("Creating character...");
		var steam_id = buffer_read(global.character_init_buffer, buffer_u64);
		ds_map_set(global.steam_id_u16_to_u64, steam_id & 0xffff, steam_id);
		var c_x = buffer_read(global.character_init_buffer, buffer_f32);
		var c_y = buffer_read(global.character_init_buffer, buffer_f32);
		var char_inst = instance_create_depth(c_x, c_y, 0, oWizard);
		char_inst.steam_id = steam_id;
		ds_map_set(global.characters, steam_id, char_inst);
		show_debug_message("Spawned character: x=" + string(c_x));
	}
	global.characters_initialized = true;
	global.character_arr = ds_map_values_to_array(global.characters);
	if (global.network_type == "CLIENT") {
		var send_buf = buffer_create(1, buffer_fixed, 1);
		buffer_write(send_buf, buffer_u8, message_types.LOADED);
		steam_net_packet_send(steam_lobby_get_owner_id(), send_buf, 1, steam_net_packet_type_reliable);
		buffer_delete(send_buf);
	} else {
		global.num_loaded++;
		if (global.num_loaded == steam_lobby_get_member_count()) {
			start_game_server();
		}
	}
}