t++;
x += lengthdir_x(spd, dir);
y += lengthdir_y(spd, dir);
image_angle = dir;
if (x < bx1 - 30 || x > bx2 + 30 || y < by1 - 30 || y > by2 + 30 || t > life) { rh_debug_destroy("fim da vida"); instance_destroy(); }