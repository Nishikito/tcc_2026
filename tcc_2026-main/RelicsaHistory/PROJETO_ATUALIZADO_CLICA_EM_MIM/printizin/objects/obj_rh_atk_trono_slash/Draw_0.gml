var _inicio = aviso_frames + delay_frames;

if (t < _inicio) {
    // Fio vermelho fino e piscando: mostra a linha que será cortada.
    rh_draw_warning_line(x1, y1, x2, y2, 2, t);
} else {
    var _a = t - _inicio;
    var _alpha = 1;
    if (_a > active_frames) {
        _alpha = max(0, 1 - (_a - active_frames) / max(1, fade_frames));
    }

    // Faixa branca de ~10 px: x1..y2 já vêm recortados na caixa (margem 6).
    draw_set_alpha(_alpha);
    draw_set_color(c_white);
    draw_line_width(x1, y1, x2, y2, largura);
    draw_set_alpha(1);

    if (RH_ATK_DEBUG_ZONES && _a <= active_frames) {
        draw_set_color(c_red);
        draw_line_width(x1, y1, x2, y2, 2);
        draw_set_color(c_white);
    }
}
