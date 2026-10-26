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
        // ── GOLPE: prepara (recua) → solta o orbe (pose do livro) → volta ──
        // O Talai NÃO avança: quem viaja até o inimigo é o orbe (bloco PROJÉTIL, mais abaixo).
        _talai_dy = 0;
        if (anim_timer < ANIM_ATTACK_WINDUP_FRAMES) {
            // Preparando: inclina para trás
            var _w = anim_timer / ANIM_ATTACK_WINDUP_FRAMES;   // 0..1
            _talai_dx    = -ANIM_TALAI_WINDUP_PIXELS * _w;
            _talai_angle = 10 * _w;
        } else {
            // Soltou o orbe: volta à posição
            var _r = clamp((anim_timer - ANIM_ATTACK_WINDUP_FRAMES) / ANIM_TALAI_RETURN_FRAMES, 0, 1);
            _talai_dx    = lerp(-ANIM_TALAI_WINDUP_PIXELS, 0, _r);
            _talai_angle = lerp(10, 0, _r);

            // SLOT: pose de ataque (livro estendido) só enquanto "segura" o lançamento
            if (ANIM_SLOT_TALAI_ATTACK_SPRITE != noone
                && anim_timer < ANIM_ATTACK_WINDUP_FRAMES + ANIM_ATTACK_POSE_HOLD_FRAMES) {
                _talai_spr = ANIM_SLOT_TALAI_ATTACK_SPRITE;
                _talai_img = min(floor((anim_timer - ANIM_ATTACK_WINDUP_FRAMES) * ANIM_TALAI_ATTACK_SPRITE_SPEED),
                                 sprite_get_number(_talai_spr) - 1);
            }
        }
    } else {
        // Errou por tempo: mantém a pose do minigame, sem golpe
        _talai_angle = -15;
        _talai_dy    = -4;
    }
} else if (state == BATTLE_STATE.ENEMY_TURN) {
    _talai_dy = 2;       // recua ao defender
}

