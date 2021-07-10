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
grounded = false;

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
	if (global.network_type == "SERVER") {
		orb.direction = arm_direction;
		orb.speed = 2;
	}
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
		arm_x + lengthdir_x(sprite_get_width(sWizard_Arm) + 25, arm_direction),
		arm_y + lengthdir_y(sprite_get_width(sWizard_Arm) + 25, arm_direction),
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
		var input = global.player_inputs[? steam_id];
		key_left = input & 0x1;
		key_right = (input >> 0x1) & 0x1;
		key_jump = (input >> 0x2) & 0x1;
		lmb_pressed = (input >> 0x3) & 0x1;
		mmb_pressed = (input >> 0x4) & 0x1;
	}
	
	var old_x = x;
	var old_y = y;
	
	var _move = key_right - key_left;

	hsp = 10 * _move;
	vsp = vsp + 2.5;
	
	if (sprite_index == sWizard && grounded && _move != 0) {
		sprite_index = sWizard_Walking;	
	} else if (sprite_index == sWizard_Walking && !(grounded && _move != 0)) {
		sprite_index = sWizard;	
	}
	
	if (grounded && key_jump) {
		vsp = -38;	
	}
	
	repeat(abs(vsp)) {
		if (!place_meeting(x, y + sign(vsp), oBlocking)) {
			y += sign(vsp);	
		} else {
			vsp = 0;
			break;
		}
	}

	repeat(abs(hsp)) {
		if (
			place_meeting(x + sign(hsp), y, oBlocking) &&
			place_meeting(x + sign(hsp), y - 1, oBlocking) &&
			!place_meeting(x + sign(hsp), y - 2, oBlocking)
		) {
			y -= 2;
		} else if (
			place_meeting(x + sign(hsp), y, oBlocking) &&
			!place_meeting(x + sign(hsp), y - 1, oBlocking)
		) {
			y--;
		}
				
		if (
			!place_meeting(x + sign(hsp), y, oBlocking) &&
			!place_meeting(x + sign(hsp), y + 1, oBlocking) &&
			!place_meeting(x + sign(hsp), y + 2, oBlocking) &&
			place_meeting(x + sign(hsp), y + 3, oBlocking)
		) {
			y += 2;
		} else if (
			!place_meeting(x + sign(hsp), y, oBlocking) &&
			!place_meeting(x + sign(hsp), y + 1, oBlocking) &&
			place_meeting(x + sign(hsp), y + 2, oBlocking
		)) {
			y++;
		}
		
		if (!place_meeting(x + sign(hsp), y, oBlocking)) {
			x += sign(hsp);	
		} else {
			hsp = 0;
			break;
		}
	}

	image_xscale = (arm_direction > 270 || arm_direction <= 90) ? 1 : -1;
	
	arm_x = x + (15 * image_xscale);
	arm_y = y - 75;
	
	if (sprite_index == sWizard_Walking) {
		var idx_floor = floor(image_index);
		if (idx_floor == 1 || idx_floor == 3) {
			arm_y += 5;
		} else if (idx_floor == 2) {
			arm_y += 10;	
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
	} if (!is_undefined(mirror) && mmb_pressed && is_me) {
		var diff_x = mouse_x - mirror.x;
		var diff_y = mouse_y - mirror.y;
		var mag = sqrt(sqr(diff_x) + sqr(diff_y));
		diff_x = diff_x / mag * 1;
		diff_y = diff_y / mag * 1;
		mirror.x += diff_x;
		mirror.y += diff_y;
		var target_angle = point_direction(mirror.x, mirror.y, mouse_x, mouse_y);
		var angle_diff = angle_difference(mirror.image_angle, target_angle);
		var angle_change = -sign(angle_diff) * min(abs(angle_diff), 3);
		mirror.image_angle += angle_change; 
		var old_x = x;
		var old_y = y;
		while (place_meeting(x, y, mirror)) {
			var pd = point_direction(mirror.x, mirror.y, x, y);
			var push_x = lengthdir_x(1, pd);
			var push_y = lengthdir_y(1, pd);
			var moved = false;
			if (!place_meeting(x + push_x, y, oStatic)) {
				show_debug_message(string(push_x));
				x += push_x;
				moved = true;
			}
			if (!place_meeting(x, y + push_y, oStatic)) {
				y += push_y;
				moved = true;
			}
			if (!moved) {
				mirror.x -= diff_x;
				mirror.y -= diff_y;
				mirror.image_angle -= angle_change;
				x = old_x;
				y = old_y;
				break;
			}
		}
		mirror.image_angle -= 360 * (mirror.image_angle div 360);
		if (mirror.image_angle < 0) {
			mirror.image_angle += 360;
		}
	}
	
	grounded = place_meeting(x, y + 1, oBlocking);
	
	var input = 0;
	input |= key_left;
	input |= key_right << 0x1;
	input |= key_jump << 0x2;
	input |= lmb_pressed << 0x3;
	input |= mmb_pressed << 0x4;

	if (is_me && global.network_type == "CLIENT") {
		buffer_seek(send_buffer, buffer_seek_start, 0);
		buffer_write(send_buffer, buffer_u8, message_types.CHAR_UPDATE);
		new character_update(input, arm_direction, old_x, old_y).write_to_buffer(steam_id, send_buffer);
		// Use new x and y
		// new character_update(input, arm_direction, x, y).write_to_buffer(steam_id, send_buffer);
		steam_net_packet_send(steam_lobby_get_owner_id(), send_buffer, buffer_tell(send_buffer), steam_net_packet_type_unreliable);	
		// steam_net_packet_send(steam_lobby_get_owner_id(), send_buffer, 12, steam_net_packet_type_reliable);
	} else if (global.network_type == "SERVER") {
		ds_map_set(global.player_inputs, global.my_steam_id, input);
		ds_map_set(global.character_updates, steam_id, new character_update(input, arm_direction, old_x, old_y));
	}
	global.transients[? steam_id][? transient_types.MIRROR] = mirror;
}