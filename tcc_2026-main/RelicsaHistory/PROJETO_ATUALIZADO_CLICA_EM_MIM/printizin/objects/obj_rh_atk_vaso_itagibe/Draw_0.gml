// Aviso do vaso (ele treme no Step, então a faixa treme junto).
if (estado == "aviso") {
    var _w = sprite_get_width(sprite_index);
    var _h = sprite_get_height(sprite_index);
    rh_draw_warning_rect(x, y, x + _w, y + _h, t);
    rh_draw_warning_line(x + _w / 2, y - 4, x + _w / 2, y, t);
}

if (clip_to_box) {
    rh_draw_clipped(sprite_index, image_index, x, y, image_xscale, image_yscale, image_blend, image_alpha);
} else {
    draw_self();
}
