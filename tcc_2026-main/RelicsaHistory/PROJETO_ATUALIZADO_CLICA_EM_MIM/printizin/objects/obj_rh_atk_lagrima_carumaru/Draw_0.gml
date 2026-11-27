if (t <= warn_t && modo != "splash") {
    if (modo == "fileira") {
        // Um marcador no topo por coluna (aviso 18 frames antes da queda).
        rh_draw_warning(x - 2, by1, x + sprite_width + 2, by1 + 6, t);
    } else {
        // Arco: faixa no topo da caixa avisando a salva inteira (16 frames).
        rh_draw_warning_line(bx1, by1, bx2, by1, 2, t);
    }
} else {
    rh_draw_clipped(sprite_index, image_index, x, y,
                    image_xscale, image_yscale, image_blend, image_alpha);
}

if (RH_ATK_DEBUG_ZONES && active) {
    var _hw = sprite_width  * 0.85 / 2;
    var _hh = sprite_height * 0.85 / 2;
    var _cx = x + sprite_width  / 2;
    var _cy = y + sprite_height / 2;
    draw_set_color(c_red);
    draw_rectangle(_cx - _hw, _cy - _hh, _cx + _hw, _cy + _hh, true);
    draw_set_color(c_white);
}
