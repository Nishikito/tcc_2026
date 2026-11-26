// ══════════════════════════════════════════════════════════════════
// ATAQUES VARIADOS (inspirados nos padrões de Undertale) — funções e macros comuns
// ──────────────────────────────────────────────────────────────────
// Quem usa: todos os obj_rh_atk_* (projéteis/ataques) e obj_rh_en_* (inimigos).
// Regra de ouro: TODO ataque é "filho" de obj_rh_battle_bullet. Assim o coração
// (obj_rh_battle_player) e o controller continuam funcionando sem mudanças:
//   - o coração só machuca ataques com active == true, UMA vez por ataque;
//   - o controller apaga todos os filhos de obj_rh_battle_bullet no fim do turno.
// Manual: ATAQUES_VARIADOS.md (na pasta do projeto).
// ══════════════════════════════════════════════════════════════════

#macro RH_BULLET_DEPTH      1   // projéteis: à frente da caixa (10), atrás do coração (-1)

#macro RH_ATK_DEBUG_ZONES   false   // true = contorna em vermelho tudo que está machucando (para testar)

// ── DIAGNÓSTICO DE ATAQUES (Tarefa 1) ─────────────────────────────
// Mude para true (e, se quiser, RH_DEBUG_FORCE_PATTERN para 0..2) para ver no Output:
// início de turno, padrão escolhido, cada spawn, cada destruição e o motivo.
#macro RH_DEBUG               false
#macro RH_DEBUG_FORCE_PATTERN -1     // -1 = normal; 0, 1, 2... = força esse índice

function rh_debug(_msg) {
    if (RH_DEBUG) show_debug_message("[RH] " + string(_msg));
}

function rh_debug_spawn(_obj, _x, _y) {
    if (RH_DEBUG) {
        show_debug_message("[RH][SPAWN] " + object_get_name(_obj)
                           + " @ " + string(round(_x)) + "," + string(round(_y)));
    }
}

function rh_debug_destroy(_reason) {
    if (RH_DEBUG) {
        show_debug_message("[RH][DESTROY] " + object_get_name(object_index)
                           + " id=" + string(id) + " | motivo: " + string(_reason));
    }
}

/// Distância do centro do coração até um segmento (usada pelo raio do canhão).
function rh_dist_to_segment(_px, _py, _x1, _y1, _x2, _y2) {
    var _dx = _x2 - _x1;
    var _dy = _y2 - _y1;
    var _len2 = _dx * _dx + _dy * _dy;
    if (_len2 <= 0) return point_distance(_px, _py, _x1, _y1);
    var _u = ((_px - _x1) * _dx + (_py - _y1) * _dy) / _len2;
    _u = clamp(_u, 0, 1);
    return point_distance(_px, _py, _x1 + _dx * _u, _y1 + _dy * _u);
}

/// Gira _cur em direção a _target no máximo _max graus (curva limitada da mordida).
function rh_approach_angle(_cur, _target, _max) {
    var _dif = angle_difference(_target, _cur);
    return _cur + clamp(_dif, -_max, _max);
}

/// Desenha um sprite com o PIVÔ em (_px,_py), em vez da origem do arquivo.
/// Necessário para o martelo: a haste nasce no canto inferior esquerdo do arquivo.
function rh_draw_sprite_pivot(_spr, _px, _py, _pivot_x, _pivot_y, _angle, _xs, _ys, _col, _alpha) {
    var _vx = _pivot_x * _xs;
    var _vy = _pivot_y * _ys;
    var _len = point_distance(0, 0, _vx, _vy);
    var _dir = point_direction(0, 0, _vx, _vy) + _angle;
    draw_sprite_ext(_spr, 0,
                    _px - lengthdir_x(_len, _dir),
                    _py - lengthdir_y(_len, _dir),
                    _xs, _ys, _angle, _col, _alpha);
}

/// rh_box_inner()
/// Retângulo INTERNO da Battle Box (onde o coração se move), em pixels da room.
/// Devolve { x1, y1, x2, y2 }.
function rh_box_inner() {
    if (!instance_exists(obj_rh_battle_box)) {
        return { x1: 106, y1: 65, x2: 204, y2: 143 };
    }
    var _b = obj_rh_battle_box;
    return {
        x1: _b.x + BOX_BORDER_PIXELS,
        y1: _b.y + BOX_BORDER_PIXELS,
        x2: _b.x + sprite_get_width(_b.sprite_index)  - BOX_BORDER_PIXELS,
        y2: _b.y + sprite_get_height(_b.sprite_index) - BOX_BORDER_PIXELS
    };
}

