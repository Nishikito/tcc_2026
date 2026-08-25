if (!instance_exists(obj_rh_battle_controller)) exit;
if (obj_rh_battle_controller.state == BATTLE_STATE.ENEMY_TURN
&&  instance_exists(obj_rh_battle_player)) {
    var _dir = point_direction(x, y, obj_rh_battle_player.x, obj_rh_battle_player.y);
    var _b = instance_create_layer(x, y, "Bullets", obj_rh_battle_bullet);
    _b.direction = _dir;
    _b.speed     = spd_bala;
}
alarm[0] = cadencia + irandom(20);