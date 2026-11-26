t++; x += vx; y += vy; image_angle += rot_spd;
if (y > by2 + 30 || x < bx1 - 40 || x > bx2 + 40 || t > life) { rh_debug_destroy("fim da vida"); instance_destroy(); }