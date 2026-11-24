/// End Step (roda depois do Step do ObjPlayer, que é quem posiciona a câmera)

// ── executa o passo atual da cena ──
if (current_step >= array_length(scene_info)) {
    instance_destroy();
    exit;
}

var _passo = scene_info[current_step];
var _fn    = _passo[0];
var _args  = [];
for (var i = 1; i < array_length(_passo); i++) array_push(_args, _passo[i]);

var _done = script_execute_ext(_fn, _args);
if (_done == undefined || _done) {
    current_step++;
    action_started = false;
}

// ── tremida da câmera ──
if (shake_on && shake_str > 0) {
    var _cam = view_camera[0];
    var _w = camera_get_view_width(_cam), _h = camera_get_view_height(_cam);
    var _bx = camera_get_view_x(_cam),    _by = camera_get_view_y(_cam);
    var _nx = clamp(_bx + irandom_range(-shake_str, shake_str), 0, max(0, room_width  - _w));
    var _ny = clamp(_by + irandom_range(-shake_str, shake_str), 0, max(0, room_height - _h));
    cam_jx = _nx - _bx;
    cam_jy = _ny - _by;
    camera_set_view_pos(_cam, _nx, _ny);
}
