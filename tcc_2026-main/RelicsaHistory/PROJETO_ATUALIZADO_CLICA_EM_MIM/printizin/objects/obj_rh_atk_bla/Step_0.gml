t++; x += vx; y += vy;
if (x > bx2 + 40 || x < bx1 - 50 || t > life) { rh_debug_destroy("fim da vida"); instance_destroy(); }