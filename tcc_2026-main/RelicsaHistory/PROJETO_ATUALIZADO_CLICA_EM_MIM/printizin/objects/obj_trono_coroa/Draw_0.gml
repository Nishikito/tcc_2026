// Aviso: linha piscando do boss até a caixa, na direção em que a coroa vai andar.
if (estado == 0) {
    rh_draw_warning_line(orig_x, orig_y,
                         orig_x + lengthdir_x(150, dir),
                         orig_y + lengthdir_y(150, dir),
                         2, t);
}

// Desenho recortado: a coroa só aparece depois de cruzar a borda da caixa.
rh_draw_clipped(sprite_index, image_index, x, y,
                image_xscale, image_yscale, image_blend, image_alpha);

if (RH_ATK_DEBUG_ZONES && active && !was_hit) {
    draw_set_color(c_red);
    draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);
    draw_set_color(c_white);
}
