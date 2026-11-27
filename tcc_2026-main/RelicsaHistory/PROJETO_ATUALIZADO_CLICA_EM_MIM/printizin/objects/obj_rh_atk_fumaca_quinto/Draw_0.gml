rh_draw_clipped(sprite_index, image_index, x, y,
                image_xscale, image_yscale, image_blend, image_alpha);

if (RH_ATK_DEBUG_ZONES && t <= vida_fumaca - 8) {
    var _w = sprite_get_width(sprite_index)  * image_xscale;
    var _h = sprite_get_height(sprite_index) * image_yscale;
    var _hw = _w * 0.6;
    var _hh = _h * 0.8;
    draw_set_color(c_red);
    draw_rectangle(x + (_w - _hw) / 2, y + _h - _hh,
                   x + (_w + _hw) / 2, y + _h, true);
    draw_set_color(c_white);
}
