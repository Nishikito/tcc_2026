t++;

if (estado == "aviso") {
    // Tremedeira: 24 frames de aviso antes do primeiro osso.
    x = base_x + (((t - 1) mod 6 < 3) ? -1 : 1);
    if (t >= warn_frames) {
        x = base_x;
        estado = "fogo";
    }
    exit;
}

if (estado == "fogo") {
    // Um osso a cada bone_interval frames; se o limite de 8 simultâneos foi
    // atingido, tenta de novo no frame seguinte (não trava o padrão).
    if (dropped < n_bones
    &&  t >= warn_frames + dropped * bone_interval
    &&  instance_number(obj_rh_atk_bone_arco) < limite_ossos) {
        var _osso = rh_spawn_attack(obj_rh_atk_bone_arco, base_x + 10, base_y - 50);
        _osso.vx   = vx_ossos;
        _osso.vy   = vy0_min - random(max(0, vy0_min - vy0_max));
        _osso.grav = grav;
        dropped++;
    }
    if (dropped >= n_bones) {
        estado = "afundando";
        fade   = 0;
    }
    exit;
}

if (estado == "afundando") {
    fade++;
    y = base_y + fade * 0.7;   // some/afunda depois do último osso
    if (fade >= 8) {
        rh_debug_destroy("vaso afundou");
        instance_destroy();
    }
}
