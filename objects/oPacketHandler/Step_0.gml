/// @description Insert description here
// You can write your code in this editor
steam_gml_update();

//if (variable_global_exists("player_inputs")) {
//	ds_map_clear(global.player_inputs);
//}

while (steam_net_packet_receive()) {
	var recv_buffer = buffer_create(16, buffer_grow, 1);
	steam_net_packet_get_data(recv_buffer);
	buffer_seek(recv_buffer, buffer_seek_start, 0);
	switch (global.network_type) {
		case "SERVER":
			global.server.handle_packet(recv_buffer);
			break;
		case "CLIENT":
			global.client.handle_packet(recv_buffer);
			break;
	}
}

if (global.characters_initialized) {
	for (var i = 0; i < array_length(global.character_arr); i++) {
		global.character_arr[i].update();
	}
}

if (room == rGame && (!variable_global_exists("characters_initialized") || !global.characters_initialized)) {
	global.characters_initialized = false;
	init_characters_client();
}

if (global.network_type == "SERVER") {
	global.server.update();	
}