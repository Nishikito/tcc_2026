t++;
y += vel_fumaca;

var _w = sprite_get_width(sprite_index)  * image_xscale;
var _h = sprite_get_height(sprite_index) * image_yscale;

// Single-hit, 60% da largura e 80% inferior da altura. Os últimos 8 frames são inofensivos.
if (t <= vida_fumaca - 8 && !was_hit) {
    var _hw = _w * 0.6;
    var _hh = _h * 0.8;
    var _x1 = x + (_w - _hw) / 2;
    var _y1 = y + _h - _hh;
    if (rh_rect_hits_heart(_x1, _y1, _x1 + _hw, _y1 + _hh)) {
        rh_hurt_heart(id);
    }
}

if (t >= vida_fumaca) {
    rh_debug_destroy("fim da fumaça");
    instance_destroy();
}
