// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function char_update_from_buffer(){
	var _input = buffer_read(buffer, buffer_u8);
	var _arm_direction = buffer_read(buffer, buffer_u16);
	var _x = buffer_read(buffer, buffer_f32);
	var _y = buffer_read(buffer, buffer_f32);
	return new character_update(_input, _arm_direction, _x, _y);
}