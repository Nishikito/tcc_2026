t++; x += vx; y += vy; vy += grav;
if (y > by2 + 22 || t > life) { rh_debug_destroy("fim da vida"); instance_destroy(); }