if (TRANSITION_DEBUG) {
    draw_set_color(c_white);
    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
    draw_text_transformed(8, 8,
        "fase " + string(phase) + "  t " + string(timer)
        + "  p_spr " + string(p_spr) + "  e_spr " + string(e_spr)
        + "  gui " + string(display_get_gui_width()) + "x" + string(display_get_gui_height()),
        2, 2, 0);
}