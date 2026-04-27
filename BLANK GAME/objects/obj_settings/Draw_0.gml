// Evento Draw do seu objeto de menu

draw_set_font(global.font_menu); // Define a fonte do menu
for (var i = 0; i < op_length; i++) {
    var y_position = y + op_border + (i * (font_get_height(global.font_menu) + op_space));
    draw_text(x + op_border, y_position, option[i]);
}