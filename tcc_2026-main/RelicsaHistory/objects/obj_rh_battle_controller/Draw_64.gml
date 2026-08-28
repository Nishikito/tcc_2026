var _gw = display_get_gui_width();   // 320
var _gh = display_get_gui_height();  // 240

draw_set_font(global.font_main);
draw_set_halign(fa_left);
draw_set_valign(fa_top);



// ── TALAI — desenhado diretamente na GUI, lado esquerdo ──────────
// Usa SprPlayerDown que já existe no projeto como placeholder
// Quando o artista entregar o sprite de batalha, troque aqui
//temporário
var _talai_x = 45;
var _talai_y = 95;
var _talai_spr = SprPlayerDown;

// Oscilação suave baseada no tempo
var _osc = dsin(current_time * 0.1) * 2;

// Estado visual baseado no estado da batalha
var _talai_angle = 0;
var _talai_dy    = _osc;

if (state == BATTLE_STATE.ATTACK_MINIGAME) {
    _talai_angle = -15;  // inclinado ao atacar
    _talai_dy    = -4;
} else if (state == BATTLE_STATE.ENEMY_TURN) {
    _talai_dy = 2;       // recua ao defender
}

draw_sprite_ext(
    _talai_spr, 0,
    _talai_x, _talai_y + _talai_dy,
    1.5, 1.5,
    _talai_angle,
    c_white, 1
);





// ══════════════════════════════════════════════════════════════════
// SUPERIOR ESQUERDO — MÉDIA (equivalente ao TP do Deltarune)
// ══════════════════════════════════════════════════════════════════
var _avg_color;
if (global.knowledge_average > KNOWLEDGE_PASS_THRESHOLD) {
    _avg_color = make_color_rgb(255, 220, 60);
} else {
    _avg_color = make_color_rgb(255, 80, 80);
}

draw_set_color(_avg_color);
draw_text(6, 4, "MED");
draw_set_halign(fa_center);
draw_text(18, 14, string_format(global.knowledge_average, 1, 1));
draw_set_halign(fa_left);
draw_set_color(c_white);
draw_text(6, 24, get_knowledge_label());

// Barra vertical de média (igual à barra de TP do Deltarune)
var _tp_x  = 4;
var _tp_y1 = 34;
var _tp_y2 = 160;
var _tp_h  = _tp_y2 - _tp_y1;
var _tp_fill = clamp(global.knowledge_average / 10.0, 0, 1);

draw_set_color(make_color_rgb(40, 40, 40));
draw_rectangle(_tp_x, _tp_y1, _tp_x + 8, _tp_y2, false);
draw_set_color(_avg_color);
draw_rectangle(_tp_x, _tp_y2 - round(_tp_h * _tp_fill), _tp_x + 8, _tp_y2, false);
draw_set_color(c_white);
draw_rectangle(_tp_x, _tp_y1, _tp_x + 8, _tp_y2, true);

// ══════════════════════════════════════════════════════════════════
// HUD INFERIOR — estilo Deltarune
// Linha de info do personagem + caixa de diálogo + botões de ação
// ══════════════════════════════════════════════════════════════════
var _hud_y   = 170;    // onde começa o HUD inferior
var _hud_h   = _gh - _hud_y; // altura disponível

// Fundo do HUD
draw_set_color(c_black);
draw_rectangle(0, _hud_y, _gw, _gh, false);
draw_set_color(c_white);
draw_rectangle(0, _hud_y, _gw, _hud_y + 1, false); // linha separadora

// ── FICHA DO TALAI ────────────────────────────────────────────────
var _pc_x   = 6;
var _pc_y   = _hud_y + 4;
var _bar_w  = 80;
var _bar_h  = 6;
var _hp_pct = clamp(global.hp / global.max_hp, 0, 1);

// Ícone do Talai (quadrado colorido como placeholder — troque por sprite)
draw_set_color(make_color_rgb(100, 160, 255));
draw_rectangle(_pc_x, _pc_y, _pc_x + 14, _pc_y + 14, false);

// Nome
draw_set_color(c_white);
draw_text(_pc_x + 18, _pc_y, global.player_name);

// Label HP
draw_set_color(make_color_rgb(255, 220, 60));
draw_text(_pc_x + 18, _pc_y + 12, "HP");

// Barra de HP
var _bx = _pc_x + 34;
var _by = _pc_y + 13;
draw_set_color(make_color_rgb(40, 40, 40));
draw_rectangle(_bx, _by, _bx + _bar_w, _by + _bar_h, false);

