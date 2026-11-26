t++;
ang += ang_spd;
rad -= rad_spd;
x = cx + lengthdir_x(rad, ang);
y = cy + lengthdir_y(rad, ang);
image_angle = ang + 90;
if (rad <= 4 || t > 140) { rh_debug_destroy("fim da vida"); instance_destroy(); }