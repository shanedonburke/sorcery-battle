// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function char_update_from_buffer(buffer, steam_id) {
	var _input = buffer_read(buffer, buffer_u8);
	var _arm_direction = buffer_read(buffer, buffer_u16);
	var _x = buffer_read(buffer, buffer_f32);
	var _y = buffer_read(buffer, buffer_f32);
	var t_count = buffer_read(buffer, buffer_u8);
	show_debug_message(string(t_count));
	if (t_count > 0) {
		var char = global.characters[? steam_id];
		var counted = 0;
		while (counted < t_count) {
			var t_type = buffer_read(buffer, buffer_u8);
			switch (t_type) {
				case transient_types.ORB:
					var num_orbs = buffer_read(buffer, buffer_u8);
					for (var i = 0; i < num_orbs; i++) {
						var orb_id = buffer_read(buffer, buffer_u8);
						var img_idx = buffer_read(buffer, buffer_u8);
						var o_x = buffer_read(buffer, buffer_f32);
						var o_y = buffer_read(buffer, buffer_f32);
						var orb = global.transients[? steam_id][? transient_types.ORB][? orb_id];
						if (is_undefined(orb)) {
							orb = char.release_orb(orb_id);
						}
						if (global.network_type == "CLIENT") {
							orb.image_index = img_idx;
							orb.x = o_x;
							orb.y = o_y;
						}
					}
					counted += num_orbs;
					break;
				case transient_types.MIRROR:
					var m_angle = buffer_read(buffer, buffer_u16);
					var m_x = buffer_read(buffer, buffer_f32);
					var m_y = buffer_read(buffer, buffer_f32);
					if (is_undefined(global.transients[? steam_id][? transient_types.MIRROR])) {
						char.spawn_mirror();
					}
					if (steam_id != global.my_steam_id) {
						char.mirror.image_angle = m_angle;
						char.mirror.x = m_x;
						char.mirror.y = m_y;	
					}
					counted += 1;
					break;
			}	
		}
	}
	return new character_update(_input, _arm_direction, _x, _y);
}