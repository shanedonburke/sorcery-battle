// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function process_packet_client(_async_load, client_socket) {
	var socket = _async_load[? "id"];
	if (socket == client_socket) {
		var buffer = _async_load[? "buffer"];
		var msg_type = buffer_read(buffer, buffer_u8);
	
		switch (msg_type) {
			case 0:
				show_debug_message("Oh no");
				break;
			case 1:
				var player_x = buffer_read(buffer, buffer_s16);
				var player_y = buffer_read(buffer, buffer_s16);
				instance_create_depth(player_x, player_y, 0, oWizard);
				break;
		}	
	}
}