bob_timer += 0.06;

near_player = false;
if (instance_exists(ObjPlayer)) {
    near_player = (point_distance(x, y, ObjPlayer.x, ObjPlayer.y) < 28);
}

// Não abre durante diálogo, pausa ou se o menu já estiver aberto
// current_time >= save_point_unlock_time: depois de fechar o menu, espera um instante (o mesmo Enter não reabre)
var _free = (!global.dialog_active && !global.paused && !instance_exists(obj_save_slots)
             && current_time >= global.save_point_unlock_time);

if (near_player && _free && keyboard_check_pressed(global.key_interact)) {
    var _menu = instance_create_layer(0, 0, "Instances", obj_save_slots);
    _menu.mode = "save";
}