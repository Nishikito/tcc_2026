// Aviso na base: sombra/faixa vermelha mostrando de onde o iceberg vai subir.
if (estado == 0) {
    var _h = sprite_get_height(sprite_index);
    rh_draw_warning_rect(x, y_base + _h - 6, x + sprite_get_width(sprite_index), y_base + _h, t);
}

if (clip_to_box) {
    rh_draw_clipped(sprite_index, image_index, x, y, image_xscale, image_yscale, image_blend, image_alpha);
} else {
    draw_self();
}
