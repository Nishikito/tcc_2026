// Fechada: não desenha nada
if (anim <= 0) exit;

var _w  = sprite_get_width(sprite_index);
var _h  = sprite_get_height(sprite_index);
var _cx = x + _w / 2;     // centro da caixa: ela cresce e gira em torno dele
var _cy = y + _h / 2;

// Do rastro mais antigo (i = BOX_TRAIL_COUNT) até a caixa de verdade (i = 0)
for (var i = BOX_TRAIL_COUNT; i >= 0; i--) {
    // cada cópia fica "atrasada" na animação, nos dois sentidos (abrindo ou fechando)
    var _an = clamp(anim - anim_dir * i * trail_gap, 0, 1);
    if (i > 0 && (!moving || _an <= 0)) continue;   // sem rastro com a caixa parada

    var _t = 1 - power(1 - _an, 3);   // ease-out cúbico: começa rápido, desacelera no fim
    var _s = _t;                      // escala 0 → 1
    var _a = (1 - _t) * BOX_SPIN_DEGREES;   // ângulo: gira e termina em 0

    var _alpha = 1;
    if (i > 0) _alpha = BOX_TRAIL_ALPHA * (1 - i / (BOX_TRAIL_COUNT + 1));

    // O sprite tem origem no canto (0,0). Para escalar/girar em torno do CENTRO,
    // calculamos onde o canto fica depois de escalar e girar.
    var _len = point_distance(0, 0, _w / 2 * _s, _h / 2 * _s);
    var _dir = point_direction(0, 0, _w / 2 * _s, _h / 2 * _s) + _a;

    draw_sprite_ext(sprite_index, 0,
                    _cx - lengthdir_x(_len, _dir),
                    _cy - lengthdir_y(_len, _dir),
                    _s, _s, _a, BOX_TINT, _alpha);
}
