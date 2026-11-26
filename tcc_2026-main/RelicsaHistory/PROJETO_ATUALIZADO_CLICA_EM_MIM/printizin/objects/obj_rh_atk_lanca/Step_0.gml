t++;
x += lengthdir_x(spd, dir);
y += lengthdir_y(spd, dir);
image_angle = dir;
if (x < bx1 - 70 || x > bx2 + 70 || y < by1 - 20 || y > by2 + 20 || t > life) { rh_debug_destroy("fim da vida"); instance_destroy(); }