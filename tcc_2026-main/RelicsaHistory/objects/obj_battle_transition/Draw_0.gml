var _cam = view_camera[0];
var _vx = camera_get_view_x(_cam);
var _vy = camera_get_view_y(_cam);
var _vw = camera_get_view_width(_cam);
var _vh = camera_get_view_height(_cam);

var _a = 0;
if (phase == 1)      _a = clamp(timer / t_dark, 0, 1);
else if (phase >= 2) _a = 1;

if (_a > 0) {
    draw_set_alpha(_a);
    draw_set_color(c_black);
    draw_rectangle(_vx - 1, _vy - 1, _vx + _vw + 1, _vy + _vh + 1, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
}