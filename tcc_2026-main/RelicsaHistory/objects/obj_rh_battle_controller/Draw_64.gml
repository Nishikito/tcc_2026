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
var _talai_spr = spr_talaiB_battle;
var _talai_img = 0;

// Oscilação suave baseada no tempo
var _osc = dsin(current_time * 0.1) * 2;

// Estado visual baseado no estado da batalha
var _talai_angle = 0;
var _talai_dx    = 0;
var _talai_dy    = _osc;

if (state == BATTLE_STATE.ATTACK_MINIGAME) {
    _talai_angle = -15;  // inclinado ao atacar
    _talai_dy    = -4;
} else if (state == BATTLE_STATE.ATTACK_ANIM) {
    if (anim_swing) {
        // ── GOLPE: recua (windup) → avança rápido (lunge) → volta ──
        _talai_dy = 0;
        if (anim_timer < ANIM_ATTACK_DURATION) {
            var _p = anim_timer / ANIM_ATTACK_DURATION;   // 0..1 até o impacto
            if (_p < 0.4) {
                var _w = _p / 0.4;
                _talai_dx    = -ANIM_TALAI_WINDUP_PIXELS * _w;
                _talai_angle = 10 * _w;
            } else {
                var _q = (_p - 0.4) / 0.6;
                _q = _q * _q;                              // acelera até o impacto
                _talai_dx    = lerp(-ANIM_TALAI_WINDUP_PIXELS, ANIM_TALAI_LUNGE_PIXELS, _q);
                _talai_angle = lerp(10, -20, _q);
            }
        } else {
            var _r = clamp((anim_timer - ANIM_ATTACK_DURATION) / ANIM_TALAI_RETURN_FRAMES, 0, 1);
            _talai_dx    = lerp(ANIM_TALAI_LUNGE_PIXELS, 0, _r);
            _talai_angle = lerp(-20, 0, _r);
        }

        // SLOT: sprite de ataque do Talai (se preenchido)
        if (ANIM_SLOT_TALAI_ATTACK_SPRITE != noone) {
            _talai_spr = ANIM_SLOT_TALAI_ATTACK_SPRITE;
            _talai_img = min(floor(anim_timer * ANIM_TALAI_ATTACK_SPRITE_SPEED),
                             sprite_get_number(_talai_spr) - 1);
        }
    } else {
        // Errou por tempo: mantém a pose do minigame, sem golpe
        _talai_angle = -15;
        _talai_dy    = -4;
    }
} else if (state == BATTLE_STATE.ENEMY_TURN) {
    _talai_dy = 2;       // recua ao defender
}