// Cor da barra baseada no HP
var _hp_color;
if (_hp_pct > 0.5)      _hp_color = make_color_rgb(255, 220, 60);  // amarelo
else if (_hp_pct > 0.25) _hp_color = make_color_rgb(255, 140, 0);   // laranja
else                      _hp_color = make_color_rgb(255, 40,  40);  // vermelho

draw_set_color(_hp_color);
draw_rectangle(_bx, _by, _bx + round(_bar_w * _hp_pct), _by + _bar_h, false);

// Números de HP
draw_set_color(c_white);
draw_set_halign(fa_right);
draw_text(_bx + _bar_w + 40, _by - 1,
    string(global.hp) + "/" + string(global.max_hp));
draw_set_halign(fa_left);

// ── CAIXA DE DIÁLOGO / AÇÃO ───────────────────────────────────────
var _box_y1 = _hud_y + 26;
var _box_y2 = _gh - 22;
var _box_x1 = 4;
var _box_x2 = _gw - 4;

draw_set_color(c_black);
draw_rectangle(_box_x1, _box_y1, _box_x2, _box_y2, false);
draw_set_color(c_white);
draw_rectangle(_box_x1, _box_y1, _box_x2, _box_y2, true);

// ── BOTÕES DE AÇÃO ────────────────────────────────────────────────
var _btn_y  = _gh - 18;
var _btn_x  = 8;
var _btn_sp = 90;

for (var i = 0; i < array_length(menu_names); i++) {
    var _cx = _btn_x + i * _btn_sp;
    if (i == menu_option && state == BATTLE_STATE.MENU) {
        // Fundo amarelo na opção selecionada
        draw_set_color(make_color_rgb(255, 220, 60));
        draw_rectangle(_cx - 2, _btn_y - 1, _cx + 70, _btn_y + 14, false);
        draw_set_color(c_black);
    } else {
        draw_set_color(c_white);
    }
    draw_text(_cx, _btn_y, menu_names[i]);
}

// ══════════════════════════════════════════════════════════════════
// CONTEÚDO DA CAIXA POR ESTADO
// ══════════════════════════════════════════════════════════════════
var _cx1 = _box_x1 + 8;
var _cy1 = _box_y1 + 6;
var _cw  = (_box_x2 - _box_x1) - 16;

