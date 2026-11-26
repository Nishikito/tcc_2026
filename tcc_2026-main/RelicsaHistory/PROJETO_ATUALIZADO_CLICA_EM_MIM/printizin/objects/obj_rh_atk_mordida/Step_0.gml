t++;

if (state == 0) {
    // Aviso: a direção ainda acompanha o coração, mas nada machuca.
    aim = point_direction(x + sprite_get_width(sprite_index) / 2,
                          y + sprite_get_height(sprite_index) / 2,
                          rh_heart_x(), rh_heart_y());
    image_angle = 0;
    if (t >= warn_t) {
        // TRAVA a mira: perseguir durante o bote seria injusto.
        state = 1;
        rh_debug("MORDIDA | bote travado em " + string(aim));
    }
    exit;
}

if (state == 1) {
    x += lengthdir_x(lunge_spd, aim);
    y += lengthdir_y(lunge_spd, aim);
    lunge_t++;
    if (lunge_t >= lunge_frames) {
        state = 2;
        bite_t = 0;
        // Zona de dano: 22x18 px na frente da boca, vive 6 frames, um único acerto.
        var _mx = x + lengthdir_x(26, aim);
        var _my = y + lengthdir_y(26, aim);
        var _z = rh_spawn_attack(obj_rh_atk_zone, 0, 0);
        _z.zone_x = _mx - 11;
        _z.zone_y = _my - 9;
        _z.zone_w = 22;
        _z.zone_h = 18;
        _z.zone_life = bite_frames;
        _z.dmg_mult = dmg_mult;
        zone_inst = _z;
        rh_debug("MORDIDA | zona ativa " + string(_z.zone_x) + "," + string(_z.zone_y));
    }
    exit;
}

if (state == 2) {
    // Mordida: 6 frames. A zona cuida do dano; este sprite só visualiza o impacto.
    bite_t++;
    image_xscale = 0.9 + (bite_t mod 2 == 1 ? 0.07 : -0.04);
    if (bite_t >= bite_frames) { state = 3; retreat_t = 0; image_xscale = 0.9; }
    exit;
}

if (state == 3) {
    // Recuo: volta ao ponto inicial com a mira ainda travada.
    var _dx = start_x - x;
    var _dy = start_y - y;
    var _d  = point_distance(x, y, start_x, start_y);
    if (_d <= retreat_spd) { x = start_x; y = start_y; }
    else {
        x += _dx / _d * retreat_spd;
        y += _dy / _d * retreat_spd;
    }
    retreat_t++;
    if (retreat_t >= retreat_frames) {
        rh_debug_destroy("fim da vida (mordida)");
        instance_destroy();
    }
}
