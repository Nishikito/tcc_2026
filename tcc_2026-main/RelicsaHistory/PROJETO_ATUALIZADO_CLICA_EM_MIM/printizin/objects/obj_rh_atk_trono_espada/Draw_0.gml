// Aviso: linha vermelha no sentido da ponta (borda da caixa ou centro do anel).
if (estado < 3) {
    var _a = 0.22;
    if (warn_fraco) _a = 0.18;
    if (((t div 4) mod 2) == 0) {
        _a = 0.45;
        if (warn_fraco) _a = 0.32;
    }
    draw_set_alpha(_a);
    draw_set_color(c_red);
    draw_line_width(x + jitter, y + jitter, warn_x2, warn_y2, 2);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

// Desenho recortado na caixa, girado em torno do centro geométrico da sprite.
var _ang = 270 - dir;
var _sx = x;
var _sy = y;
if (estado == 1) { _sx += jitter; _sy += jitter; }
rh_draw_clipped_ext(sprite_index, image_index, _sx, _sy,
                    esc, esc, _ang, image_blend, image_alpha);

// Depuração opcional: círculo no centro da hitbox girada.
if (RH_ATK_DEBUG_ZONES && !was_hit && estado == 3) {
    draw_set_color(c_red);
    draw_circle(_sx, _sy, 6, true);
    draw_set_color(c_white);
}
