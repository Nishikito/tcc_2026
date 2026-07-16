global.font_main = fnt_dialogo;
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


//variaveis do inventário

//status do personagem
global.player_name = "Talai";
global.hp = 10;
global.max_hp = 10;
global.history_knowledge = 0; // 0 a 100 — progresso histórico
global.relics_count = 0; // atualizado automaticamente pelo scr_inventory_add

//arrays de inventário
global.inventory_relics = []; // relíquias colecionáveis
global.inventory_mission = []; // itens de missão / chave
global.inventory_docs = []; // documentos e lore desbloqueado
global.inventory_consumables = []; // consumíveis (cura, buff)






if(room == rm_teste){
	audio_stop_sound(sfxTitle);
}

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

// ── VOLUME ─────────────────────────────────────────────
global.vol_bgm  = 1.0;  // 0.0 = mudo, 1.0 = máximo
global.vol_sfx  = 1.0;

// ── TECLAS (armazena o keycode de cada ação) ───────────
global.key_up     = ord("W");
global.key_down   = ord("S");
global.key_left   = ord("A");
global.key_right  = ord("D");
global.key_sprint = vk_shift;
global.key_interact = vk_enter; // útil para o futuro
global.key_inventory = ord("I");