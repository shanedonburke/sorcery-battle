/// @description Insert description here
// You can write your code in this editor
stop_frame = undefined;
steam_id = -1;
orb_id = -1;

stop_animation = function() {
	stop_frame = image_index;
	image_speed = 0;
}

destroy = function() {
	ds_map_delete(global.transients[? steam_id][? transient_types.ORB], orb_id);
	instance_destroy();
}