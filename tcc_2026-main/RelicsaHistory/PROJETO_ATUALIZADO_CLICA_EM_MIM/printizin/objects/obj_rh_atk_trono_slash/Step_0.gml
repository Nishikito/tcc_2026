t++;

var _inicio = aviso_frames + delay_frames;
if (t < _inicio) exit;              // ainda é só o fio de aviso

var _a = t - _inicio;
if (_a <= active_frames && !was_hit
    && rh_segment_hits_heart(x1, y1, x2, y2, largura * RH_HEART_SHRINK / 2)) {
    rh_hurt_heart(id);
}

if (_a > active_frames + fade_frames) {
    rh_debug_destroy("corte terminou");
    instance_destroy();
}
