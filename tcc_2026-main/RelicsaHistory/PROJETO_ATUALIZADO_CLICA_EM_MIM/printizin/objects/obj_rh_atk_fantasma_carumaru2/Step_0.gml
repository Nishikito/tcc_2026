t++;

// Other_0 está vazio de propósito: fantasmas podem nascer fora da caixa (dentro da room).
if (t >= vida) {
    rh_debug_destroy("fim da vida (fantasma)");
    instance_destroy();
    exit;
}

var _sw = sprite_width;
var _sh = sprite_height;
var _hx = rh_heart_x();
var _hy = rh_heart_y();

// O ECO observa o coração TODOS os frames, mesmo parado: 1 struct por frame.
array_push(eco_buffer, { x: _hx, y: _hy });
if (array_length(eco_buffer) > 41) {
    array_delete(eco_buffer, 0, array_length(eco_buffer) - 41);
}

if (t <= fade_in) {
    // Semi-transparente e inofensivo. Aproxima devagar (ou caminha até a borda, se parede).
    image_alpha = 0.15 + 0.7 * (t / fade_in);
    active = false;
    var _tx0 = _hx;
    var _ty0 = _hy;
    if (personality == "parede") {
        _tx0 = clamp(x, bx1 + _sw / 2, bx2 - _sw / 2);
        _ty0 = clamp(y, by1 + _sh / 2, by2 - _sh / 2);
    }
    var _d0 = max(0.001, point_distance(x, y, _tx0, _ty0));
    x += (_tx0 - x) / _d0 * 0.8;
    y += (_ty0 - y) / _d0 * 0.8;
    exit;
}

if (t >= vida - fade_out) {
    // Fade final inofensivo.
    image_alpha = (vida - t) / fade_out;
    active = false;
    exit;
}

image_alpha = 0.85;
active = !was_hit;

var _tx = _hx;
var _ty = _hy;
if (personality == "eco") {
    // Alvo = posição do coração 40 frames atrás (buffer por instância).
    var _idx = array_length(eco_buffer) - 1 - 40;
    if (_idx < 0) _idx = 0;
    _tx = eco_buffer[_idx].x;
    _ty = eco_buffer[_idx].y;
}

if (personality == "parede") {
    // Desliza pela borda; a cada 60 frames escolhe a borda mais perto do coração
    // e a direção do deslizamento naquela borda.
    turn_t++;
    if (turn_t >= turn_every || t == fade_in + 1) {
        turn_t = 0;
        var _dx = _hx - x;
        var _dy = _hy - y;
        if (abs(_dx) > abs(_dy)) {
            borda_eixo = (_dx >= 0) ? "direita" : "esquerda";
            borda_dir  = sign(_hy - y);
        } else {
            borda_eixo = (_dy >= 0) ? "baixo" : "cima";
            borda_dir  = sign(_hx - x);
        }
        if (borda_dir == 0) borda_dir = 1;
    }

    var _mx = bx1 + _sw / 2;
    var _Mx = bx2 - _sw / 2;
    var _my = by1 + _sh / 2;
    var _My = by2 - _sh / 2;
    if (borda_eixo == "esquerda") {
        x = _mx;
        y += vel * borda_dir;
        if (y < _my) y = _My;
        if (y > _My) y = _my;
    } else if (borda_eixo == "direita") {
        x = _Mx;
        y += vel * borda_dir;
        if (y < _my) y = _My;
        if (y > _My) y = _my;
    } else if (borda_eixo == "cima") {
        y = _my;
        x += vel * borda_dir;
        if (x < _mx) x = _Mx;
        if (x > _Mx) x = _mx;
    } else {
        y = _My;
        x += vel * borda_dir;
        if (x < _mx) x = _Mx;
        if (x > _Mx) x = _mx;
    }
} else {
    // SEGUIDOR: reta ao coração. ECO: reta à posição atrasada do coração.
    var _d = max(0.001, point_distance(x, y, _tx, _ty));
    x += (_tx - x) / _d * vel;
    y += (_ty - y) / _d * vel;
    x = clamp(x, _sw / 2 + 2, room_width  - _sw / 2 - 2);
    y = clamp(y, _sh / 2 + 2, room_height - _sh / 2 - 2);
}

// Hitbox = 80% do sprite (o coração já vem com RH_HEART_SHRINK em rh_heart_rect).
if (active) {
    var _hw = _sw * 0.8 / 2;
    var _hh = _sh * 0.8 / 2;
    if (rh_rect_hits_heart(x - _hw, y - _hh, x + _hw, y + _hh)) {
        rh_hurt_heart(id);   // destroy_on_hit = false: was_hit vira o single-hit
    }
}