draw_sprite_ext(
    _talai_spr, _talai_img,
    _talai_x + _talai_dx, _talai_y + _talai_dy,
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
draw_text(_bx + _bar_w + 40, _by - 1, string(global.hp) + "/" + string(global.max_hp));
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

    // Ocupa quase a tela inteira — pergunta precisa de espaço pra respirar
    var _qx1 = 4;
    var _qx2 = _gw - 4;
    var _qy1 = 4;
    var _qy2 = _gh - 4;

    draw_set_color(c_black);
    draw_rectangle(_qx1, _qy1, _qx2, _qy2, false);
    draw_set_color(c_white);
    draw_rectangle(_qx1, _qy1, _qx2, _qy2, true);

    var _qcx = _qx1 + 10;
    var _qcw = (_qx2 - _qx1) - 20;

    // Enunciado — fonte normal, altura calculada dinamicamente
    draw_set_font(global.font_main);
    draw_set_color(c_white);
    draw_text_ext(_qcx, _qy1 + 8, current_question.question, 14, _qcw);
    var _question_h = string_height_ext(current_question.question, 14, _qcw);

    // Linha separadora logo abaixo do enunciado
    var _sep_y = _qy1 + 8 + _question_h + 8;
    draw_set_color(make_color_rgb(60, 60, 60));
    draw_rectangle(_qx1 + 6, _sep_y, _qx2 - 6, _sep_y + 1, false);

    // Alternativas — lista vertical de largura total, altura de cada uma
    // calculada a partir do próprio texto, sem sobreposição
    draw_set_font(fnt_question);
    var _labels    = ["A", "B", "C", "D"];
    var _ans_x     = _qcx + 14;          // espaço reservado pra seta/destaque
    var _ans_w     = _qcw - 14;
    var _ans_sep   = 13;                  // espaço entre linhas quebradas
    var _ans_gap   = 6;                   // espaço entre uma alternativa e a próxima
    var _ay        = _sep_y + 10;

    for (var i = 0; i < 4; i++) {
        var _text = _labels[i] + ") " + current_question.answers[i].text;
        var _ah   = string_height_ext(_text, _ans_sep, _ans_w);

        // Destaque de fundo na opção selecionada — mais fácil de enxergar
        // que só a seta
        if (i == selected_option) {
            draw_set_alpha(0.25);
            draw_set_color(make_color_rgb(255, 220, 60));
            draw_rectangle(_qcx, _ay - 3, _qx2 - 6, _ay + _ah + 1, false);
            draw_set_alpha(1);
            draw_set_color(make_color_rgb(255, 220, 60));
            draw_text(_qcx, _ay, ">");
        } else {
            draw_set_color(c_white);
        }

        draw_text_ext(_ans_x, _ay, _text, _ans_sep, _ans_w);
        _ay += _ah + _ans_gap;
    }

    draw_set_font(global.font_main);
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
    case BATTLE_STATE.ATTACK_ANIM:   // mesma caixa; a barra fica congelada onde o jogador apertou
        draw_set_color(c_black);
        draw_rectangle(_box_x1, _box_y1, _box_x2, _box_y2, false);
        draw_set_color(c_white);
        draw_rectangle(_box_x1, _box_y1, _box_x2, _box_y2, true);

        var _lane_y = (_box_y1 + _box_y2) / 2 + 4;
        var _lane_h = 10;
        var _tx1    = attack_lane_x1;
        var _tx2    = attack_lane_x2;

        // Trilha
        draw_set_color(make_color_rgb(60, 60, 60));
        draw_rectangle(_tx1, _lane_y - _lane_h, _tx2, _lane_y + _lane_h, false);

        // Zona OK (verde escuro): mesma largura que o Step usa para aceitar acerto
        draw_set_color(make_color_rgb(30, 100, 30));
        draw_rectangle(attack_target_x - attack_zone_ok, _lane_y - _lane_h,
                       attack_target_x + attack_zone_ok, _lane_y + _lane_h, false);
        draw_set_color(c_green);
        draw_rectangle(attack_target_x - attack_zone_ok, _lane_y - _lane_h,
                       attack_target_x + attack_zone_ok, _lane_y + _lane_h, true);

        // Zona ÓTIMO (verde mais vivo)
        draw_set_color(make_color_rgb(60, 170, 60));
        draw_rectangle(attack_target_x - attack_zone_great, _lane_y - _lane_h + 2,
                       attack_target_x + attack_zone_great, _lane_y + _lane_h - 2, false);

        // Zona PERFEITO (ciano)
        draw_set_color(c_aqua);
        draw_rectangle(attack_target_x - attack_zone_perfect, _lane_y - _lane_h + 3,
                       attack_target_x + attack_zone_perfect, _lane_y + _lane_h - 3, false);

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
            // (o "-N" de dano agora aparece flutuando sobre o inimigo — bloco de EFEITOS no fim)
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

// ══════════════════════════════════════════════════════════════════
// EFEITOS DA ANIMAÇÃO DE ATAQUE — só LEEM a lógica, nunca alteram HP
// Room e GUI têm o mesmo tamanho (320x240, sem views), então as
// coordenadas do inimigo na room valem direto aqui.
// ══════════════════════════════════════════════════════════════════
if (state == BATTLE_STATE.ATTACK_ANIM && anim_hit && anim_impact_done
    && instance_exists(obj_rh_battle_enemy)) {

    var _en    = obj_rh_battle_enemy;
    var _ecx   = _en.x + (sprite_get_width(_en.sprite_index)  * _en.image_xscale) / 2;
    var _ecy   = _en.centro_y + (sprite_get_height(_en.sprite_index) * _en.image_yscale) / 2;
    var _since = anim_timer - ANIM_ATTACK_DURATION;   // frames desde o impacto

    // ── Efeito de impacto (corte) ─────────────────────────────────
    if (_since >= 0 && _since < ANIM_FX_DURATION) {
        if (ANIM_SLOT_ATTACK_FX_SPRITE != noone) {
            // SLOT preenchido: toca o sprite uma vez, sem loop
            var _fxf = floor(_since * ANIM_ATTACK_FX_SPRITE_SPEED);
            if (_fxf < sprite_get_number(ANIM_SLOT_ATTACK_FX_SPRITE)) {
                draw_sprite(ANIM_SLOT_ATTACK_FX_SPRITE, _fxf, _ecx, _ecy);
            }
        } else {
            // Procedural: dois cortes diagonais que crescem e somem
            var _fp  = _since / ANIM_FX_DURATION;
            var _len = 8 + 22 * _fp;
            draw_set_alpha(1 - _fp);
            draw_set_color(c_white);
            draw_line_width(_ecx - _len, _ecy + _len, _ecx + _len, _ecy - _len, 3);
            draw_line_width(_ecx - _len + 6, _ecy + _len + 4, _ecx + _len + 6, _ecy - _len + 4, 1);
            draw_set_alpha(1);
        }
    }

    // ── Número de dano flutuante ──────────────────────────────────
    var _dd = _since - ANIM_DAMAGE_DELAY;             // frames desde que o número apareceu
    if (_dd >= 0 && _dd < ANIM_DAMAGE_DISPLAY_DURATION) {
        var _rise  = ANIM_DAMAGE_RISE_PIXELS * min(1, _dd / 15);
        var _alpha = 1;
        if (_dd > ANIM_DAMAGE_DISPLAY_DURATION - 15) {
            _alpha = (ANIM_DAMAGE_DISPLAY_DURATION - _dd) / 15;   // some nos últimos 15 frames
        }
        var _dtxt = "-" + string(attack_damage);
        var _dy   = _en.centro_y - 6 - _rise;

        draw_set_font(global.font_main);
        draw_set_halign(fa_center);
        draw_set_alpha(_alpha);
        draw_set_color(c_black);
        draw_text(_ecx + 1, _dy + 1, _dtxt);
        draw_set_color(make_color_rgb(255, 220, 60));
        draw_text(_ecx, _dy, _dtxt);
        draw_set_alpha(1);
        draw_set_halign(fa_left);
    }
}

// Reset
draw_set_halign(fa_left);
draw_set_color(c_white);
draw_set_alpha(1);