// Talai atingido por uma bala: sprite de dano + tremidinha lateral
// (tem prioridade sobre as outras poses; o hit só acontece no ENEMY_TURN)
if (talai_hit_timer > 0) {
    _talai_spr = ANIM_SLOT_TALAI_HIT_SPRITE;
    _talai_img = 0;
    if ((talai_hit_timer div 3) mod 2 == 0) {
        _talai_dx = -ANIM_TALAI_HIT_SHAKE_PIXELS;
    } else {
        _talai_dx =  ANIM_TALAI_HIT_SHAKE_PIXELS;
    }
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

// Barra vertical de média em SPRITE (fundo + preenchimento que cresce de baixo para cima).
// O preenchimento usa a cor original do sprite com média acima do limite e fica
// avermelhado abaixo dele. A linha branca marca o limite (KNOWLEDGE_PASS_THRESHOLD).
var _tp_w    = sprite_get_width(UI_SLOT_AVG_BAR_BASE_SPRITE);
var _tp_h    = sprite_get_height(UI_SLOT_AVG_BAR_BASE_SPRITE);
var _tp_fill = clamp(global.knowledge_average / 10.0, 0, 1);
var _fill_h  = round(_tp_h * _tp_fill);      // altura preenchida, em pixels do sprite
var _fill_y0 = _tp_h - _fill_h;              // onde o preenchimento começa dentro do sprite

draw_sprite(UI_SLOT_AVG_BAR_BASE_SPRITE, 0, UI_AVG_BAR_X, UI_AVG_BAR_Y);
if (_fill_h > 0) {
    var _fill_tint = c_white;
    if (global.knowledge_average <= KNOWLEDGE_PASS_THRESHOLD) _fill_tint = make_color_rgb(255, 90, 90);
    draw_sprite_part_ext(UI_SLOT_AVG_BAR_FILL_SPRITE, 0, 0, _fill_y0, _tp_w, _fill_h,
                         UI_AVG_BAR_X, UI_AVG_BAR_Y + _fill_y0, 1, 1, _fill_tint, 1);
}

// Marca do limite de aprovação
var _tick_y = UI_AVG_BAR_Y + _tp_h - round(_tp_h * KNOWLEDGE_PASS_THRESHOLD / 10.0);
draw_set_color(c_white);
draw_rectangle(UI_AVG_BAR_X, _tick_y, UI_AVG_BAR_X + _tp_w - 1, _tick_y, false);

// ══════════════════════════════════════════════════════════════════
// HUD INFERIOR — estilo Deltarune
// Linha de info do personagem + caixa de diálogo + botões de ação
// ══════════════════════════════════════════════════════════════════
var _hud_y   = 170;    // onde começa o HUD inferior
var _hud_h   = _gh - _hud_y; // altura disponível

// Fundo do HUD (a linha separadora branca saiu: a moldura do painel já tem borda)
draw_set_color(c_black);
draw_rectangle(0, _hud_y, _gw, _gh, false);

// ── PAINEL DO TALAI ───────────────────────────────────────────────
// Moldura em sprite esticada na largura da tela. Layout: HP à esquerda,
// NOME NO CENTRO, números à direita (a batalha tem um único personagem).
var _pn_top = _hud_y + 1;     // topo da arte da moldura
var _pn_h   = 17;             // altura da arte do frame 0 (compacto)
var _pn_cy  = _pn_top + _pn_h / 2;   // centro vertical do painel
draw_ui_frame(0, 0, _pn_top, _gw, _pn_h, c_white);

var _hp_pct = clamp(global.hp / global.max_hp, 0, 1);
var _ts     = 0.85;           // escala do texto do painel
draw_set_valign(fa_middle);

// HP (esquerda): rótulo + barra
draw_set_color(UI_COLOR_HP_LABEL);
draw_text_transformed(10, _pn_cy, "HP", _ts, _ts, 0);

var _hbx = 28, _hbw = 80, _hbh = 5;
var _hby = _pn_cy - _hbh / 2;
draw_set_color(make_color_rgb(40, 40, 40));
draw_rectangle(_hbx, _hby, _hbx + _hbw, _hby + _hbh - 1, false);

var _hp_color;
if (_hp_pct > 0.5)       _hp_color = make_color_rgb(255, 220, 60);  // amarelo
else if (_hp_pct > 0.25) _hp_color = make_color_rgb(255, 140, 0);   // laranja
else                     _hp_color = make_color_rgb(255, 40,  40);  // vermelho
draw_set_color(_hp_color);
draw_rectangle(_hbx, _hby, _hbx + round(_hbw * _hp_pct), _hby + _hbh - 1, false);

// Nome (CENTRO)
draw_set_halign(fa_center);
draw_set_color(c_white);
draw_text_transformed(_gw / 2, _pn_cy, global.player_name, 1, 1, 0);

// Números (direita)
draw_set_halign(fa_right);
draw_text_transformed(_gw - 10, _pn_cy, string(global.hp) + "/" + string(global.max_hp), _ts, _ts, 0);

draw_set_halign(fa_left);
draw_set_valign(fa_top);

// ── CAIXA DE DIÁLOGO / AÇÃO ───────────────────────────────────────
var _box_y1 = _hud_y + 26;
var _box_y2 = _gh - 22;
var _box_x1 = 4;
var _box_x2 = _gw - 4;

// Caixa: fundo preto por código + borda em moldura de sprite
draw_set_color(c_black);
draw_rectangle(_box_x1, _box_y1, _box_x2, _box_y2, false);
draw_ui_frame(1, _box_x1, _box_y1, _box_x2 - _box_x1 + 1, _box_y2 - _box_y1 + 1, c_white);

// ── BOTÕES DE COMANDO (ícone em sprite + nome) ────────────────────
// frame normal = menu_icon_frames[i] | selecionado = +4. Só o MENU destaca a opção.
var _cmd_y = _gh - 20;
draw_set_valign(fa_middle);
for (var i = 0; i < array_length(menu_names); i++) {
    var _cmd_x   = 28 + i * 100;
    var _cmd_sel = (i == menu_option && state == BATTLE_STATE.MENU);
    var _cmd_img = menu_icon_frames[i];
    if (_cmd_sel) _cmd_img += 4;

    draw_sprite(UI_SLOT_COMMAND_SPRITE, _cmd_img, _cmd_x, _cmd_y);

    if (_cmd_sel) draw_set_color(UI_COLOR_SELECTED);
    else          draw_set_color(c_white);
    draw_text_transformed(_cmd_x + 21, _cmd_y + 6.5, menu_names[i], 0.9, 0.9, 0);
}
draw_set_valign(fa_top);

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
    draw_ui_frame(1, _qx1, _qy1, _qx2 - _qx1 + 1, _qy2 - _qy1 + 1, c_white);

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
            draw_ui_cursor(_qcx, _ay + 1);   // coração em sprite (antes: ">")
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
        draw_ui_frame(1, _box_x1, _box_y1, _box_x2 - _box_x1 + 1, _box_y2 - _box_y1 + 1, _score_color);   // borda tingida pela nota

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
        draw_ui_frame(1, _box_x1, _box_y1, _box_x2 - _box_x1 + 1, _box_y2 - _box_y1 + 1, c_white);

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

    // ── MENU DE ITENS (painel grande, igual ao da QUESTION) ───────
    case BATTLE_STATE.ITEM_MENU:
        var _ix1 = 4;
        var _ix2 = _gw - 4;
        var _iy1 = 4;
        var _iy2 = _gh - 4;

        draw_set_color(c_black);
        draw_rectangle(_ix1, _iy1, _ix2, _iy2, false);
        draw_ui_frame(1, _ix1, _iy1, _ix2 - _ix1 + 1, _iy2 - _iy1 + 1, c_white);

        draw_set_font(global.font_main);

        // Cabeçalho: título + HP atual (útil pra decidir se vale curar)
        draw_set_color(c_white);
        draw_text(_ix1 + 10, _iy1 + 8, "ITENS");
        draw_set_halign(fa_right);
        draw_text(_ix2 - 10, _iy1 + 8, "HP " + string(global.hp) + "/" + string(global.max_hp));
        draw_set_halign(fa_left);

        var _list_y  = _iy1 + 30;
        var _row_h   = 18;
        var _n_items = array_length(global.inventory_consumables);

        if (_n_items == 0) {
            draw_set_color(make_color_rgb(160, 160, 160));
            draw_text(_ix1 + 10, _list_y, "(sem consumíveis)");
        } else {
            var _last_row = min(_n_items, item_view_top + item_rows_visible);
            for (var _item_r = item_view_top; _item_r < _last_row; _item_r++) {
                var _it  = global.inventory_consumables[_item_r];
                var _ry  = _list_y + (_item_r - item_view_top) * _row_h;

                if (_item_r == item_sel) {
                    draw_set_alpha(0.25);
                    draw_set_color(make_color_rgb(255, 220, 60));
                    draw_rectangle(_ix1 + 6, _ry - 3, _ix2 - 6, _ry + _row_h - 5, false);
                    draw_set_alpha(1);
                    draw_set_color(make_color_rgb(255, 220, 60));
                    draw_ui_cursor(_ix1 + 10, _ry + 1);   // coração em sprite (antes: ">")
                } else {
                    draw_set_color(c_white);
                }
                draw_text(_ix1 + 24, _ry, _it.name);
                draw_set_halign(fa_right);
                draw_text(_ix2 - 14, _ry, "x" + string(_it.qty));
                draw_set_halign(fa_left);
            }

            // Setas de rolagem (só aparecem se tem mais itens fora da janela)
            draw_set_color(c_white);
            if (item_view_top > 0) {
                draw_text(_ix2 - 8, _list_y, "^");
            }
            if (item_view_top + item_rows_visible < _n_items) {
                draw_text(_ix2 - 8, _list_y + (item_rows_visible - 1) * _row_h, "v");
            }

            // Descrição do item selecionado
            var _desc_y = _list_y + item_rows_visible * _row_h + 8;
            draw_set_color(make_color_rgb(60, 60, 60));
            draw_rectangle(_ix1 + 6, _desc_y - 4, _ix2 - 6, _desc_y - 3, false);
            draw_set_color(make_color_rgb(200, 200, 200));
            draw_text_ext(_ix1 + 10, _desc_y,
                global.inventory_consumables[item_sel].description,
                12, (_ix2 - _ix1) - 20);
        }

        // Mensagem de feedback ("HP já está cheio!")
        if (item_msg_timer > 0) {
            draw_set_color(make_color_rgb(255, 220, 60));
            draw_text(_ix1 + 10, _iy2 - 34, item_msg);
        }

        // Rodapé com os controles
        draw_set_color(make_color_rgb(160, 160, 160));
        draw_text(_ix1 + 10, _iy2 - 18, "[Z] Usar   [X] Voltar");
        break;

    case BATTLE_STATE.ENEMY_TURN:
        draw_set_color(c_white);
        if (item_used_name != "") {
            draw_text_ext(_cx1, _cy1, "* Você usou " + item_used_name + "!", 12, _cw);
        } else if (is_defending) {
            draw_text_ext(_cx1, _cy1, "* Você se defende! " + enemy_name + " ataca!", 12, _cw);
        } else {
            draw_text_ext(_cx1, _cy1, "* " + enemy_name + " ataca!", 12, _cw);
        }
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
// PROJÉTIL DO TALAI (VISUAL) — orbe que sai do livro e viaja até o inimigo
// Só DESENHA. O dano já foi decidido no clique; o IMPACTO (ANIM_ATTACK_DURATION)
// é o instante em que o orbe chega, e é nele que o Step dispara a reação do inimigo.
// ══════════════════════════════════════════════════════════════════
if (state == BATTLE_STATE.ATTACK_ANIM && anim_swing
    && ANIM_SLOT_PROJECTILE_SPRITE != noone
    && instance_exists(obj_rh_battle_enemy)
    && anim_timer >= ANIM_ATTACK_WINDUP_FRAMES) {

    var _pen = obj_rh_battle_enemy;

    // De onde sai (ponta do livro) e para onde vai (centro do inimigo)
    var _sx = _talai_x + ANIM_PROJECTILE_BOOK_OFFSET_X;
    var _sy = _talai_y + ANIM_PROJECTILE_BOOK_OFFSET_Y;
    var _tx = _pen.x        + (sprite_get_width(_pen.sprite_index)  / 2 - sprite_get_xoffset(_pen.sprite_index)) * _pen.image_xscale;
	var _ty = _pen.centro_y + (sprite_get_height(_pen.sprite_index) / 2 - sprite_get_yoffset(_pen.sprite_index)) * _pen.image_yscale;

    // u: 0 = acabou de sair do livro | 1 = chegou no inimigo | >1 = passou direto (só no erro)
    var _u = (anim_timer - ANIM_ATTACK_WINDUP_FRAMES) / ANIM_PROJECTILE_TRAVEL_FRAMES;

    var _pvisible = true;
    if (anim_hit) {
        if (anim_timer >= ANIM_ATTACK_DURATION) _pvisible = false;   // chegou: o impacto assume
    } else if (!ANIM_PROJECTILE_FLIES_ON_MISS) {
        _pvisible = false;
    }

    // lerp NÃO limita em 1: no erro o orbe continua na mesma reta até sair da tela
    var _bx = lerp(_sx, _tx, _u);
    var _by = lerp(_sy, _ty, _u);
    if (_bx > _gw + 30 || _by < -30 || _by > _gh + 30) _pvisible = false;

    if (_pvisible) {
        var _pang = point_direction(_sx, _sy, _tx, _ty);   // o sprite aponta para a direita (0°)
        var _pw   = sprite_get_width(ANIM_SLOT_PROJECTILE_SPRITE)  * ANIM_PROJECTILE_SCALE;
        var _ph   = sprite_get_height(ANIM_SLOT_PROJECTILE_SPRITE) * ANIM_PROJECTILE_SCALE;

        // O sprite tem origem no canto (0,0). Para girar em torno do CENTRO (e o centro
        // ficar em _bx,_by), recuamos do centro até o canto, já considerando o giro.
        var _plen = point_distance(0, 0, _pw / 2, _ph / 2);
        var _pdir = point_direction(0, 0, _pw / 2, _ph / 2) + _pang;

        draw_sprite_ext(ANIM_SLOT_PROJECTILE_SPRITE, 0,
                        _bx - lengthdir_x(_plen, _pdir),
                        _by - lengthdir_y(_plen, _pdir),
                        ANIM_PROJECTILE_SCALE, ANIM_PROJECTILE_SCALE,
                        _pang, c_white, 1);
    }
}

// ══════════════════════════════════════════════════════════════════
// EFEITOS DA ANIMAÇÃO DE ATAQUE — só LEEM a lógica, nunca alteram HP
// Room e GUI têm o mesmo tamanho (320x240, sem views), então as
// coordenadas do inimigo na room valem direto aqui.
// ══════════════════════════════════════════════════════════════════
if (state == BATTLE_STATE.ATTACK_ANIM && anim_hit && anim_impact_done
    && instance_exists(obj_rh_battle_enemy)) {

    var _en    = obj_rh_battle_enemy;
    var _ecx = _en.x        + (sprite_get_width(_en.sprite_index)  / 2 - sprite_get_xoffset(_en.sprite_index)) * _en.image_xscale;
	var _ecy = _en.centro_y + (sprite_get_height(_en.sprite_index) / 2 - sprite_get_yoffset(_en.sprite_index)) * _en.image_yscale;
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
