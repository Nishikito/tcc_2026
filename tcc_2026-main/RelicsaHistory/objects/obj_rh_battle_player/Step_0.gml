if (!instance_exists(obj_rh_battle_controller)) exit;
var _ctrl = obj_rh_battle_controller;

if (_ctrl.state == BATTLE_STATE.ENEMY_TURN) {
    visible = true;

    xspd = (keyboard_check(global.key_right) - keyboard_check(global.key_left)) * move_spd;
    yspd = (keyboard_check(global.key_down)  - keyboard_check(global.key_up))   * move_spd;

    // Colisão com as bordas da caixa (por dentro)
    if (place_meeting(x + xspd, y, obj_rh_battle_box)) {
        while (!place_meeting(x + sign(xspd), y, obj_rh_battle_box)) x += sign(xspd);
        xspd = 0;
    }
    x += xspd;

    if (place_meeting(x, y + yspd, obj_rh_battle_box)) {
        while (!place_meeting(x, y + sign(yspd), obj_rh_battle_box)) y += sign(yspd);
        yspd = 0;
    }
    y += yspd;

    // Dano das balas
    if (place_meeting(x, y, obj_rh_battle_bullet)) {
        var _dmg = calculate_enemy_damage();
        apply_damage_to_player(_dmg);
        with (obj_rh_battle_bullet) {
            if (place_meeting(other.x, other.y, id)) instance_destroy();
        }
    }
} else {
    visible = false;
}