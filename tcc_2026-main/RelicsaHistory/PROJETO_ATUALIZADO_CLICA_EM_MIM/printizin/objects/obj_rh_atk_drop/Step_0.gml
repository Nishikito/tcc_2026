t++;
if (t < warn_t) { active = false; exit; }   // fica parada no topo enquanto o aviso pisca
active = true;
vy += grav;
y  += vy;
if (y + sprite_height >= by2) {
    // espirra: duas poças correndo pelo chão, uma pra cada lado
    var _sx = x + sprite_width / 2 - 11;
    var _sy = by2 - 21;
    var _l = rh_spawn_attack(obj_rh_atk_splash, _sx, _sy);
    var _r = rh_spawn_attack(obj_rh_atk_splash, _sx, _sy);
    _l.vx = -1.7;
    _r.vx =  1.7;
    rh_debug_destroy("fim da vida");
    instance_destroy();
}
