// Estrela balançando
draw_sprite(sprite_index, 0, x, y + round(sin(bob_timer) * 2));

// Dica quando o Talai está perto
if (near_player) {
    draw_set_font(global.font_main);
    draw_set_halign(fa_center);
    draw_set_valign(fa_bottom);
    draw_set_color(c_white);
    draw_text_transformed(x + 8, y - 4, "Enter", 0.6, 0.6, 0);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);
}
