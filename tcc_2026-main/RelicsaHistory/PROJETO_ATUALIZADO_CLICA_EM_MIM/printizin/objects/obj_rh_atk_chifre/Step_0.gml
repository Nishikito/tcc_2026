t++;
x += vx;
if (x < bx1 - 70 || x > bx2 + 70 || t > life) { rh_debug_destroy("fim da vida"); instance_destroy(); }