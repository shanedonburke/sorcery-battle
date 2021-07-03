// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function character_update(_input, _arm_direction, _x, _y) constructor {
	input = _input;
	arm_direction = _arm_direction;
	x = _x;
	y = _y;
	write_to_buffer = function(buffer) {
		buffer_seek(buffer, buffer_seek_start, 0);
		buffer_write(buffer, buffer_u8, 3);
		buffer_write(buffer, buffer_u8, input);
		buffer_write(buffer, buffer_u16, arm_direction);
		buffer_write(buffer, buffer_f32, x);
		buffer_write(buffer, buffer_f32, y);
	}
}