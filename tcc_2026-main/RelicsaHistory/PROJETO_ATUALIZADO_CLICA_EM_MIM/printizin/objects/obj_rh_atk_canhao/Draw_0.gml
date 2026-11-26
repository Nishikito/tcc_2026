var _cx = x + sprite_get_width(sprite_index) / 2 + jitter;
var _cy = y + sprite_get_height(sprite_index) / 2;
var _a  = locked ? aim_lock : aim;

// spr_canhao_attack tem a BOCA PARA A ESQUERDA (180°): compensa para olhar para _a.
var _sprite_a = _a - 180;
var _warn_w   = 16;
var _mouth    = sprite_get_width(sprite_index) / 2 - 2;
var _mx = _cx + lengthdir_x(_mouth, _a);
var _my = _cy + lengthdir_y(_mouth, _a);

// AVISO: linha vermelha até o disparo; some quando a 1ª bala sai.
if (t <= warn_t) {
    draw_set_alpha(0.30 + 0.35 * dsin(t * 10));
    draw_set_color(c_red);
    draw_line_width(_mx, _my, _mx + lengthdir_x(420, _a), _my + lengthdir_y(420, _a), _warn_w);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

rh_draw_sprite_pivot(sprite_index, _cx, _cy,
                     sprite_get_width(sprite_index) / 2,
                     sprite_get_height(sprite_index) / 2,
                     _sprite_a, 1, 1, c_white, 1);
