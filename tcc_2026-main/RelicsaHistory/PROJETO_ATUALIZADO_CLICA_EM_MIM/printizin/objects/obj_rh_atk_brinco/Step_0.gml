t++; x += vx; y += vy; vy += grav;
if (y > by2 + 22 || t > life) instance_destroy();