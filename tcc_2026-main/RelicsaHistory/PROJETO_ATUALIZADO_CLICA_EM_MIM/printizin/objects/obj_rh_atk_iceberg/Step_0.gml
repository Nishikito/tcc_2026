t++;

if (estado == 0) {
    active = false;
    if (t >= warn_frames) { estado = 1; active = true; }
    exit;
}

y += vy;
if (y < by1 - 55 || t > life) { rh_debug_destroy("fim da vida"); instance_destroy(); }
