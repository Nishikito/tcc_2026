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

#macro RH_ATK_DEBUG_ZONES   false   // true = contorna em vermelho tudo que está machucando (para testar)

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
/// Cria um ataque na layer "Bullets" (ou, se ela não existir, em depth 200),
/// do mesmo jeito que o inimigo antigo cria suas balas. Devolve a instância.
/// Ajuste as variáveis do ataque DEPOIS de criar (ex.: _a.vy = 2).
function rh_spawn_attack(_obj, _x, _y) {
    if (layer_exists("Bullets")) return instance_create_layer(_x, _y, "Bullets", _obj);
    return instance_create_depth(_x, _y, 200, _obj);
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
