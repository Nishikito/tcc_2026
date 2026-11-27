t++;

// Other_0 está vazio de propósito: ataques nascem acima/fora da caixa, mas dentro da room.
// A morte é sempre por tempo (ou ao virar splash / sair da área útil).
if (t > vida) {
    rh_debug_destroy("fim da vida (gota)");
    instance_destroy();
    exit;
}

if (modo == "splash") {
    // Gota lateral: corre pelo chão e some com fade curto.
    x += vx;
    y  = by2 - sprite_height;
    image_alpha = clamp((vida - t) / 10, 0, 1);
} else {
    if (t <= warn_t) {
        // Telegráfico: fica parada no topo e NÃO machuca. O aviso está no Draw.
        active = false;
        image_alpha = 0.65;
        exit;
    }

    vy = min(vy + grav, vy_max);
    x += vx;
    y += vy;
    image_alpha = 1;

    if (modo == "fileira" && y + sprite_height >= by2) {
        // Respingo: duas gotas laterais do MESMO objeto (nada de obj_rh_atk_splash).
        var _sx = x + sprite_width / 2 - 11;
        var _sy = by2 - sprite_height;
        var _e = rh_spawn_attack(obj_rh_atk_lagrima_carumaru, _sx, _sy);
        _e.modo    = "splash";
        _e.warn_t  = 0;
        _e.vx      = -1.7;
        _e.vy      = 0;
        _e.grav    = 0;
        _e.vy_max  = 0;
        _e.vida    = 22;
        _e.image_alpha = 1;
        var _d = rh_spawn_attack(obj_rh_atk_lagrima_carumaru, _sx, _sy);
        _d.modo    = "splash";
        _d.warn_t  = 0;
        _d.vx      = 1.7;
        _d.vy      = 0;
        _d.grav    = 0;
        _d.vy_max  = 0;
        _d.vida    = 22;
        _d.image_alpha = 1;
        rh_debug_destroy("virou splash");
        instance_destroy();
        exit;
    }

    if (modo == "arco" && (y > by2 + 48 || x < bx1 - 96 || x > bx2 + 96)) {
        rh_debug_destroy("fora da área do arco");
        instance_destroy();
        exit;
    }
}

// Hitbox própria: 85% do sprite (o coração já é encolhido em rh_heart_rect).
active = (!was_hit && image_alpha > 0.25);
if (active) {
    var _hw = sprite_width  * 0.85 / 2;
    var _hh = sprite_height * 0.85 / 2;
    var _cx = x + sprite_width  / 2;
    var _cy = y + sprite_height / 2;
    if (rh_rect_hits_heart(_cx - _hw, _cy - _hh, _cx + _hw, _cy + _hh)) {
        rh_hurt_heart(id);   // destroy_on_hit = false: was_hit vira o single-hit
    }
}
