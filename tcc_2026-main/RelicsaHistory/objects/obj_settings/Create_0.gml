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
// ── PONTE EXPLORAÇÃO ↔ BATALHA ────────────────────────────────────
// obj_settings é persistente E está colocado em várias salas (title, teste, batalha),
// então ele é recriado a cada troca de sala e este Create roda DE NOVO.
// Estas variáveis precisam SOBREVIVER à troca de sala, por isso só são
// inicializadas se ainda não existirem.
if (!variable_global_exists("current_enemy_id")) global.current_enemy_id = "";
init_carol_cutscene();
global.paused = false;
global.carol_dialogo_fim = false;
// ── PROGRESSO DO JOGO ─────────────────────────────────────────────
// Este Create roda de novo a cada troca de sala (obj_settings é persistente e está
// colocado em várias salas). Tudo que é PROGRESSO só inicializa UMA vez; o reinício
// de verdade acontece no botão NOVO JOGO (obj_buttons).
// ── SAVE ──────────────────────────────────────────────────────────
if (!variable_global_exists("play_time")) global.play_time = 0;    // tempo de jogo, em segundos
if (!variable_global_exists("save_slot")) global.save_slot = -1;   // slot ativo (-1 = nenhum ainda)
if (!variable_global_exists("save_point_unlock_time")) global.save_point_unlock_time = 0;   // evita reabrir o menu com o mesmo Enter

if (!variable_global_exists("itens_coletados")) global.itens_coletados = []; // itens do cenário já pegos


//variaveis do inventário

//status do personagem
global.player_name = "Talai";
// HP só inicializa UMA vez: este Create roda de novo a cada troca de sala (veja a nota
// da ponte exploração↔batalha) e o HP não pode voltar a 20 sozinho.
if (!variable_global_exists("max_hp")) global.max_hp = 20;
if (!variable_global_exists("hp"))     global.hp     = global.max_hp;
if (!variable_global_exists("history_knowledge")) global.history_knowledge = 0; // 0 a 100 — progresso histórico
if (!variable_global_exists("relics_count"))      global.relics_count = 0;      // atualizado automaticamente pelo scr_inventory_add

//arrays de inventário
if (!variable_global_exists("inventory_relics"))      global.inventory_relics      = []; // relíquias colecionáveis
if (!variable_global_exists("inventory_mission"))     global.inventory_mission     = []; // itens de missão / chave
if (!variable_global_exists("inventory_docs"))        global.inventory_docs        = []; // documentos e lore desbloqueado
if (!variable_global_exists("inventory_consumables")) global.inventory_consumables = []; // consumíveis (cura, buff)






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




// ── SISTEMA DE CONHECIMENTO ───────────────────────────────────────
if (!variable_global_exists("knowledge_scores"))  global.knowledge_scores  = [];
if (!variable_global_exists("knowledge_average")) global.knowledge_average = 0.0;
if (!variable_global_exists("knowledge_total"))   global.knowledge_total   = 0;

// ── DADOS DA BATALHA ATUAL ────────────────────────────────────────
if (!variable_global_exists("battle_enemy_hp"))     global.battle_enemy_hp     = 0;
if (!variable_global_exists("battle_enemy_max_hp")) global.battle_enemy_max_hp = 0;
if (!variable_global_exists("battle_result"))       global.battle_result       = "";


// provavelmente terei de criar uma variável que salva a sala em que estamos, na coordenada em que estivermos
if (!variable_global_exists("pre_battle_room")) global.pre_battle_room = rm_teste; // sala padrão de retorno
if (!variable_global_exists("pre_battle_hp"))   global.pre_battle_hp   = 0;        // salva HP antes de destruir o player
if (!variable_global_exists("pre_battle_x"))    global.pre_battle_x    = 0;        // salva posição X para restaurar
if (!variable_global_exists("pre_battle_y"))    global.pre_battle_y    = 0;        // salva posição Y para restaurar