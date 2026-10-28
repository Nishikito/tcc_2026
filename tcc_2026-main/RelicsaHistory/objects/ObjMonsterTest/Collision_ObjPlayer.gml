// Não executar fora das salas de exploração
if (room == rm_rh_battle) exit;

// Segurança: só acessa ObjPlayer se ele existir
if (!instance_exists(ObjPlayer)) exit;


if (state == "chasing") {
  
    if (variable_global_exists("defeated_enemies")) {
        for(var i = 0; i < array_length(global.defeated_enemies); i++) {
            if(global.defeated_enemies[i] == enemy_id) {
                instance_destroy();
                exit;
            }
        }
    }
    
    state = "caught";
    caught_timer = caught_duration;
    
    with (ObjPlayer) {
        pre_battle_x = x;
        pre_battle_y = y;
        global.pre_battle_room = room;//talvez precise trocar
    }
    global.current_enemy_id = enemy_id;
    if (!instance_exists(obj_battle_transition)) {
    var _t = instance_create_depth(0, 0, -50000, obj_battle_transition);
    _t.enemy          = id;
    _t.enemy_id_value = enemy_id;
}
}