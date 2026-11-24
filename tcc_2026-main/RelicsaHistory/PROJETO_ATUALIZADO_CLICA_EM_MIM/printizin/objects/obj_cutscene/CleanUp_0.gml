// Roda ao destruir o objeto E quando a room muda (ex.: a cena manda o player pra outra room)
if (surface_exists(dark_surf)) surface_free(dark_surf);

// devolve a câmera se ela estava deslocada pela tremida
if (cam_jx != 0 || cam_jy != 0) {
    var _cam = view_camera[0];
    camera_set_view_pos(_cam, camera_get_view_x(_cam) - cam_jx, camera_get_view_y(_cam) - cam_jy);
}

global.cutscene_active = false;
global.dialog_active   = false;
