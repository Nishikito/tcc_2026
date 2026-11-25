t++;
if (t < fade_t) { image_alpha = t / fade_t; exit; }
if (t > life - 20) {
    image_alpha = (life - t) / 20;
    active = false;
    if (t >= life) instance_destroy();
    exit;
}
active = true;
image_alpha = 1;
var _d = point_direction(x + sprite_get_width(sprite_index)/2, y + sprite_get_height(sprite_index)/2, rh_heart_x(), rh_heart_y());
x += lengthdir_x(spd, _d) + dsin(t * 5) * 0.3;
y += lengthdir_y(spd, _d);