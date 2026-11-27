// Fora da caixa (RH_BAU_DENTRO == false) o baú é desenhado inteiro, abaixo da borda.
if (RH_BAU_DENTRO) {
    rh_draw_clipped(sprite_index, image_index, x, y,
                    image_xscale, image_yscale, image_blend, image_alpha);
} else {
    draw_self();
}

// Flash curto da explosão.
if (estado == 1 && pop > 0) {
    var _bw = sprite_get_width(sprite_index)  * image_xscale;
    var _bh = sprite_get_height(sprite_index) * image_yscale;
    draw_set_alpha((pop / 6) * 0.55);
    draw_set_color(c_white);
    draw_rectangle(x - 3, y - 3, x + _bw + 3, y + _bh + 3, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

if (RH_ATK_DEBUG_ZONES && estado == 0) {
    draw_set_color(c_red);
    draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);
    draw_set_color(c_white);
}
