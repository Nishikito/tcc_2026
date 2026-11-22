t++;
var _hw = 18;   // largura da zona que machuca (o sprite tem 40, mas a curva vazia não deve machucar)

if (t < warn_t)                           { vis_h = 0; }
else if (t < warn_t + rise_t)             { vis_h = tent_h * ((t - warn_t) / rise_t); }
else if (t < warn_t + rise_t + hold_t)    { vis_h = tent_h; }
else if (t < warn_t + rise_t + hold_t + fall_t) {
    vis_h = tent_h * (1 - (t - warn_t - rise_t - hold_t) / fall_t);
}
else { instance_destroy(); exit; }

if (!zone_made && t >= warn_t) {
    zone_made = true;
    var _z = rh_spawn_attack(obj_rh_atk_zone, 0, 0);
    _z.zone_x    = x + sprite_get_width(sprite_index) / 2 - _hw / 2;
    _z.zone_w    = _hw;
    _z.zone_h    = tent_zone_h;
    _z.zone_y    = by2 - tent_zone_h;
    _z.zone_life = rise_t + hold_t;
    _z.dmg_mult  = dmg_mult;
}
