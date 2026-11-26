t++;
x += vx; y += vy; image_angle += rot_spd;
if (x < bx1 - 45 || x > bx2 + 45 || t > life) { rh_debug_destroy("fim da vida"); instance_destroy(); }