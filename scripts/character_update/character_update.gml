// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function character_update(_input, _arm_direction, _x, _y) constructor {
	input = _input;
	arm_direction = _arm_direction;
	x = _x;
	y = _y;
	write_to_buffer = function(steam_id, buffer) {
		buffer_write(buffer, buffer_u8, input);
		buffer_write(buffer, buffer_u16, arm_direction);
		buffer_write(buffer, buffer_f32, x);
		buffer_write(buffer, buffer_f32, y);
		var player_map = global.transients[? steam_id];
		var orbs = player_map[? transient_types.ORB];
		var num_orbs = ds_map_size(orbs);
		var mirror = player_map[? transient_types.MIRROR];
		var t_count = num_orbs + (is_undefined(mirror) ? 0 : 1);
		buffer_write(buffer, buffer_u8, t_count);
		if (num_orbs > 0) {
			var orb_id_arr = ds_map_keys_to_array(orbs);
			buffer_write(buffer, buffer_u8, transient_types.ORB);
			buffer_write(buffer, buffer_u8, num_orbs);
			for (var i = 0; i < num_orbs; i++) {
				var o = orbs[? orb_id_arr[i]];
				buffer_write(buffer, buffer_u8, orb_id_arr[i]);
				buffer_write(buffer, buffer_u8, o.image_index);
				buffer_write(buffer, buffer_f32, o.x);
				buffer_write(buffer, buffer_f32, o.y);
			}
		}
		if (!is_undefined(mirror)) {
			buffer_write(buffer, buffer_u8, transient_types.MIRROR);
			buffer_write(buffer, buffer_u16, mirror.image_angle);
			buffer_write(buffer, buffer_f32, mirror.x);
			buffer_write(buffer, buffer_f32, mirror.y);
		}
	}
}