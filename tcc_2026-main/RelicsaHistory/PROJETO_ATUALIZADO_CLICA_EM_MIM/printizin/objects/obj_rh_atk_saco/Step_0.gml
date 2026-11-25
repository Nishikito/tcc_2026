t++;
var _w = sprite_get_width(sprite_index);
var _h = sprite_get_height(sprite_index);
var _hidden = by1 - _h - 20;
var _landed = by2 - _h + 4;
x = zone_x + zone_w / 2 - _w / 2;
if (t < warn_t) { y = _hidden; }
else if (t < warn_t + drop_t) {
    var _e = (t - warn_t) / drop_t;
    y = lerp(_hidden, _landed, _e * _e);
    if (!zone_made) {
        zone_made = true;
        var _z = rh_spawn_attack(obj_rh_atk_zone, 0, 0);
        _z.zone_x = zone_x; _z.zone_w = zone_w;
        _z.zone_y = by1; _z.zone_h = by2 - by1;
        _z.zone_life = drop_t + hold_t; _z.dmg_mult = dmg_mult;
    }
}
else if (t < warn_t + drop_t + hold_t) { y = _landed; }
else if (t < warn_t + drop_t + hold_t + rise_t) {
    var _e2 = (t - warn_t - drop_t - hold_t) / rise_t;
    y = lerp(_landed, _hidden, _e2);
}
else instance_destroy();