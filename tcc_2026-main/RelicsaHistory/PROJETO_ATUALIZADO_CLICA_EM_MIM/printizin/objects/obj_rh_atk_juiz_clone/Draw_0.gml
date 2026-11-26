var _sc = 0.6;
var _w  = sprite_get_width(sprite_index)  * _sc;
var _h  = sprite_get_height(sprite_index) * _sc;
var _ox = x + _w / 2 + (state == 1 ? jitter : 0);
var _oy = y + _h / 2;

// TELEGRAFIA: linha vermelha do juiz até o ponto-alvo e além, atravessando a caixa.
if (state == 1) {
    draw_set_alpha(0.45 + 0.35 * dsin(telegraph_t * 12));
    draw_set_color(c_red);
    draw_line_width(_ox, _oy,
                    _ox + lengthdir_x(400, aim), _oy + lengthdir_y(400, aim), 2);
    draw_circle(_ox, _oy, 8, true);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

draw_sprite_ext(sprite_index, 0, x + (state == 1 ? jitter : 0), y,
                _sc, _sc, 0, c_white, image_alpha);
