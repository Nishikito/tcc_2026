var _xs = bar_w / sprite_get_width(sprite_index);    // 0.6
var _ys = bar_h / sprite_get_height(sprite_index);   // 0.6

if (t < warn_frames) {
    // Aviso: retângulo vermelho no PONTO DE POUSO (a coluna inteira até o chão).
    rh_draw_warning(x - 1, ground_y - 1, x + bar_w + 1, ground_y + bar_h + 1, t);
    exit;
}

if (launched) {
    // Rastro curto da barra rastejando rente ao chão.
    for (var _k = 0; _k < 6; _k++) {
        var _age = (trail_i - _k + 6) mod 6;
        var _a = (1 - _age / 6) * 0.30;
        if (_a <= 0) continue;
        rh_draw_clipped(sprite_index, 0, trail[_k], y, _xs, _ys, c_white, _a);
    }
}

rh_draw_clipped(sprite_index, 0, x, y, _xs, _ys, c_white, 1);

if (flash_t > 0) {
    // Brilho curto ao bater no chão (a barra some logo em seguida).
    draw_set_alpha(clamp(flash_t / 5, 0, 1) * 0.55);
    draw_set_color(c_white);
    draw_rectangle(x - 2, y - 2, x + bar_w + 2, y + bar_h + 2, true);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

if (mode == 1 && landed && !launched
    && rest_t >= rest_frames - warn_line_frames) {
    // Seta/linha vermelha no chão: para onde a barra vai ser lançada.
    var _ly = y + bar_h / 2;
    var _lx1 = x + bar_w / 2;
    var _lx2 = (launch_dir > 0) ? bx2 : bx1;
    rh_draw_warning_line(_lx1, _ly, _lx2, _ly, 3, rest_t);
}

if (RH_ATK_DEBUG_ZONES && (!landed || launched)) {
    rh_draw_warning_rect(x, y, x + bar_w, y + bar_h, t);
}
