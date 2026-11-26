var _jx = (t <= stand_t) ? dsin(t * 7) * 0.8 : 0;
var _da = base_angle + (side_left ? ang : -ang);
var _alpha = 1;
if (zone_made && t > stand_t + 28) {
    _alpha = 1 - clamp((t - stand_t - 28) / 12, 0, 1);
}

if (!zone_made) {
    // Telegrafia: área onde a cabeça vai bater.
    rh_draw_warning(zone_x, zone_y, zone_x + zone_w, zone_y + zone_h, t);
}

rh_draw_sprite_pivot(sprite_index, pivot_x + _jx, pivot_y,
                     0, sprite_get_height(sprite_index),
                     _da, scale_h, scale_h, c_white, _alpha);

if (shake_t > 0) {
    // Feedback curto de impacto: linhas brancas + leve "tremida" do próprio golpe.
    draw_set_alpha(shake_t / 8 * 0.5);
    draw_set_color(c_white);
    draw_rectangle(bx1, by1, bx2, by2, true);
    draw_set_alpha(1);
    draw_set_color(c_white);
}
