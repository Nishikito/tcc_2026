if (clip_to_box) rh_draw_clipped(sprite_index, image_index, x, y, image_xscale, image_yscale, image_blend, image_alpha); else draw_self();
if (t < warn_t) rh_draw_warning(zone_x, by1, zone_x + zone_w, by2, t);
if (zone_made) {
    draw_set_color(c_red);
    draw_line(zone_x, by2 - 2, zone_x + zone_w, by2 - 2);
    draw_set_color(c_white);
}