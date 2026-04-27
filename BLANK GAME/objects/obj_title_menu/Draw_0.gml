// Desenha o sprite do menu
/*draw_sprite_ext(menu_sprite, 0, x, y, menu_width / sprite_get_width(menu_sprite), menu_height / sprite_get_height(menu_sprite), 0, c_white, 1);

// Desenho das Opções
for (var i = 0; i < op_length; i++) {
    var y_position = y + op_border + (i * (font_get_height(font) + op_space));
    draw_text(x + op_border, y_position, option[i]);
}