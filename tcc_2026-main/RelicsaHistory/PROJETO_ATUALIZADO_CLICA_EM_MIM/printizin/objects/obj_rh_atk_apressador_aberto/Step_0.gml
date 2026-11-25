t++;
x += lengthdir_x(spd, dir);
y += lengthdir_y(spd, dir);
image_angle = dir;
if (x < bx1 - 60 || x > bx2 + 60 || t > life) instance_destroy();