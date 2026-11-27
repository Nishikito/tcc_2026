if (puff > 0) {
    // Puff: um brilho curto que cresce e some, já dentro da caixa.
    draw_set_alpha((puff / 6) * 0.7);
    draw_set_color(c_white);
    draw_circle(x + largura / 2, y + altura / 2, 3 + (6 - puff) * 1.5, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
    exit;
}

rh_draw_clipped_ext(sprite_index, image_index, x, y,
                    image_xscale, image_yscale, image_angle, image_blend, image_alpha);

if (RH_ATK_DEBUG_ZONES && !was_hit) {
    draw_set_color(c_red);
    draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);
    draw_set_color(c_white);
}
