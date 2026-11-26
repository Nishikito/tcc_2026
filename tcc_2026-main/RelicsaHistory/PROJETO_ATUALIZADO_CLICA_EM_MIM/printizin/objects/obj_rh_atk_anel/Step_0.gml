t++; x += vx; y += vy; vy += grav; image_angle += rot_spd;
if (y > by2 + 20 || t > life) { rh_debug_destroy("fim da vida"); instance_destroy(); }