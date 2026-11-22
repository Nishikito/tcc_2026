/// @param enemy_name
/// @param enemy_hp
/// @param enemy_sprite
function start_math_battle(enemy_name, enemy_hp, enemy_sprite) {
    if(room == rm_math_battle) {
        with(instance_create_depth(0, 0, -1000, obj_math_battle)) {
            enemy_name_text = enemy_name;
            enemy_max_hp = enemy_hp;
            enemy_current_hp = enemy_hp;
        }
        global.dialog_active = true;
    }
}