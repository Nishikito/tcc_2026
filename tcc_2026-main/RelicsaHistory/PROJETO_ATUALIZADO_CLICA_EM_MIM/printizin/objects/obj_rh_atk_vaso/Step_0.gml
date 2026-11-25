t++;
if (t >= 18 && dropped < n_drops && (t - 18) mod interval == 0) {
    dropped++;
    var _b = rh_spawn_attack(obj_rh_atk_bone, x + irandom_range(0, 20), y + sprite_get_height(sprite_index));
    _b.vx = choose(-0.35, 0, 0.35);
    _b.vy = 1.7;
}
if (dropped >= n_drops && t > 18 + n_drops * interval + 30) instance_destroy();