/// @description Insert description here
// You can write your code in this editor
var w = camera_get_view_width(view_camera[0]);
var h = camera_get_view_height(view_camera[0]);
draw_set_font(fImpostor);
draw_set_color(c_white);
draw_set_halign(fa_center);

if (countdown_started) {
	if (countdown_time_remaining > 0) {
		draw_text(w / 2, h / 2, string(ceil(countdown_time_remaining / 1000)));	
	} else if (countdown_time_remaining >= -1000) {
		draw_text(w / 2, h / 2, "FIGHT!");	
	}
}