/// rh_heart_x() / rh_heart_y()
/// Posição do coração (ou o centro da caixa se ele ainda não existe).
function rh_heart_x() {
    if (instance_exists(obj_rh_battle_player)) return obj_rh_battle_player.x;
    var _r = rh_box_inner();
    return (_r.x1 + _r.x2) / 2;
}
function rh_heart_y() {
    if (instance_exists(obj_rh_battle_player)) return obj_rh_battle_player.y;
    var _r = rh_box_inner();
    return (_r.y1 + _r.y2) / 2;
}

/// rh_spawn_attack(objeto, x, y)
/// Cria um ataque na layer "Bullets" (depth RH_BULLET_DEPTH na rm_rh_battle;
/// se ela não existir, cria em depth 200 e sobe para RH_BULLET_DEPTH).
/// Devolve a instância.
/// Ajuste as variáveis do ataque DEPOIS de criar (ex.: _a.vy = 2).
function rh_spawn_attack(_obj, _x, _y) {
    rh_debug_spawn(_obj, _x, _y);
    var _inst;
    if (layer_exists("Bullets")) _inst = instance_create_layer(_x, _y, "Bullets", _obj);
    else                         _inst = instance_create_depth(_x, _y, 200, _obj);

    // Na rm_rh_battle a layer "Bullets" já está em RH_BULLET_DEPTH (1), à frente
    // da caixa (10). Se a room não tiver a layer, o fallback cria em 200 e aqui
    // o tiro sobe. Quem define depth próprio no Create (martelo/bota = -5) fica.
    if (_inst.depth == 200) _inst.depth = RH_BULLET_DEPTH;
    return _inst;
}

/// rh_draw_clipped(sprite, quadro, x, y, xscale, yscale, cor, alpha)
/// Desenha o sprite SÓ dentro da Battle Box: o ataque "entra" pela borda da caixa
/// em vez de aparecer solto na tela. (Origem do sprite = canto superior esquerdo.)
function rh_draw_clipped(_spr, _img, _x, _y, _xs, _ys, _col, _alpha) {
    var _r  = rh_box_inner();
    _x = round(_x);
    _y = round(_y);
    var _w  = sprite_get_width(_spr);
    var _h  = sprite_get_height(_spr);
    var _dx1 = max(_x, _r.x1);
    var _dy1 = max(_y, _r.y1);
    var _dx2 = min(_x + _w * _xs, _r.x2);
    var _dy2 = min(_y + _h * _ys, _r.y2);
    if (_dx2 <= _dx1 || _dy2 <= _dy1) return;
    draw_sprite_part_ext(_spr, _img,
                         (_dx1 - _x) / _xs, (_dy1 - _y) / _ys,
                         (_dx2 - _dx1) / _xs, (_dy2 - _dy1) / _ys,
                         _dx1, _dy1, _xs, _ys, _col, _alpha);
}

/// rh_draw_warning(x1, y1, x2, y2, tempo)
/// Retângulo vermelho piscando: o AVISO de onde o golpe vai cair (justiça: o jogador
/// precisa ver antes). "tempo" = frames desde o início do aviso.
function rh_draw_warning(_x1, _y1, _x2, _y2, _t) {
    var _a = 0.22;
    if (((_t div 4) mod 2) == 0) _a = 0.45;
    draw_set_alpha(_a);
    draw_set_color(c_red);
    draw_rectangle(_x1, _y1, _x2, _y2, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

/// rh_draw_warning_rect(x1, y1, x2, y2, tempo)
/// Faixa vermelha piscando (mesma linguagem visual de rh_draw_warning), usada
/// pelas raias/colunas do Itagibe. "tempo" = frames desde o início do aviso.
function rh_draw_warning_rect(_x1, _y1, _x2, _y2, _t) {
    var _a = 0.18;
    if (((_t div 4) mod 2) == 0) _a = 0.38;
    draw_set_alpha(_a);
    draw_set_color(c_red);
    draw_rectangle(_x1, _y1, _x2, _y2, false);
    draw_set_alpha(min(1, _a + 0.22));
    draw_rectangle(_x1, _y1, _x2, _y2, true);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

/// rh_draw_warning_line(x1, y1, x2, y2, tempo)
/// Linha fina central dentro da faixa de aviso: reforça a direção do golpe reto.
function rh_draw_warning_line(_x1, _y1, _x2, _y2, _t) {
    var _a = 0.34;
    if (((_t div 4) mod 2) == 0) _a = 0.68;
    draw_set_alpha(_a);
    draw_set_color(c_red);
    draw_line_width(_x1, _y1, _x2, _y2, 2);
    draw_set_alpha(1);
    draw_set_color(c_white);
}
