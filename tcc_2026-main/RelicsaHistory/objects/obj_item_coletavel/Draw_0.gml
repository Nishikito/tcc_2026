draw_self();

// Indicador de "pode interagir" — aparece só quando o jogador chega perto
if (no_alcance) {
    var _px = x;
    var _py = y - sprite_height - 2 + dsin(float_timer * 1.5) * 1;

    if (sprite_exists(spr_interact)) {
        draw_sprite(spr_interact, 0, _px, _py);
    } else {
        // Fallback caso o sprite suma: desenha um "!" simples
        draw_set_font(global.font_main);
        draw_set_halign(fa_center);
        draw_set_color(c_white);
        draw_text(_px, _py, "!");
        draw_set_halign(fa_left);
    }
}