// GUI fixa em 320x240 — mesma resolução do projeto principal
display_set_gui_size(320, 240);
gpu_set_tex_filter(false);

// ── MÁQUINA DE ESTADOS ────────────────────────────────────────────
enum BATTLE_STATE {
    MENU,
    QUESTION,
    QUESTION_RESULT,
    ATTACK_MINIGAME,
    ENEMY_TURN,
    VICTORY,
    DEFEAT
}
state = BATTLE_STATE.MENU;

// ── MENU ──────────────────────────────────────────────────────────
menu_option  = 0;
menu_names   = ["LUTAR", "ITEM", "DEFENDER"];

// ── QUESTÃO ───────────────────────────────────────────────────────
current_question    = undefined;
selected_option     = 0;
last_answer_score   = 0;

// ── RESULTADO DA QUESTÃO ──────────────────────────────────────────
result_timer     = 0;
result_timer_max = 120; // 2 segundos a 60fps
result_text      = "";
result_damage_max = 0;

// ── MINIGAME DE ATAQUE ────────────────────────────────────────────
attack_bar_x     = 0;
attack_bar_speed = 7;
attack_state     = 0;     // 0 = deslizando, 1 = resultado
attack_result_text = "";
attack_timer     = 0;
attack_damage    = 0;
attack_damage_max = 0;    // configurado após a questão

// ── TURNO DO INIMIGO ──────────────────────────────────────────────
enemy_turn_timer    = 0;
enemy_turn_max_time = 300;

// ── INIMIGO ───────────────────────────────────────────────────────
enemy_name = "Inimigo";
enemy_hp   = global.battle_enemy_hp;
enemy_max_hp = global.battle_enemy_max_hp;
if (enemy_hp <= 0) {
    enemy_hp     = 50;
    enemy_max_hp = 50;
}


