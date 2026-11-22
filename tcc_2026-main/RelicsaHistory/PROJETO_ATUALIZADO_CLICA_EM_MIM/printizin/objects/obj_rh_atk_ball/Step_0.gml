x += vx;
y += vy;

if (bounces_left > 0) {
    var _w = sprite_width;
    var _h = sprite_height;
    if (x < bx1)            { x = bx1;       vx =  abs(vx); bounces_left--; }
    else if (x + _w > bx2)  { x = bx2 - _w;  vx = -abs(vx); bounces_left--; }
    if (y < by1)            { y = by1;       vy =  abs(vy); bounces_left--; }
    else if (y + _h > by2)  { y = by2 - _h;  vy = -abs(vy); bounces_left--; }
}

life--;
if (life <= 0) instance_destroy();
