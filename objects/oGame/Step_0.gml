/// @description Insert description here
// You can write your code in this editor
if (countdown_started) {
	countdown_time_remaining -= delta_time / 1000;
	if (countdown_time_remaining <= 0) {
		global.game_started = true;
	}
}