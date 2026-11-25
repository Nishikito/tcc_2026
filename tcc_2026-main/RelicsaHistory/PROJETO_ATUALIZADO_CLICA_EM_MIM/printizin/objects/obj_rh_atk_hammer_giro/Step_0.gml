t++;
var _w = sprite_get_width(sprite_index) * image_xscale;
var _h = sprite_get_height(sprite_index) * image_yscale;
x = zone_x + zone_w / 2 - _w / 2;
if (t < warn_t) { y = by1 - _h - 24; exit; }
var _p = clamp((t - warn_t) / 16, 0, 1);
image_xscale = lerp(1, shrink, _p);
image_yscale = image_xscale;
image_angle += spin;
vy += grav;
y += vy;
if (!zone_made && y + _h >= by2 - 6) {
    zone_made = true;
    var _z = rh_spawn_attack(obj_rh_atk_zone, 0, 0);
    _z.zone_x = zone_x; _z.zone_w = zone_w;
    _z.zone_y = by1; _z.zone_h = by2 - by1;
    _z.zone_life = 18; _z.dmg_mult = dmg_mult;
}
if (zone_made && t > warn_t + 26) instance_destroy();