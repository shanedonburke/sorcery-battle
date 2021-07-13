/// @description Insert description here
// You can write your code in this editor
global.game = self;
global.num_loaded = 0;
global.characters_initialized = false;
global.game_started = false;

countdown_started = false;
countdown_time_remaining = 3000;

start_game = function() {
	countdown_started = true;
}

destroy_lobby_avatars();
init_characters_client();