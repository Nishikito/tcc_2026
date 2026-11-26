t++;
if (t < warn_t) { active = false; exit; }   // só aviso: ainda não se move nem machuca
active = true;
x += vx;
if ((vx > 0 && x > bx2 + 4) || (vx < 0 && x + sprite_width < bx1 - 4)) { rh_debug_destroy("fim da vida"); instance_destroy(); }
