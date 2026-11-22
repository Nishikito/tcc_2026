t++;
if (t <= fade_t) {
    image_alpha = 0.9 * (t / fade_t);
}
else {
    active = true;
    image_alpha = 0.95;
    var _tx = rh_heart_x() - sprite_width  / 2;
    var _ty = rh_heart_y() - sprite_height / 2;
    var _d  = point_direction(x, y, _tx, _ty);
    x += lengthdir_x(spd, _d);
    y += lengthdir_y(spd, _d) + dsin(t * 5) * 0.4;   // leve balanço
}
if (t >= life - 20) image_alpha = max(0, (life - t) / 20);
if (t >= life) instance_destroy();
