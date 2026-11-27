// Aviso: faixa vermelha piscando na altura travada, antes da entrada.
if (estado == 0) {
    rh_draw_warning_rect(bx1, y_travada, bx2,
                         y_travada + sprite_get_height(sprite_index), t);
}

if (clip_to_box) {
    rh_draw_clipped(sprite_index, image_index, x, y, image_xscale, image_yscale, image_blend, image_alpha);
} else {
    draw_self();
}