switch (state) {

    case BATTLE_STATE.MENU:
        draw_set_color(c_white);
        draw_text_ext(_cx1, _cy1, "* " + enemy_name + " bloqueia seu caminho!", 12, _cw);
        break;

    case BATTLE_STATE.QUESTION:
    if (current_question == undefined) break;

    // Expande a caixa para cobrir todo o HUD durante a questão
    var _qx1 = _box_x1;
    var _qx2 = _box_x2;
    var _qy1 = _hud_y + 2;
    var _qy2 = _gh - 2;

    draw_set_color(c_black);
    draw_rectangle(_qx1, _qy1, _qx2, _qy2, false);
    draw_set_color(c_white);
    draw_rectangle(_qx1, _qy1, _qx2, _qy2, true);

    var _qcx = _qx1 + 8;
    var _qcw = (_qx2 - _qx1) - 16;

    // Enunciado — linha separada das alternativas
    draw_set_color(c_white);
    draw_text_ext(_qcx, _qy1 + 5, current_question.question, 11, _qcw);

    // Linha separadora
    var _sep_y = _qy1 + 34;
    draw_set_color(make_color_rgb(60, 60, 60));
    draw_rectangle(_qx1 + 4, _sep_y, _qx2 - 4, _sep_y + 1, false);

    // Alternativas — 2 colunas, 2 linhas
    var _labels = ["A", "B", "C", "D"];
    var _half_w = (_qcw / 2) - 4;

    for (var i = 0; i < 4; i++) {
        var _col = (i mod 2);
        var _row = (i div 2);
        var _ax  = _qcx + (_col * (_half_w + 8));
        var _ay  = _sep_y + 6 + (_row * 18);

        if (i == selected_option) {
            draw_set_color(make_color_rgb(255, 220, 60));
            draw_text(_ax - 8, _ay, "▶");
        } else {
            draw_set_color(c_white);
        }
        draw_text_ext(_ax, _ay, _labels[i] + ") " + current_question.answers[i].text, -1, _half_w);
    }
    break;
	
	
    case BATTLE_STATE.QUESTION_RESULT:
        // Caixa com borda colorida baseada no score
        var _score_color;
		if (last_answer_score >= 7) {
			_score_color = make_color_rgb(60, 220, 60);
		} else if (last_answer_score >= 4) {
			_score_color = make_color_rgb(255, 220, 60);
		} else {
			_score_color = make_color_rgb(255, 80, 80);
		}
        draw_set_color(c_black);
        draw_rectangle(_box_x1, _box_y1, _box_x2, _box_y2, false);
        draw_set_color(_score_color);
        draw_rectangle(_box_x1, _box_y1, _box_x2, _box_y2, true);

        draw_set_color(c_white);
        draw_text_ext(_cx1, _cy1, result_text, 11, _cw);

        // Barra de timer
        var _prog = result_timer / result_timer_max;
        draw_set_color(make_color_rgb(40, 40, 40));
        draw_rectangle(_box_x1 + 2, _box_y2 - 5, _box_x2 - 2, _box_y2 - 2, false);
        draw_set_color(_score_color);
        draw_rectangle(_box_x1 + 2, _box_y2 - 5,
            _box_x1 + 2 + ((_box_x2 - _box_x1 - 4) * _prog),
            _box_y2 - 2, false);
        break;

    case BATTLE_STATE.ATTACK_MINIGAME:
        draw_set_color(c_black);
        draw_rectangle(_box_x1, _box_y1, _box_x2, _box_y2, false);
        draw_set_color(c_white);
        draw_rectangle(_box_x1, _box_y1, _box_x2, _box_y2, true);

        var _lane_y = (_box_y1 + _box_y2) / 2 + 4;
        var _lane_h = 10;
        var _tx1    = _cx1;
        var _tx2    = _box_x2 - 8;

        // Trilha
        draw_set_color(make_color_rgb(60, 60, 60));
        draw_rectangle(_tx1, _lane_y - _lane_h, _tx2, _lane_y + _lane_h, false);

        // Zona alvo
        var _tz1 = _tx1 + 4;
        var _tz2 = _tx1 + 80;
        draw_set_color(make_color_rgb(30, 100, 30));
        draw_rectangle(_tz1, _lane_y - _lane_h, _tz2, _lane_y + _lane_h, false);
        draw_set_color(c_green);
        draw_rectangle(_tz1, _lane_y - _lane_h, _tz2, _lane_y + _lane_h, true);

        // Marca perfect (ciano)
        draw_set_color(c_aqua);
        draw_rectangle(_tz1 + 2, _lane_y - _lane_h + 2, _tz1 + 6, _lane_y + _lane_h - 2, false);

        // Rastro da barra
        if (attack_state == 0) {
            var _offsets = [8, 16, 24];
            var _alphas  = [0.5, 0.3, 0.1];
            for (var t = 0; t < 3; t++) {
                var _tx = attack_bar_x + _offsets[t];
                if (_tx > _tx1 && _tx < _tx2) {
                    draw_set_alpha(_alphas[t]);
                    draw_set_color(c_white);
                    draw_rectangle(_tx - 2, _lane_y - _lane_h, _tx + 2, _lane_y + _lane_h, false);
                }
            }
            draw_set_alpha(1);
        }

        // Barra principal
        draw_set_color(c_white);
        draw_rectangle(attack_bar_x - 3, _lane_y - _lane_h - 2,
                       attack_bar_x + 3, _lane_y + _lane_h + 2, false);

        // Dano máximo
        draw_set_color(make_color_rgb(255, 220, 60));
        draw_text(_cx1, _box_y1 + 4, "Dano máx: " + string(attack_damage_max));

        // Resultado
        if (attack_state == 1) {
            draw_set_halign(fa_center);
            var _rc;
			if (attack_damage > 0) {
				_rc = make_color_rgb(255, 220, 60);
			} else {
				_rc = c_gray;
			}
            draw_set_color(_rc);
            draw_text((_box_x1 + _box_x2) / 2, _box_y1 + 18, attack_result_text);
            if (attack_damage > 0) {
                draw_set_color(c_white);
                draw_text((_box_x1 + _box_x2) / 2, _box_y1 + 30,
                    "-" + string(attack_damage) + " HP");
            }
            draw_set_halign(fa_left);
        }
        break;

    case BATTLE_STATE.ENEMY_TURN:
        draw_set_color(c_white);
        draw_text_ext(_cx1, _cy1, "* " + enemy_name + " ataca!", 12, _cw);
        break;

    case BATTLE_STATE.VICTORY:
        draw_set_color(make_color_rgb(255, 220, 60));
        draw_text_ext(_cx1, _cy1, "* Você venceu! [Z] para continuar.", 12, _cw);
        break;

    case BATTLE_STATE.DEFEAT:
        draw_set_color(make_color_rgb(255, 80, 80));
        draw_text_ext(_cx1, _cy1, "* Você foi derrotado... [Z] para continuar.", 12, _cw);
        break;
}

// Reset
draw_set_halign(fa_left);
draw_set_color(c_white);
draw_set_alpha(1);