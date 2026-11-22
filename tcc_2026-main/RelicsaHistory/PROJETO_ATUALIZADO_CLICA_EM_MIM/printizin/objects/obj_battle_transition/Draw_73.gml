var _cam = view_camera[0];
var _vx  = camera_get_view_x(_cam);
var _vy  = camera_get_view_y(_cam);

// ── "!" sobre o player (fase 0) ──
if (phase == 0) {
    var _s = 1.5;
    if (timer < 6) _s = 1.5 * (timer / 6) * 1.4;           // pulinho de entrada
    else if (timer < 10) _s = 1.5 * (1.4 - (timer - 6) * 0.1);
    var _bounce = (timer < 10) ? -sin(timer / 10 * pi) * 3 : 0;
    draw_sprite_ext(SprAlert, 0, alert_x - 3 * _s, alert_y - 10 * _s + _bounce, _s, _s, 0, c_white, 1);
}

// ── Coração piscando (fase 1) ──
if (phase == 1) {
    if ((timer >= t_dark - 6) || (timer >= 8 && ((timer div 3) mod 2 == 0))) {
        draw_sprite_ext(spr_rh_battle_player, 0, heart_x0, heart_y0, 1, 1, 0, c_white, 1);
    }
}

// ── Formação (fases 2 e 3): sprites de BATALHA deslizam com rastro ──
if (phase >= 2) {
    var _p  = (phase == 3) ? 1 : clamp(timer / t_slide, 0, 1);
    var _mv = (phase == 2);

    // se a captura falhar, o sprite não some: fica parado no destino
    var _pcx = (p_spr != -1) ? p_cx : _vx + player_tx;
    var _pcy = (p_spr != -1) ? p_cy : _vy + player_ty;
    var _ecx = (e_spr != -1) ? e_cx : _vx + enemy_tx;
    var _ecy = (e_spr != -1) ? e_cy : _vy + enemy_ty;
    var _hx0 = (p_spr != -1) ? heart_x0 : _pcx;
    var _hy0 = (p_spr != -1) ? heart_y0 : _pcy;

    for (var k = trail_count; k >= 0; k--) {
        var _pp = clamp(_p - k * trail_gap, 0, 1);
        if (k > 0 && (!_mv || _pp <= 0)) continue;

        var _u  = 1 - power(1 - _pp, 3);                       // ease-out cúbico
        var _al = 1;
        if (k > 0) _al = trail_alpha * (1 - k / (trail_count + 1));

        // Talai
        var _ps = lerp(p_start_scale, battle_talai_scale, _u);
        draw_copy(battle_talai_spr, 0, _ps, _ps,
                  lerp(_pcx, _vx + player_tx, _u), lerp(_pcy, _vy + player_ty, _u), _al);

        // Inimigo
        if (battle_enemy_spr != -1) {
            var _es = lerp(e_start_scale, battle_enemy_fit, _u);
            draw_copy(battle_enemy_spr, 0, _es, _es,
                      lerp(_ecx, _vx + enemy_tx, _u), lerp(_ecy, _vy + enemy_ty, _u), _al);
        }

        // Coração (origem no centro)
        draw_sprite_ext(spr_rh_battle_player, 0,
                        lerp(_hx0, _vx + heart_tx, _u), lerp(_hy0, _vy + heart_ty, _u),
                        1, 1, 0, c_white, _al);
    }
}