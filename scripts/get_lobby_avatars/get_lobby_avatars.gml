// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function get_lobby_avatars(){
	destroy_lobby_avatars();
	
	for (var i = 0; i < steam_lobby_get_member_count(); ++i) {
		var steam_id = steam_lobby_get_member_id(i);
		var image_id = steam_get_user_avatar(steam_id, steam_user_avatar_size_large);
		if (image_id > 0) {
			var sprite_id = steam_image_create_sprite(image_id);
			show_debug_message("Loaded sprite with ID " + string(sprite_id));
			var avatar_inst = instance_create_depth(200, 170 + 200 * i, 0, oSteamAvatar);
			avatar_inst.sprite_index = sprite_id;
			avatar_inst.persistent = true;
			ds_list_add(global.lobby_avatars, avatar_inst);
		}
	}
}