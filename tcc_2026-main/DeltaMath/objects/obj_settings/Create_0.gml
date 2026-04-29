global.font_main = font_add_sprite(spr_main_font, 32, true, 1);
global.font_title = fnt_main
global.dialog_active = false; 
global.dialog_ended = false;
global.school_sound = false;
global.carol_dialog_finished = false;
global.carol_disappeared = false;
global.fade_active = false;
global.intro_played = false;
global.math_battle_active = false;
global.player_lives = 3;
global.max_lives = 3;
global.previous_room = -1; 
global.carol_end = true
global.current_enemy_id = "";
init_carol_cutscene();
global.paused = false;

if (!variable_global_exists("carol_defeated")) {
    global.carol_defeated = false;
}
if (!variable_global_exists("new_game")) {
    global.new_game = false;
}
carol_transition_done = false;
if (!variable_global_exists("player_knocked_down")) {
    global.player_knocked_down = false;
}

// Fullscreen ao iniciar
window_set_fullscreen(true);