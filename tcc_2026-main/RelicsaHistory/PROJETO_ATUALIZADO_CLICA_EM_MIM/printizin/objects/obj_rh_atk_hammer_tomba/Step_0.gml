t++;

if (shake_t > 0) shake_t--;

if (t <= stand_t) {
    // EM PÉ: aviso claro da área que será atingida.
    exit;
}

if (!zone_made) {
    // Aceleração angular crescente: começa devagar, termina rápido.
    ang += ang_acc;
    ang_acc += 0.25;
    if (ang >= 90) {
        ang = 90;
        zone_made = true;
        shake_t = 8;

        // Usa a MESMA função do aviso: vista e impacto nunca divergem.
        var _zp = zone_for_angle(90);
        zone_x = _zp.x;
        zone_y = _zp.y;

        var _z = rh_spawn_attack(obj_rh_atk_zone, 0, 0);
        _z.zone_x = zone_x; _z.zone_y = zone_y;
        _z.zone_w = zone_w; _z.zone_h = zone_h;
        _z.zone_life = 12;      // zona ativa ~10 frames, single-hit via was_hit
        _z.zone_delay = 0;
        _z.dmg_mult = dmg_mult;
        rh_debug("MARTELO TOMBOU | lado=" + (side_left ? "esquerdo" : "direito")
                 + " | zona=" + string(zone_x) + "," + string(zone_y));
    }
}

// Some logo depois do impacto (o dano continua na zona, não no martelo).
if (zone_made && t > stand_t + 40) {
    rh_debug_destroy("fim da vida (martelo)");
    instance_destroy();
}
