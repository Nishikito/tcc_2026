// Ao tocar no player, cria o fade de transição e passa os dados do destino
if place_meeting(x, y, ObjPlayer) and !instance_exists(obj_fade) and keyboard_check_pressed(vk_enter) {
    var instantiated = instance_create_depth(0, 0, -99999, obj_fade);
    instantiated.target_x = target_x;
    instantiated.target_y = target_y;
    instantiated.target_room = target_room;
}