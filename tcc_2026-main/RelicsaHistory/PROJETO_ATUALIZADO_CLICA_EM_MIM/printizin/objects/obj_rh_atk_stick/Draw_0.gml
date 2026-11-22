// Gira em volta do CENTRO do sprite (a origem dele é o canto superior esquerdo)
var _w   = sprite_get_width(sprite_index);
var _h   = sprite_get_height(sprite_index);
var _len = point_distance(0, 0, _w / 2, _h / 2);
var _dir = point_direction(0, 0, _w / 2, _h / 2) + rot;
draw_sprite_ext(sprite_index, 0,
                x + _w / 2 - lengthdir_x(_len, _dir),
                y + _h / 2 - lengthdir_y(_len, _dir),
                1, 1, rot, c_white, 1);

if (RH_ATK_DEBUG_ZONES && active) {
    draw_set_color(c_red);
    draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);
    draw_set_color(c_white);
}
