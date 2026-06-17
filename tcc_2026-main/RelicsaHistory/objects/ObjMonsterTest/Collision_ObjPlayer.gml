
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
        pre_battle_room = room;
    }
    global.current_enemy_id = enemy_id;
    global.dialog_active = true;
}