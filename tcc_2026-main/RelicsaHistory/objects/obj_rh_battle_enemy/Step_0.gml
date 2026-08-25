if (!instance_exists(obj_rh_battle_controller)) exit;
if (obj_rh_battle_controller.state == BATTLE_STATE.ENEMY_TURN) {
    tempo += 3;
    y = centro_y + dsin(tempo) * 20;
    image_angle = dsin(tempo) * 15;
}