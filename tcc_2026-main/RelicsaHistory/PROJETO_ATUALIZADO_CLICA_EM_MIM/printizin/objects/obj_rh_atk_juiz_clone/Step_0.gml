t++;

if (state == 0) {                       // fade-in (6 frames, comandado pelo manager)
    image_alpha = min(1, image_alpha + 0.18);
    exit;
}

if (state == 1) {                       // telegrafia: treme, mas NÃO se move nem machuca
    telegraph_t++;
    jitter = dsin(telegraph_t * 9) * 1.2;
    active = false;
    if (telegraph_t >= 12) {
        state = 2;
        charge_t = 0;
        active = is_true;               // comprimento da investida perigosa: 12 frames
        if (is_true) {
            kb_power = 3.4;
            kb_dir   = aim;             // empurrão na direção da investida
        }
        rh_debug("INVESTIDA JUIZ " + string(ring_pos + 1) + (is_true ? " (VERDADEIRO)" : " (falso)"));
    }
    exit;
}

if (state == 2 || state == 3) {
    // Direção travada: perseguir depois é proibido.
    x += lengthdir_x(charge_spd, aim);
    y += lengthdir_y(charge_spd, aim);
    charge_t++;
    if (state == 2 && charge_t > 10) { active = false; state = 3; }

    // Saída manual: este objeto sobrescreve o Other_0 do pai (Outside Room).
    if (x < -90 || x > 410 || y < -90 || y > 330) {
        rh_debug_destroy("saiu da room após a investida");
        instance_destroy();
    }
    if (charge_t > 70) {
        rh_debug_destroy("fim da vida (clone)");
        instance_destroy();
    }
}
