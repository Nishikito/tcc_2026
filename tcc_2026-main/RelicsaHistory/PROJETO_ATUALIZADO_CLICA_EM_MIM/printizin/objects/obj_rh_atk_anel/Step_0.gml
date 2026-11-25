t++; x += vx; y += vy; vy += grav; image_angle += rot_spd;
if (y > by2 + 20 || t > life) instance_destroy();