var _jx = 0;
if (mode == 0 && t <= warn_frames + prep_frames) _jx = dsin(t * 7) * 0.8;   // tremida leve
if (shake_t > 0) _jx += random_range(-1.5, 1.5);                            // tremida do impacto

var _alpha = 1;
if (mode == 0) {
    var _impact = warn_frames + prep_frames + fall_frames;
    if (t <= warn_frames) {
        // Aviso vermelho somente nos 30 frames iniciais.
        rh_draw_warning(zone_x1, zone_y1, zone_x2, zone_y2, t);
    }
    if (t > _impact + zone_frames) {
        _alpha = 1 - clamp((t - _impact - zone_frames) / 8, 0, 1);
    }
}

// Pivô na ponta da haste: é o ângulo que coloca a CABEÇA para baixo no impacto.
rh_draw_clipped_pivot(sprite_index, 0, px + _jx, py,
                      PIVOT_X, PIVOT_Y, ang,
                      SCALE_H, SCALE_H, c_white, _alpha);

if (shake_t > 0) {
    // Flash branco curto, desenhado por este ataque (sem mexer no controller).
    draw_set_alpha(clamp(shake_t / 8, 0, 1) * 0.55);
    draw_set_color(c_white);
    draw_rectangle(bx1, by1, bx2, by2, true);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

if (RH_ATK_DEBUG_ZONES && mode == 0) {
    var _hd = head_pos(ang);
    var _wd = HEAD_W * SCALE_H / 2;
    var _hd2 = HEAD_H * SCALE_H / 2;
    rh_draw_warning_rect(_hd.x - _wd, _hd.y - _hd2,
                         _hd.x + _wd, _hd.y + _hd2, t);
}
