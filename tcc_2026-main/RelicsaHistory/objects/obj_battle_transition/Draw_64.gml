var _gw  = display_get_gui_width();
var _gh  = display_get_gui_height();
var _cam = view_camera[0];
var _vx  = camera_get_view_x(_cam);
var _vy  = camera_get_view_y(_cam);
var _vw  = camera_get_view_width(_cam);
var _vh  = camera_get_view_height(_cam);
var _sx  = _gw / _vw;   // pixels da view → pixels da GUI
var _sy  = _gh / _vh;

// ── "!" sobre o player (fase 0) ──
if (phase == 0) {
    var _s = 1.5;
    if (timer < 6) _s = 1.5 * (timer / 6) * 1.4;           // pulinho de entrada
    else if (timer < 10) _s = 1.5 * (1.4 - (timer - 6) * 0.1);
    var _bounce = (timer < 10) ? -sin(timer / 10 * pi) * 3 : 0;
    draw_sprite_ext(SprAlert, 0,
                    (alert_x - _vx - 3 * _s) * _sx,
                    (alert_y - _vy - 10 * _s + _bounce) * _sy,
                    _s * _sx, _s * _sy, 0, c_white, 1);
}

// ── Formação (fases 2 e 3): cópias do player e do inimigo deslizam ──
// ── Formação (fases 2 e 3): sprites de BATALHA deslizam até a posição da batalha ──
// Mesma técnica da battle box (sem girar): cópias atrasadas no tempo + ease-out cúbico,
// e o rastro só existe enquanto está se movendo.
if (phase >= 2) {
    var _p  = (phase == 3) ? 1 : clamp(timer / t_slide, 0, 1);
    var _mv = (phase == 2);

    for (var k = trail_count; k >= 0; k--) {
        var _pp = clamp(_p - k * trail_gap, 0, 1);
        if (k > 0 && (!_mv || _pp <= 0)) continue;

        var _u  = 1 - power(1 - _pp, 3);                       // ease-out
        var _al = 1;
        if (k > 0) _al = trail_alpha * (1 - k / (trail_count + 1));

        if (p_spr != -1) {
            var _ps = lerp(p_start_scale, battle_talai_scale, _u);
            draw_copy(battle_talai_spr, 0, _ps, _ps,
                      lerp(p_cx - _vx, player_tx, _u) * _sx,
                      lerp(p_cy - _vy, player_ty, _u) * _sy,
                      _al, _sx, _sy);
        }
        if (e_spr != -1 && battle_enemy_spr != -1) {
            var _es = lerp(e_start_scale, battle_enemy_fit, _u);
            draw_copy(battle_enemy_spr, 0, _es, _es,
                      lerp(e_cx - _vx, enemy_tx, _u) * _sx,
                      lerp(e_cy - _vy, enemy_ty, _u) * _sy,
                      _al, _sx, _sy);
        }
    }
}

// ── Coração ──
var _wx = heart_x0;
var _wy = heart_y0;
var _visible = false;

if (phase == 1) {
    // começa a piscar na metade do escurecimento e fica aceso no fim
    _visible = (timer >= t_dark - 6) || (timer >= 8 && ((timer div 3) mod 2 == 0));
}
else if (phase >= 2) {
    _visible = true;
    var _hp = (phase == 3) ? 1 : clamp(timer / t_slide, 0, 1);
        for (var k = trail_count; k >= 0; k--) {
        var _hpp = clamp(_hp - k * trail_gap, 0, 1);
        if (k > 0 && (phase != 2 || _hpp <= 0)) continue;
        var _hu = 1 - power(1 - _hpp, 3);
        var _hal = 1;
        if (k > 0) _hal = trail_alpha * (1 - k / (trail_count + 1));
        draw_sprite_ext(spr_rh_battle_player, 0,
                        (lerp(heart_x0, _vx + heart_tx, _hu) - _vx) * _sx,
                        (lerp(heart_y0, _vy + heart_ty, _hu) - _vy) * _sy,
                        _sx, _sy, 0, c_white, _hal);
    }
    _visible = false;   // já desenhado acima
}

if (_visible) {
    draw_sprite_ext(spr_rh_battle_player, 0,
                    (_wx - _vx) * _sx, (_wy - _vy) * _sy,
                    _sx, _sy, 0, c_white, 1);
}