t++;

if (puff > 0) {
    puff--;
    if (puff <= 0) {
        rh_debug_destroy("puff do terceiro rebote");
        instance_destroy();
    }
    exit;
}

var _cx = x + largura / 2 + vx;
var _cy = y + altura  / 2 + vy;

// REFLEXÃO nas quatro paredes internas da caixa.
if (_cx - largura / 2 < bx1) { _cx = bx1 + largura / 2; vx = -vx; rebotes++; }
if (_cx + largura / 2 > bx2) { _cx = bx2 - largura / 2; vx = -vx; rebotes++; }
if (_cy - altura  / 2 < by1) { _cy = by1 + altura  / 2; vy = -vy; rebotes++; }
if (_cy + altura  / 2 > by2) { _cy = by2 - altura  / 2; vy = -vy; rebotes++; }

x = _cx - largura / 2;
y = _cy - altura  / 2;
image_angle = point_direction(0, 0, vx, vy) - 90;

if (rebotes >= 3) {
    // Some no 3º rebote, com um puff curto desenhado no Draw.
    puff   = 6;
    active = false;
    exit;
}

if (!was_hit && rh_rot_rect_hits_heart(_cx, _cy, largura, altura, image_angle)) {
    rh_hurt_heart(id);
}

if (t > 400) {
    rh_debug_destroy("fim da vida do foguinho");
    instance_destroy();
}
