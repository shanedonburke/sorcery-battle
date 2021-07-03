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
		ds_map_add(global.characters, steam_id, char_inst);
		show_debug_message("Spawned character: x=" + string(c_x));
	}
	global.characters_initialized = true;
}