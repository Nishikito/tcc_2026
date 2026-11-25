if (clip_to_box) rh_draw_clipped(sprite_index, image_index, x, y, image_xscale, image_yscale, image_blend, image_alpha); else draw_self();
if (is_true) {
    draw_set_alpha(0.75 + 0.25 * dsin(t * 8));
    draw_set_color(c_red);
    var _w = sprite_get_width(sprite_index)  * image_xscale;
    var _h = sprite_get_height(sprite_index) * image_yscale;
    draw_rectangle(x, y, x + _w, y + _h, true);
    draw_line(x, y + _h - 2, x + _w, y + _h - 2);
    draw_set_alpha(1);
    draw_set_color(c_white);
}