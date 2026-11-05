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
    // enemy e enemy_id_value PRECISAM ir no struct: o Create da transição lê esses valores
    // e ele roda DENTRO do instance_create_depth, antes da linha seguinte.
    instance_create_depth(0, 0, -50000, obj_battle_transition, {
        enemy: id,
        enemy_id_value: enemy_id
    });
}
}