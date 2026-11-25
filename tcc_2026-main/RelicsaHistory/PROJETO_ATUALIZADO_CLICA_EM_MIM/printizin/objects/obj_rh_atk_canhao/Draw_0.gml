if (clip_to_box) rh_draw_clipped(sprite_index, image_index, x, y, image_xscale, image_yscale, image_blend, image_alpha); else draw_self();
if (t <= warn_t) rh_draw_warning(x - 6, y - 6, x + sprite_get_width(sprite_index) + 6, y + sprite_get_height(sprite_index) + 6, t);
var _ox = x + sprite_get_width(sprite_index) / 2;
var _oy = y + sprite_get_height(sprite_index) / 2;
draw_set_color(c_red);
draw_line(_ox, _oy, _ox + lengthdir_x(52, aim), _oy + lengthdir_y(52, aim));
draw_set_color(c_white);