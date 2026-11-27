t++;

if (estado == 0) {
    active = false;
    if (t >= warn_frames) { estado = 1; active = true; }
    exit;
}

x += vx;
if (x < bx1 - 70 || x > bx2 + 70 || t > life) { rh_debug_destroy("fim da vida"); instance_destroy(); }
