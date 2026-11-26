// Desenho sempre igual à máscara: girado com image_angle quando há rotação,
// recortado quando o osso já parou de girar.
if (image_angle != 0) {
    draw_sprite_ext(sprite_index, image_index, x, y,
                    image_xscale, image_yscale, image_angle, image_blend, image_alpha);
} else if (clip_to_box) {
    rh_draw_clipped(sprite_index, image_index, x, y,
                    image_xscale, image_yscale, image_blend, image_alpha);
} else {
    draw_self();
}

if (RH_ATK_DEBUG_ZONES && active) {
    draw_set_color(c_red);
    draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);
    draw_set_color(c_white);
}
