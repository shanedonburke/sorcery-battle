/// @description Insert description here
// You can write your code in this editor

hp = 20;

hsp = 0;
vsp = 0;

arm_direction = 0;
arm_x = x;
arm_y = y;

send_buffer = buffer_create(16, buffer_grow, 1);
steam_id = -1;
charge_frames = 0;
orb = undefined;
mirror = undefined;
next_orb_id = 0;

spawn_orb = function() {
	orb = instance_create_depth(
		arm_x + lengthdir_x(sprite_get_width(sWizard_Arm), arm_direction),
		arm_y + lengthdir_y(sprite_get_width(sWizard_Arm), arm_direction),
		-1,
		oWizardOrb
	);
}

release_orb = function(orb_id) {
	if (is_undefined(orb)) {
		spawn_orb();
	}
	orb.direction = arm_direction;
	orb.speed = 2;
	orb.stop_animation();
	global.transients[? steam_id][? transient_types.ORB][? orb_id] = orb;
	var old_orb = orb;
	orb = undefined;
	charge_frames = 0;
	next_orb_id = (orb_id + 1) % 256;
	return old_orb;
}

spawn_mirror = function() {
	mirror = instance_create_depth(
		arm_x + lengthdir_x(sprite_get_width(sWizard_Arm) + 5, arm_direction),
		arm_y + lengthdir_y(sprite_get_width(sWizard_Arm) + 5, arm_direction),
		-1,
		oMirror
	);	
}

update = function() {
	key_left = 0;
	key_right = 0;
	key_jump = 0;
	lmb_pressed = 0;
	mmb_pressed = 0;

	var is_me = id == ds_map_find_value(global.characters, global.my_steam_id);

	if (is_me) {
		// Is my character (server or client)
		key_left = keyboard_check(vk_left) || keyboard_check(ord("A"));
		key_right = keyboard_check(vk_right) || keyboard_check(ord("D"));
		key_jump = keyboard_check(vk_space) || keyboard_check(ord("W"));
		lmb_pressed = mouse_check_button(mb_left);
		mmb_pressed = mouse_check_button(mb_middle);
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
	
	var grounded = place_meeting(x, y + 1, oStatic);

	if (grounded && key_jump) {
		vsp = vsp - 7.5;	
	}
	
	if (sprite_index == sWizard && grounded && _move != 0) {
		sprite_index = sWizard_Walking;	
	} else if (sprite_index == sWizard_Walking && !(grounded && _move != 0)) {
		sprite_index = sWizard;	
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
	
	if (sprite_index == sWizard_Walking) {
		var idx_floor = floor(image_index);
		if (idx_floor == 1 || idx_floor == 3) {
			arm_y += 1;
		} else if (idx_floor == 2) {
			arm_y += 2;	
		}
	}
	
	if (is_me) {
		arm_direction =  point_direction(arm_x, arm_y, mouse_x, mouse_y);	
	}

	if (lmb_pressed) {
		if (charge_frames == 0) {
			spawn_orb();
		} else {
			orb.x = arm_x + lengthdir_x(sprite_get_width(sWizard_Arm), arm_direction);
			orb.y = arm_y + lengthdir_y(sprite_get_width(sWizard_Arm), arm_direction);
		}
		charge_frames = 1;
	} else if (charge_frames > 0 && global.network_type == "SERVER") {
		release_orb(next_orb_id);
	}
	
	if (is_undefined(mirror) && mmb_pressed) {
		spawn_mirror();
		mirror.image_angle = arm_direction;
	} if (!is_undefined(mirror) && mmb_pressed) {
		var diff_x = mouse_x - mirror.x;
		var diff_y = mouse_y - mirror.y;
		var mag = sqrt(sqr(diff_x) + sqr(diff_y));
		diff_x = diff_x / mag * 0.2;
		diff_y = diff_y / mag * 0.2;
		mirror.x += diff_x;
		mirror.y += diff_y;
		if (mouse_x != last_mouse_x || mouse_y != last_mouse_y) {
			var target_angle = point_direction(mirror.x, mirror.y, mouse_x, mouse_y);
			var angle_diff = angle_difference(mirror.image_angle, target_angle);
			mirror.image_angle -= sign(angle_diff) * min(abs(angle_diff), 3);
		}
	}
	
	var input = 0;
	input |= key_left;
	input |= key_right << 0x1;
	input |= key_jump << 0x2;
	input |= lmb_pressed << 0x3;

	if (is_me && global.network_type == "CLIENT") {
		buffer_seek(send_buffer, buffer_seek_start, 0);
		buffer_write(send_buffer, buffer_u8, message_types.CHAR_UPDATE);
		new character_update(input, arm_direction, old_x, old_y).write_to_buffer(steam_id, send_buffer);
		steam_net_packet_send(steam_lobby_get_owner_id(), send_buffer, 12, steam_net_packet_type_unreliable);	
		// steam_net_packet_send(steam_lobby_get_owner_id(), send_buffer, 12, steam_net_packet_type_reliable);
	} else if (global.network_type == "SERVER") {
		ds_map_set(global.player_inputs, global.my_steam_id, input);
		ds_map_set(global.character_updates, steam_id, new character_update(input, arm_direction, old_x, old_y));
	}
	
	last_mouse_x = mouse_x;
	last_mouse_y = mouse_y;
	global.transients[? steam_id][? transient_types.MIRROR] = mirror;
}