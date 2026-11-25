t++;
var _ox = x + sprite_get_width(sprite_index) / 2;
var _oy = y + sprite_get_height(sprite_index) / 2;
aim = point_direction(_ox, _oy, rh_heart_x(), rh_heart_y());
if (t <= warn_t) exit;
if (shots < n_shots && (t - warn_t) mod fire_t == 0) {
    var _a = aim + irandom_range(-5, 5);
    var _b = rh_spawn_attack(obj_rh_atk_bala_de_canhao, _ox + lengthdir_x(16, _a), _oy + lengthdir_y(16, _a));
    _b.direction = _a;
    _b.speed = spd;
    shots++;
}
if (shots >= n_shots && t > warn_t + n_shots * fire_t + 24) instance_destroy();