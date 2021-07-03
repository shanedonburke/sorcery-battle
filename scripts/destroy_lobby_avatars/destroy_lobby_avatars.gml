// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function destroy_lobby_avatars(){
	for (var i = 0; i < ds_list_size(global.lobby_avatars); ++i) {
		instance_destroy(ds_list_find_value(global.lobby_avatars, i));
	}
	ds_list_clear(global.lobby_avatars);
}