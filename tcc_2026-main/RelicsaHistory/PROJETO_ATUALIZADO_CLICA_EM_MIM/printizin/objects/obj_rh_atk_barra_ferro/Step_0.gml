t++;

if (t < warn_frames) exit;   // aviso: fica parada no topo, ainda não machuca

// ── Queda em coluna: vy 0 -> 3.4, aceleração de 0.12 por frame ─────
if (!landed) {
    vy = min(vy + grav, vy_max);
    y += vy;
    if (y >= ground_y) {
        y = ground_y;
        landed = true;
        if (mode == 0) flash_t = 5;   // brilha e se parte ao tocar o chão
    }
}

// Dano manual por geometria: só enquanto cai ou depois de lançada.
// Parada no chão (Sentença) é inofensiva por rest_frames frames.
if (!was_hit && (!landed || launched)
    && rh_rect_hits_heart(x, y, x + bar_w, y + bar_h)) {
    rh_hurt_heart(id);   // active é false: dano manual, single-hit
}

if (launched) {
    trail_i = (trail_i + 1) mod 6;
    trail[trail_i] = x;
    x += launch_dir * launch_speed;
    if (x > bx2 || x + bar_w < bx1) {
        rh_debug_destroy("fim da vida (barra lançada)");
        instance_destroy();
        exit;
    }
}

if (mode == 0) {
    if (flash_t > 0) {
        flash_t--;
        if (flash_t <= 0) {
            rh_debug_destroy("fim da vida (barra quebrou)");
            instance_destroy();
        }
    }
    exit;
}

// ── Sentença: repouso, aviso da linha, martelo e lançamento ────────
if (landed && !launched) {
    rest_t++;

    // -1 compensa o frame em que o martelo avisa a barra (ela processa no Step seguinte).
    if (rest_t == rest_frames - smash_frames - 1 && !smash_spawned) {
        smash_spawned = true;
        var _hm = rh_spawn_attack(obj_rh_atk_martelo_ferro,
                                  x + bar_w / 2, y - 50);
        _hm.mode         = 1;   // esmaga, sem dano próprio
        _hm.px           = x + bar_w / 2;
        _hm.py           = y - 50;
        _hm.py_start     = y - 50;
        _hm.py_end       = y - 50;
        _hm.smash_frames = smash_frames;
        _hm.target_bar   = id;
        _hm.dmg_mult     = dmg_mult;
    }
}

if (launch_now && !launched) {
    launched   = true;
    launch_now = false;
}
