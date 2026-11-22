if (clip_to_box) {
    rh_draw_clipped(sprite_index, image_index, x, y, image_xscale, image_yscale, image_blend, image_alpha);
} else {
    draw_self();
}

// Debug: contorna o que está machucando agora (RH_ATK_DEBUG_ZONES em scr_rh_attacks)
if (RH_ATK_DEBUG_ZONES && active) {
    draw_set_color(c_red);
    draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);
    draw_set_color(c_white);
}
