// GUI fixa em 320x240 — mesma resolução do projeto principal
display_set_gui_size(320, 240);
global.fade_active = false;
intro_max   = 25;
intro_timer = intro_max;
// Veio da transição (os sprites já estão na formação)? Então NÃO faz fade a partir do preto:
// esse fade cobriria o Talai e o inimigo e eles "sumiriam e reapareceriam".
if (variable_global_exists("battle_from_transition") && global.battle_from_transition) {
    intro_timer = 0;
    global.battle_from_transition = false;
}

// ── MÁQUINA DE ESTADOS ────────────────────────────────────────────
enum BATTLE_STATE {
    MENU,
    QUESTION,
    QUESTION_RESULT,
    ATTACK_MINIGAME,
    ENEMY_TURN,
    VICTORY,
    DEFEAT,
    ITEM_MENU,
    ATTACK_ANIM   // novo: animação visual do ataque (fica no FIM do enum de propósito)
}
state = BATTLE_STATE.MENU;

// ── MENU ──────────────────────────────────────────────────────────
menu_option  = 0;
menu_names   = ["LUTAR", "ITEM", "DEFENDER"];

// Frame do ícone de cada comando em UI_SLOT_COMMAND_SPRITE (MESMA ORDEM de menu_names).
// Frame normal = valor | frame selecionado = valor + 4.
// spr_bt_cmd: 0 = figura (AGIR/LUTAR) · 1 = frasco · 2 = bolsa (ITEM) · 3 = escudo (DEFENDER)
menu_icon_frames = [0, 2, 3];

// Moldura de sprite esticada em LARGURA e ALTURA (9-slice manual):
// 4 cantos fixos + 4 bordas e o miolo esticados. Funciona em qualquer tamanho.
//   _frame: 0 = compacto | 1 = alto      _x,_y,_w,_h: onde e que tamanho (em pixels da GUI)
//   _color: tinge a borda (c_white = cor original do sprite; outra cor = borda dessa cor)
// A arte de cada frame ocupa só parte do sprite de 32 linhas: frame 0 = linhas 15..31 | frame 1 = 0..31
ui_frame_art_top    = [15, 0];
ui_frame_art_height = [17, 32];

draw_ui_frame = function(_frame, _x, _y, _w, _h, _color) {
    var _spr = UI_SLOT_PANEL_SPRITE;
    var _sw  = sprite_get_width(_spr);
    var _at  = ui_frame_art_top[_frame];
    var _ah  = ui_frame_art_height[_frame];
    var _cx  = UI_PANEL_CAP_PIXELS;
    var _cy  = UI_PANEL_CAP_VERTICAL;

    // Origem (no sprite) e destino (na tela) das 3 colunas e das 3 linhas
    var _src_x = [0, _cx, _sw - _cx];
    var _src_w = [_cx, _sw - _cx * 2, _cx];
    var _dst_x = [_x, _x + _cx, _x + _w - _cx];
    var _dst_w = [_cx, _w - _cx * 2, _cx];

    var _src_y = [_at, _at + _cy, _at + _ah - _cy];
    var _src_h = [_cy, _ah - _cy * 2, _cy];
    var _dst_y = [_y, _y + _cy, _y + _h - _cy];
    var _dst_h = [_cy, _h - _cy * 2, _cy];

    for (var _row = 0; _row < 3; _row++) {
        for (var _col = 0; _col < 3; _col++) {
            draw_sprite_part_ext(_spr, _frame,
                                 _src_x[_col], _src_y[_row], _src_w[_col], _src_h[_row],
                                 _dst_x[_col], _dst_y[_row],
                                 _dst_w[_col] / _src_w[_col], _dst_h[_row] / _src_h[_row],
                                 _color, 1);
        }
    }
}

// ── CURSOR (coração em sprite nas listas) ─────────────────────────
// cursor_timer avança no Step; o desenho só LÊ. O balanço usa o mesmo seno do menu de pause.
cursor_timer = 0;
draw_ui_cursor = function(_x, _y) {
    var _bob = round(sin(cursor_timer) * UI_CURSOR_BOB_PIXELS);
    draw_sprite(UI_SLOT_CURSOR_SPRITE, 0, _x, _y + _bob);
}

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

// ── ANIMAÇÃO DE ATAQUE (estado ATTACK_ANIM) ───────────────────────
// Só controla o VISUAL. O dano já foi calculado/aplicado no clique do minigame.
// Tempos e sprites: ver os #macro ANIM_* em scr_damage_calculator.
anim_timer        = 0;      // frames desde o início da animação
anim_swing        = false;  // true = Talai balança o golpe | false = errou por tempo, sem golpe
anim_hit          = false;  // true = o golpe causou dano (haverá impacto + reação)
anim_impact_done  = false;  // true depois que o impacto disparou (garante que dispara UMA vez)
anim_end_frame    = 0;      // frame em que a animação acaba (0 = ainda não definido)

// ── TURNO DO INIMIGO ──────────────────────────────────────────────
enemy_turn_timer    = 0;
enemy_turn_max_time = 300;

// ── TALAI ATINGIDO ────────────────────────────────────────────────
// Frames restantes mostrando o sprite de dano. Quem LIGA: obj_rh_battle_player (ao levar bala).
// Quem DESCONTA: o Step deste objeto. Quem DESENHA: o Draw_64.
talai_hit_timer = 0;

// ── DEFENDER ──────────────────────────────────────────────────────
// true só durante o turno do inimigo logo após escolher DEFENDER.
// Quem LÊ: calculate_enemy_damage() (scr_damage_calculator). Quem DESLIGA: o Step, no fim do turno.
is_defending = false;

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