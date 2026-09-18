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
    DEFEAT,
    ITEM_MENU
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

// ── MENU DE ITENS ─────────────────────────────────────────────────
// Usa global.inventory_consumables direto: o mesmo array do inventário
// normal, então gastar aqui já reflete lá (via de mão dupla).
item_sel          = 0;   // índice do item selecionado na lista
item_view_top     = 0;   // primeiro item visível (rolagem da lista)
item_rows_visible = 4;   // quantas linhas cabem no painel
item_msg          = "";  // mensagem de feedback ("HP já está cheio!" etc)
item_msg_timer    = 0;   // frames restantes da mensagem
item_used_name    = "";  // nome do item usado, mostrado no ENEMY_TURN