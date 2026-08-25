var _gw = display_get_gui_width();   // 320
var _gh = display_get_gui_height();  // 240

draw_set_font(global.font_main);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// ── HUD SUPERIOR — HP DO PLAYER E MÉDIA ───────────────────────────
draw_set_color(c_white);
draw_text(4, 4, "HP: " + string(global.hp) + "/" + string(global.max_hp));

// Barra de HP
var _bar_x = 50;
var _bar_y = 5;
var _bar_w = 80;
var _bar_h = 8;
draw_set_color(c_red);
draw_rectangle(_bar_x, _bar_y, _bar_x + _bar_w, _bar_y + _bar_h, false);
draw_set_color(c_yellow);
draw_rectangle(_bar_x, _bar_y,
    _bar_x + _bar_w * clamp(global.hp / global.max_hp, 0, 1),
    _bar_y + _bar_h, false);

// Média em tempo real (sempre visível)
var _avg_str = "Média: " + string_format(global.knowledge_average, 1, 1)
             + " — " + get_knowledge_label();
draw_set_color(global.knowledge_average > KNOWLEDGE_PASS_THRESHOLD ? c_aqua : c_red);
draw_text(4, 18, _avg_str);

// ── HUD INIMIGO ───────────────────────────────────────────────────
var _enem_bar_x = _gw - 130;
draw_set_color(c_white);
draw_text(_enem_bar_x, 4, enemy_name);
draw_set_color(c_red);
draw_rectangle(_enem_bar_x, 16, _enem_bar_x + 110, 24, false);
draw_set_color(make_color_rgb(255, 80, 80));
draw_rectangle(_enem_bar_x, 16,
    _enem_bar_x + 110 * clamp(enemy_hp / enemy_max_hp, 0, 1),
    24, false);
draw_set_color(c_white);
draw_text(_enem_bar_x, 26, string(enemy_hp) + "/" + string(enemy_max_hp));

// ── CAIXA INFERIOR ────────────────────────────────────────────────
var _bx1 = 8;
var _bx2 = _gw - 8;
var _by1 = _gh - 90;
var _by2 = _gh - 50;

draw_set_color(c_black);
draw_rectangle(_bx1, _by1, _bx2, _by2, false);
draw_set_color(c_white);
draw_rectangle(_bx1, _by1, _bx2, _by2, true);

// ── BOTÕES DE AÇÃO ────────────────────────────────────────────────
var _btn_y  = _gh - 38;
var _btn_x  = 10;
var _btn_sp = 90;

for (var i = 0; i < array_length(menu_names); i++) {
    var _cx = _btn_x + i * _btn_sp;
    if (i == menu_option && state == BATTLE_STATE.MENU) {
        draw_set_color(c_yellow);
        draw_rectangle(_cx - 3, _btn_y - 2, _cx + 78, _btn_y + 16, true);
    } else {
        draw_set_color(c_white);
    }
    draw_text(_cx, _btn_y, menu_names[i]);
}

