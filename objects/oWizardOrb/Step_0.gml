/// @description Insert description here
// You can write your code in this editor
x += lengthdir_x(speed, direction);
y += lengthdir_y(speed, direction);

if (!is_undefined(stop_frame)) {
	image_angle += 0.5;
} else if (image_index == image_number - 1) {
	stop_animation();	
}