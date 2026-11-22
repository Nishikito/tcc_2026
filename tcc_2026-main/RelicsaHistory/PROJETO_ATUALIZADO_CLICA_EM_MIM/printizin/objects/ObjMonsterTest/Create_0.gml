// Filhos (ObjMonster*) definem enemy_id ANTES de chamar event_inherited(). Sozinho, é o monstro antigo.
if (!variable_instance_exists(id, "enemy_id")) enemy_id = "MathMonster";

if(variable_global_exists("defeated_enemies")) {
    for(var i = 0; i < array_length(global.defeated_enemies); i++) {
        if(global.defeated_enemies[i] == enemy_id) {

            instance_destroy();
            exit;
        }
    }
}

state = "idle";
detection_range = 80;
speed_follow = 2;

alert_timer = 0;
alert_duration = 1 * 60; 
caught_timer = 0;
caught_duration = 1.5 * 60;


alert_sprite = SprAlert;
show_alert = false;

