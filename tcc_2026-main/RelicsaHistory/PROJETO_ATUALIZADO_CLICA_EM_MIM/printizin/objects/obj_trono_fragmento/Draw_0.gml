// Mesmo recorte da caixa usado pela coroa, para o estilhaço não aparecer solto na tela.
rh_draw_clipped(sprite_index, image_index, x, y,
                image_xscale, image_yscale, image_blend, image_alpha);

if (RH_ATK_DEBUG_ZONES && active && !was_hit) {
    draw_set_color(c_red);
    draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);
    draw_set_color(c_white);
}