// ── CONTEÚDO DA CAIXA POR ESTADO ─────────────────────────────────
switch (state) {

    case BATTLE_STATE.MENU:
        draw_set_color(c_white);
        draw_text(_bx1 + 10, _by1 + 10, "* " + enemy_name + " bloqueia seu caminho!");
        break;

    case BATTLE_STATE.QUESTION:
        if (current_question == undefined) break;
        // Enunciado
        draw_set_color(c_white);
        draw_text_ext(_bx1 + 8, _by1 + 6, current_question.question, 14, (_bx2 - _bx1) - 16);

        // Caixa de alternativas (cobre os botões durante a questão)
        var _ay1 = _by2 + 2;
        var _ay2 = _gh - 2;
        draw_set_color(c_black);
        draw_rectangle(_bx1, _ay1, _bx2, _ay2, false);
        draw_set_color(c_white);
        draw_rectangle(_bx1, _ay1, _bx2, _ay2, true);

        var _labels = ["A", "B", "C", "D"];
        for (var i = 0; i < 4; i++) {
            var _ax = _bx1 + 8 + (i >= 2 ? 156 : 0);
            var _ay = _ay1 + 4 + (i % 2) * 18;
            if (i == selected_option) {
                draw_set_color(c_yellow);
                draw_text(_ax - 10, _ay, "▶");
            } else {
                draw_set_color(c_white);
            }
            draw_text(_ax, _ay, _labels[i] + ") " + current_question.answers[i].text);
        }
        break;

    case BATTLE_STATE.QUESTION_RESULT:
        // Caixa de feedback de média — estilo caixa de diálogo do jogo
        draw_set_color(c_black);
        draw_rectangle(_bx1, _by1, _bx2, _by2, false);
        draw_set_color(c_aqua);
        draw_rectangle(_bx1, _by1, _bx2, _by2, true);

        draw_set_color(c_white);
        draw_text_ext(_bx1 + 10, _by1 + 8, result_text, 14, (_bx2 - _bx1) - 16);

        // Barra de progresso do timer (quanto tempo resta antes do minigame)
        var _prog = result_timer / result_timer_max;
        draw_set_color(make_color_rgb(0, 120, 180));
        draw_rectangle(_bx1 + 2, _by2 - 6, _bx2 - 2, _by2 - 2, false);
        draw_set_color(c_aqua);
        draw_rectangle(_bx1 + 2, _by2 - 6,
            _bx1 + 2 + ((_bx2 - _bx1 - 4) * _prog),
            _by2 - 2, false);
        break;

    case BATTLE_STATE.ATTACK_MINIGAME:
        // Trilha da barra
        var _lane_y  = (_by1 + _by2) / 2 + 6;
        var _lane_h  = 14;
        var _tx1     = _bx1 + 10;
        var _tx2     = _bx2 - 10;

        // Fundo da trilha
        draw_set_color(c_black);
        draw_rectangle(_bx1, _by1, _bx2, _by2, false);
        draw_set_color(c_white);
        draw_rectangle(_bx1, _by1, _bx2, _by2, true);

        // Guias
        draw_set_color(c_blue);
        draw_line(_tx1, _lane_y - _lane_h, _tx2, _lane_y - _lane_h);
        draw_line(_tx1, _lane_y + _lane_h, _tx2, _lane_y + _lane_h);

        // Zona alvo
        var _tz1 = _tx1 + 2;
        var _tz2 = _tx1 + 120;
        draw_set_color(c_black);
        draw_rectangle(_tz1, _lane_y - _lane_h, _tz2, _lane_y + _lane_h, false);
        draw_set_color(c_blue);
        draw_rectangle(_tz1, _lane_y - _lane_h, _tz2, _lane_y + _lane_h, true);

        // Marca de perfect (ciano)
        draw_set_color(c_aqua);
        draw_rectangle(_tz1 + 2, _lane_y - _lane_h + 2, _tz1 + 7, _lane_y + _lane_h - 2, false);

        // Rastro
        if (attack_state == 0) {
            var _offsets = [10, 20, 30, 40];
            var _cols    = [c_ltgray, c_gray, c_dkgray, make_color_rgb(30,30,30)];
            for (var t = 0; t < 4; t++) {
                var _tx = attack_bar_x + _offsets[t];
                if (_tx < _tx2 && _tx > _tx1) {
                    draw_set_color(_cols[t]);
                    draw_rectangle(_tx - 2, _lane_y - _lane_h, _tx + 2, _lane_y + _lane_h, false);
                }
            }
        }

        // Barra principal
        draw_set_color(c_white);
        draw_rectangle(attack_bar_x - 3, _lane_y - _lane_h - 2,
                       attack_bar_x + 3, _lane_y + _lane_h + 2, false);

        // Dano máximo configurado pela média (exibido acima da trilha)
        draw_set_color(c_yellow);
        draw_text(_bx1 + 8, _by1 + 4, "Dano máx: " + string(attack_damage_max));

        // Resultado
        if (attack_state == 1) {
            draw_set_halign(fa_center);
            draw_set_color(attack_damage > 0 ? c_yellow : c_gray);
            draw_text((_bx1 + _bx2) / 2, _by1 + 20, attack_result_text);
            if (attack_damage > 0) {
                draw_set_color(c_white);
                draw_text((_bx1 + _bx2) / 2, _by1 + 34, "-" + string(attack_damage) + " HP");
            }
            draw_set_halign(fa_left);
        }
        break;

    case BATTLE_STATE.ENEMY_TURN:
        draw_set_color(c_white);
        draw_text(_bx1 + 10, _by1 + 10, "* " + enemy_name + " ataca!");
        break;

    case BATTLE_STATE.VICTORY:
        draw_set_color(c_yellow);
        draw_text(_bx1 + 10, _by1 + 10, "* Você venceu! Pressione Enter para continuar.");
        break;

    case BATTLE_STATE.DEFEAT:
        draw_set_color(c_red);
        draw_text(_bx1 + 10, _by1 + 10, "* Você foi derrotado... Pressione Enter para continuar.");
        break;
}