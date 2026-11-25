t++;
x += vx; y += vy; image_angle += rot_spd;
if (x < bx1 - 45 || x > bx2 + 45 || t > life) instance_destroy();