// (x,y) é o centro do sprite: rh_draw_clipped_ext centraliza a origem e recorta na caixa.
rh_draw_clipped_ext(sprite_index, image_index, x, y,
                    image_xscale, image_yscale, 0, c_white, image_alpha);

if (RH_ATK_DEBUG_ZONES && active) {
    var _hw = sprite_width  * 0.8 / 2;
    var _hh = sprite_height * 0.8 / 2;
    draw_set_color(c_red);
    draw_rectangle(x - _hw, y - _hh, x + _hw, y + _hh, true);
    draw_set_color(c_white);
}
