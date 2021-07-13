/// @description Insert description here
// You can write your code in this editor
x += lengthdir_x(speed, direction);
y += lengthdir_y(speed, direction);

if (!is_undefined(stop_frame)) {
	image_angle += 0.5;
} else if (image_index == image_number - 1) {
	stop_animation();	
}

if (speed != 0) {
	var c_hit = instance_place(x, y, oWizard);
	if (c_hit != noone && c_hit.steam_id != steam_id) {
		c_hit.damage(4);
		destroy();
	}

	if (place_meeting(x, y, oStatic) && image_index < image_number - 1) {
		destroy();
	}	
}