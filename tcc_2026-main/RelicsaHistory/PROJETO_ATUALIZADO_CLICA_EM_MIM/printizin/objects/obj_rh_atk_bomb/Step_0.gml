if (bomb_state == 0) {
    y += vy;
    if (y >= fuse_y) {
        y = fuse_y;
        bomb_state = 1;
        fuse_t = 0;
    }
}
else {
    fuse_t++;
    image_blend = (((fuse_t div 4) mod 2) == 0) ? c_red : c_white;   // pisca
    if (fuse_t >= fuse_frames) {
        var _a0 = irandom(359);
        for (var i = 0; i < n_shards; i++) {
            var _s = rh_spawn_attack(obj_rh_atk_ball,
                                     x + sprite_width / 2 - 5, y + sprite_height / 2 - 5);
            var _a = _a0 + i * 360 / n_shards;
            _s.vx = lengthdir_x(shard_spd, _a);
            _s.vy = lengthdir_y(shard_spd, _a);
            _s.bounces_left = 0;
        }
        rh_debug_destroy("fim da vida");
        instance_destroy();
    }
}
