t++;

if (estado == 0) {                      // fade-in inofensivo (alpha até 0.35)
    image_alpha = 0.12 + 0.23 * min(1, t / max(1, fade_frames));
    if (t >= fade_frames) { estado = 1; telegraph_t = 0; }
    exit;
}

if (estado == 1) {                      // telegrafia: treme, não se move, não machuca
    telegraph_t++;
    jitter = dsin(telegraph_t * 9) * 1.1;
    if (telegraph_t >= telegraph_frames) {
        estado = 2;
        delay_t = 0;
        jitter = 0;
        image_alpha = 1;
    }
    exit;
}

if (estado == 2) {                      // atraso aleatório 0..8 frames
    delay_t++;
    if (delay_t >= delay_frames) estado = 3;
    exit;
}

// Avanço reto: direção travada no nascimento.
x += lengthdir_x(spd, dir);
y += lengthdir_y(spd, dir);
var _ang = 270 - dir;   // sprite com a ponta para baixo em image_angle = 0
image_angle = _ang;

// Geometria própria: retângulo 16x98 escalado, girado em torno do centro.
if (!was_hit && rh_rot_rect_hits_heart(x, y,
        sprite_get_width(sprite_index) * esc,
        sprite_get_height(sprite_index) * esc, _ang)) {
    rh_hurt_heart(id);
}

var _r = rh_box_inner();
var _m = 55;
if (t > vida_max
    || x < _r.x1 - _m || x > _r.x2 + _m
    || y < _r.y1 - _m || y > _r.y2 + _m) {
    rh_debug_destroy("espada saiu da caixa / fim da vida");
    instance_destroy();
}
