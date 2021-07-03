/// @description Insert description here
// You can write your code in this editor

key_left = 0;
key_right = 0;
key_jump = 0;
lmb_pressed = 0;

var is_me = id == ds_map_find_value(global.characters, global.my_steam_id);

if (is_me) {
	// Is my character (server or client)
	key_left = keyboard_check(vk_left) || keyboard_check(ord("A"));
	key_right = keyboard_check(vk_right) || keyboard_check(ord("D"));
	key_jump = keyboard_check(vk_space) || keyboard_check(ord("W"));
	lmb_pressed = mouse_check_button_pressed(mb_left);
	arm_direction =  point_direction(arm_x, arm_y, mouse_x, mouse_y);
} else if (ds_map_exists(global.player_inputs, steam_id)) {
	//show_debug_message("Have input");
	var input = ds_map_find_value(global.player_inputs, steam_id);
	key_left = input & 0x1;
	key_right = (input >> 0x1) & 0x1;
	key_jump = (input >> 0x2) & 1;
	lmb_pressed = (input >> 0x3) & 0x1;
}
	
var old_x = x;
var old_y = y;
	
var _move = key_right - key_left;

hsp = 2 * _move;
vsp = vsp + 0.5;


if (place_meeting(x, y + 1, oStatic) && key_jump) {
	vsp = vsp - 7.5;	
}

if (place_meeting(x + hsp, y, oStatic)) {
	while (!place_meeting(x + sign(hsp), y, oStatic)) {
		x = x + sign(hsp);
		hsp = 0;
	}
}
x = x + hsp;

image_xscale = (arm_direction > 270 || arm_direction <= 90) ? 1 : -1;

if (place_meeting(x, y + vsp, oStatic)) {
	while (!place_meeting(x, y + sign(vsp), oStatic)) {
		y = y + sign(vsp);
	}
	vsp = 0;
}
y = y + vsp;

arm_x = x + (3 * image_xscale);
arm_y = y - 14;

if (lmb_pressed) {
	var bubble = instance_create_depth(arm_x + lengthdir_x(sprite_get_width(sWizard_Arm), arm_direction), arm_y + lengthdir_y(sprite_get_width(sWizard_Arm), arm_direction), -1, oMagicBubble);
	bubble.direction = arm_direction;
	bubble.speed = 2;
}

var input = 0;
input |= key_left;
input |= key_right << 0x1;
input |= key_jump << 0x2;
input |= lmb_pressed << 0x3;

if (is_me && global.network_type == "CLIENT") {
	buffer_seek(send_buffer, buffer_seek_start, 0);
	buffer_write(send_buffer, buffer_u8, 3);
	new character_update(input, arm_direction, old_x, old_y).write_to_buffer(send_buffer);
	steam_net_packet_send(steam_lobby_get_owner_id(), send_buffer, 12, steam_net_packet_type_unreliable);	
	// steam_net_packet_send(steam_lobby_get_owner_id(), send_buffer, 12, steam_net_packet_type_reliable);
} else if (global.network_type == "SERVER") {
	ds_map_set(global.player_inputs, global.my_steam_id, input);
	ds_map_set(global.character_updates, steam_id, new character_update(input, arm_direction, old_x, old_y));
}

