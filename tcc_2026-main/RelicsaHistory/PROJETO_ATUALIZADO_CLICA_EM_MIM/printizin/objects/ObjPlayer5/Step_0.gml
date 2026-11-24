global.playtime += delta_time / 1000000;

// Libera o player do estado de derrota ao mover
if (global.player_knocked_down) {
    if (keyboard_check(ord("D")) || keyboard_check(ord("A")) || 
        keyboard_check(ord("W")) || keyboard_check(ord("S"))) {
        global.player_knocked_down = false;
    }
}

if (keyboard_check_pressed(vk_escape)) {
    if (!global.dialog_active && !global.fade_active
    && !global.math_battle_active) {
        if (!instance_exists(obj_pause_menu)) {
            instance_create_layer(0, 0, "Instances", obj_pause_menu);
        }
    }
}

// Abrir inventário
if (keyboard_check_pressed(global.key_inventory)) {
    if (!global.dialog_active && !global.fade_active && !global.math_battle_active && !global.paused) {
        if (!instance_exists(obj_inventory)) {
            instance_create_layer(0, 0, "Instances", obj_inventory);
        }
    }
}

// Movimento — só funciona fora de diálogo, fade e batalha
if (!global.dialog_active && !global.fade_active && !global.math_battle_active) {
    
    // Reseta animação ao terminar diálogo
    if (global.dialog_ended) {
        image_speed = 1;
        global.dialog_ended = false;
    }

    // Input de movimento
    right_key = keyboard_check(global.key_right);
    left_key  = keyboard_check(global.key_left);
    up_key    = keyboard_check(global.key_up);
    down_key  = keyboard_check(global.key_down);

    xspd = (right_key - left_key) * move_spd;
    yspd = (down_key - up_key) * move_spd;

    // Sprint
    if keyboard_check_pressed(global.key_sprint) {
        move_spd = sprint_spd; 
    } else if keyboard_check_released(global.key_sprint) {
        move_spd = default_spd;
    }

    // Atualiza direção do player
    mask_index = sprite[DOWN];
    if yspd == 0 {
        if xspd > 0 { face = RIGHT };
        if xspd < 0 { face = LEFT };
    }
    if xspd > 0 && face == LEFT  { face = RIGHT };
    if xspd < 0 && face == RIGHT { face = LEFT };
    if xspd == 0 {
        if yspd > 0 { face = DOWN };
        if yspd < 0 { face = UP };
    }
    if yspd > 0 && face == UP   { face = DOWN };
    if yspd < 0 && face == DOWN { face = UP };

    sprite_index = sprite[face];

    // ===== movimento em pixels inteiros, acumulando a fração =====
    x_remainder += xspd;
    y_remainder += yspd;

    var _move_x = round(x_remainder);
    var _move_y = round(y_remainder);

    x_remainder -= _move_x;
    y_remainder -= _move_y;

    // Colisão com paredes
    if place_meeting(x + _move_x, y, ObjWall) { _move_x = 0; x_remainder = 0; }
    if place_meeting(x, y + _move_y, ObjWall) { _move_y = 0; y_remainder = 0; }

    // Colisão com a Carol
    if place_meeting(x + _move_x, y, ObjCarol) or place_meeting(x + _move_x, y, obj_carol_teachers_room) { _move_x = 0; x_remainder = 0; }
    if place_meeting(x, y + _move_y, ObjCarol) or place_meeting(x, y + _move_y, obj_carol_teachers_room) { _move_y = 0; y_remainder = 0; }

    x += _move_x;
    y += _move_y;

	if (_move_x != 0 || _move_y != 0) {
	    array_push(pos_history, {x: x, y: y});
	    var _max = follow_delay * (array_length(global.party) + 1) + 2;
	    var _extra = array_length(pos_history) - _max;
	    if (_extra > 0) array_delete(pos_history, 0, _extra);
	}
    // ===== FIM =====

    // Para a animação quando parado
    if xspd == 0 && yspd == 0 {
        image_index = 0;
    }
} else {
    // Congela animação durante diálogo, fade ou batalha (mas deixa a cutscene animar o player andando)
    if (!global.cutscene_active) {
        image_speed = 0;
        image_index = 0;
    }
}

// Sprite de derrota da Carol
if (global.player_knocked_down) {
    sprite_index = sprite_carol_defeat;
    image_index = 0;
}

// Garante animação ativa fora de diálogo e fade, na velocidade certa (normal ou sprint)
if (!global.dialog_active && !global.fade_active) {
    image_speed = move_spd / default_spd;
}