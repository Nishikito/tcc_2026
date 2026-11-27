if (estado == 0) {
    // Aviso no chão, do lado por onde o cachorro vai entrar.
    var _x1 = (dir > 0) ? bx1 : bx2 - 26;
    var _x2 = (dir > 0) ? bx1 + 26 : bx2;
    var _chao = by2 - 2;
    rh_draw_warning_line(_x1, _chao, _x2, _chao, 3, t);
    rh_draw_warning_rect(_x1, by2 - altura - 2, _x2, by2, t);
} else if (estado != 3 || t < t_fim + 4) {
    rh_draw_clipped(sprite_index, image_index, x, y,
                    image_xscale, image_yscale, image_blend, image_alpha);

    if (estado == 2) {
        // Leve squash/stretch na cabeça, desenhada por código sobre o corpo.
        var _cabeca_u = 18;
        var _src_x = (dir > 0) ? (sprite_get_width(sprite_index) - _cabeca_u) : 0;
        var _dx = x + _src_x * image_xscale;
        var _p  = t_parada / max(1, tempo_parada);
        var _st = 1 + 0.10 * dsin(_p * 360);
        draw_sprite_part_ext(sprite_index, image_index,
                             _src_x, 0, _cabeca_u, sprite_get_height(sprite_index),
                             _dx, y, image_xscale * _st, image_yscale / _st,
                             image_blend, image_alpha);
    }
}

if (RH_ATK_DEBUG_ZONES && (estado == 1 || estado == 2)) {
    var _hw = largura * 0.85;
    var _hh = altura  * 0.85;
    draw_set_color(c_red);
    draw_rectangle(x + (largura - _hw) / 2, y + (altura - _hh) / 2,
                   x + (largura + _hw) / 2, y + (altura + _hh) / 2, true);
    draw_set_color(c_white);
}
