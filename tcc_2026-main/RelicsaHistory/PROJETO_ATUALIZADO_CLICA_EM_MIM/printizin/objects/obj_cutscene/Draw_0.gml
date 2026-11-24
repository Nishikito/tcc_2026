// Escuridão: tela preta com um "buraco" de luz em volta do player
if (dark_alpha <= 0.001) exit;

var _cam = view_camera[0];
var _vx = camera_get_view_x(_cam),     _vy = camera_get_view_y(_cam);
var _vw = camera_get_view_width(_cam), _vh = camera_get_view_height(_cam);

if (!surface_exists(dark_surf)) dark_surf = surface_create(_vw, _vh);

surface_set_target(dark_surf);
draw_clear_alpha(c_black, dark_alpha);

if (dark_radius > 0 && instance_exists(ObjPlayer)) {
    var _px = ObjPlayer.x - _vx;
    var _py = ObjPlayer.y - _vy;
    gpu_set_blendmode(bm_subtract);
    draw_set_color(c_white);
    draw_set_alpha(0.25);
    for (var i = 0; i < 4; i++) {                       // 4 círculos empilhados = borda macia
        draw_circle(_px, _py, dark_radius * (1 - i * 0.15), false);
    }
    draw_set_alpha(1);
    gpu_set_blendmode(bm_normal);
}
surface_reset_target();

draw_surface(dark_surf, _vx, _vy);
