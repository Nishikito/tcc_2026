if (!instance_exists(obj_rh_battle_controller)) exit;
var _ctrl = obj_rh_battle_controller;

if (_ctrl.state == BATTLE_STATE.ENEMY_TURN) {
    visible = true;

    var _xspd = (keyboard_check(global.key_right) - keyboard_check(global.key_left)) * move_spd;
    var _yspd = (keyboard_check(global.key_down)  - keyboard_check(global.key_up))   * move_spd;

    // Fallback setas físicas
    if (_xspd == 0 && _yspd == 0) {
        _xspd = (keyboard_check(vk_right) - keyboard_check(vk_left)) * move_spd;
        _yspd = (keyboard_check(vk_down)  - keyboard_check(vk_up))   * move_spd;
    }

    // Limites da caixa por coordenada — sem depender de solid
    if (instance_exists(obj_rh_battle_box)) {
        var _box  = obj_rh_battle_box;
        var _bx1  = _box.x;
        var _bx2  = _box.x + sprite_get_width(_box.sprite_index);
        var _by1  = _box.y;
        var _by2  = _box.y + sprite_get_height(_box.sprite_index);
        var _hw   = sprite_get_width(sprite_index) / 2;
        var _hh   = sprite_get_height(sprite_index) / 2;

        // Limita o movimento dentro da caixa
        x = clamp(x + _xspd, _bx1 + _hw + 2, _bx2 - _hw - 2);
        y = clamp(y + _yspd, _by1 + _hh + 2, _by2 - _hh - 2);
    } else {
        x += _xspd;
        y += _yspd;
    }

    // Dano das balas
    if (place_meeting(x, y, obj_rh_battle_bullet)) {
        var _dmg = calculate_enemy_damage();
        apply_damage_to_player(_dmg);
        with (obj_rh_battle_bullet) {
            if (place_meeting(other.x, other.y, id)) instance_destroy();
        }
    }

} else if (_ctrl.state == BATTLE_STATE.MENU
       ||  _ctrl.state == BATTLE_STATE.VICTORY
       ||  _ctrl.state == BATTLE_STATE.DEFEAT) {
    visible = true;
} else {
    visible = false;
}