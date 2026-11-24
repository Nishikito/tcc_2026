if (global.battle_return) {
    global.battle_return = false;
    if (room == global.pre_battle_room) {
        x = global.pre_battle_x;
        y = global.pre_battle_y;

        var _cam = view_camera[0];
        var _cw = camera_get_view_width(_cam);
        var _ch = camera_get_view_height(_cam);
        camera_set_view_pos(_cam, clamp(x - _cw / 2, 0, room_width - _cw), clamp(y - _ch / 2, 0, room_height - _ch));
    }
}
sort_assets_convert();
var raio = 4;
while (place_meeting(x, y, ObjWall) && raio < 128) {
    // Testa 4 direções com raio crescente
    if (!place_meeting(x + raio, y, ObjWall)) { x += raio; break; }
    if (!place_meeting(x - raio, y, ObjWall)) { x -= raio; break; }
    if (!place_meeting(x, y + raio, ObjWall)) { y += raio; break; }
    if (!place_meeting(x, y - raio, ObjWall)) { y -= raio; break; }
    raio += 4; // aumenta o raio a cada iteração
}
party_spawn_followers();
if (global.pending_scene != "") {
    var _s = global.pending_scene;
    global.pending_scene = "";
    cutscene_play(_s);
}
