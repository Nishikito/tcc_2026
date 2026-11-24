/// Begin Step
// Mantém o player travado (a caixa de texto destrava ao terminar cada fala)
global.dialog_active = true;

// Desfaz a tremida do frame anterior ANTES do Step do ObjPlayer reposicionar a câmera
if (cam_jx != 0 || cam_jy != 0) {
    var _cam = view_camera[0];
    camera_set_view_pos(_cam, camera_get_view_x(_cam) - cam_jx, camera_get_view_y(_cam) - cam_jy);
    cam_jx = 0;
    cam_jy = 0;
}
