t++;
var _cx = x + sprite_get_width(sprite_index) / 2;
var _cy = y + sprite_get_height(sprite_index) / 2;

// Persegue só no começo. Depois a mira é travada e o aviso continua visível.
if (!locked && t <= aim_t) {
    aim = point_direction(_cx, _cy, rh_heart_x(), rh_heart_y());
    jitter = dsin(t * 6) * 1.4;
} else if (!locked) {
    locked = true;
    aim_lock = aim;
    shots_left = shot_n;
    next_shot = warn_t + 1;
    jitter = 0;
    rh_debug("CANHAO TRAVOU MIRA | dir=" + string(aim_lock));
}

// 5 balas de canhão em sequência, sempre na direção travada.
if (locked && shots_left > 0 && t >= next_shot) {
    var _mouth = sprite_get_width(sprite_index) / 2 - 2;
    var _mx = _cx + lengthdir_x(_mouth, aim_lock);
    var _my = _cy + lengthdir_y(_mouth, aim_lock);
    var _b = rh_spawn_attack(obj_rh_atk_bala_de_canhao, _mx, _my);
    _b.direction    = aim_lock;
    _b.speed        = 3.2;
    _b.image_angle  = 0;      // a bala é redonda: não precisa girar
    _b.dmg_mult     = dmg_mult;
    _b.destroy_on_hit = true;
    shots_left--;
    next_shot += shot_gap;
    rh_debug("CANHAO DISPAROU | restam " + string(shots_left));
}

if (t > warn_t + shot_n * shot_gap + 45) {
    rh_debug_destroy("fim da vida (canhão)");
    instance_destroy();
}
