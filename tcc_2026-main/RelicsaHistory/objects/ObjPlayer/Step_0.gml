


if (global.player_knocked_down) {

    if (keyboard_check(global.key_right) || keyboard_check(global.key_left) ||
    keyboard_check(global.key_up)    || keyboard_check(global.key_down)) {

        global.player_knocked_down = false;
    }
}
if (!global.dialog_active && !global.fade_active && !global.math_battle_active) {
    if (global.dialog_ended) {
        image_speed = 1;
        global.dialog_ended = false
    }

    right_key = keyboard_check(global.key_right);
    left_key  = keyboard_check(global.key_left);
    up_key    = keyboard_check(global.key_up);
    down_key  = keyboard_check(global.key_down);

    var _in_x = right_key - left_key;
    var _in_y = down_key - up_key;

    // 1) Velocidade ALVO: parado (0), andando ou correndo.
    //    Shift é lido a cada frame (antes dependia dos eventos apertou/soltou,
    //    que se perdiam se o diálogo começasse com Shift pressionado).
    var _target_spd = 0;
    if (_in_x != 0 || _in_y != 0) {
        last_dir_x = _in_x;
        last_dir_y = _in_y;
        _target_spd = default_spd;
        if (keyboard_check(global.key_sprint)) _target_spd = sprint_spd;
    }

    // 2) Aproxima a velocidade ATUAL da alvo, um degrau por frame.
    if (move_spd < _target_spd) {
        move_spd = min(move_spd + spd_accel, _target_spd);
    } else if (move_spd > _target_spd) {
        move_spd = max(move_spd - spd_decel, _target_spd);
    }

    // 3) Direção vem da última tecla pedida, então ao soltar ele desliza
    //    alguns pixels enquanto move_spd cai a zero (em vez de parar cravado).
    xspd = last_dir_x * move_spd;
    yspd = last_dir_y * move_spd;

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

    if place_meeting(x + xspd, y, ObjWall){
        xspd = 0;
    }
    if place_meeting(x, y + yspd, ObjWall){
        yspd = 0;
    }
    if place_meeting(x + xspd, y, ObjCarol) or place_meeting(x + xspd, y, obj_carol_teachers_room) {
        xspd = 0;
    }
    if place_meeting(x, y + yspd, ObjCarol) or place_meeting(x, y + yspd, obj_carol_teachers_room){
        yspd = 0;
    }

    x += xspd;
    y += yspd;

    // Animação acompanha a velocidade REAL: parado = 0, andando = 1,
    // correndo = 1 + run_anim_boost. Nada de salto brusco de 1 para 1.3.
    if (move_spd <= default_spd) {
        image_speed = move_spd / default_spd;
    } else {
        image_speed = 1 + run_anim_boost * (move_spd - default_spd) / (sprint_spd - default_spd);
    }

    if xspd == 0 && yspd == 0 {
        image_index = 0;
    }
}
else {
    image_speed = 0;
    image_index = 0;
    move_spd    = 0; // ao voltar do diálogo, recomeça do zero (sem deslizar)
    last_dir_x  = 0;
    last_dir_y  = 0;
}
if (global.player_knocked_down) {
    sprite_index = sprite_carol_defeat;
    image_index = 0;
}
// (removido: um 'image_speed = 1' aqui sobrescrevia a velocidade da animação todo frame)

//menu de pausa
if (keyboard_check_pressed(vk_escape)) {
    // Só abre se não tiver nenhum outro sistema ativo
    if (!global.dialog_active && !global.fade_active && !global.math_battle_active) {
        instance_create_layer(0, 0, "Instances", obj_pause_menu);
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

// Toggle fullscreen com F11
if (keyboard_check_pressed(vk_f11)) {
    window_set_fullscreen(!window_get_fullscreen());
}

// ── DIAGNÓSTICO (remover depois) ──────────────────────
if (keyboard_check_pressed(vk_f1)) {
    show_message(
        "dialog_active: "     + string(global.dialog_active)     + "\n" +
        "fade_active: "       + string(global.fade_active)       + "\n" +
        "math_battle_active: "+ string(global.math_battle_active)+ "\n" +
        "paused: "            + string(global.paused)            + "\n" +
        "wall aqui: "         + string(place_meeting(x, y, ObjWall)) + "\n" +
        "posição: "           + string(x) + ", " + string(y)
    );
}
// ──────────────────────────────────────────────────────


// ── CÂMERA COM INTERPOLAÇÃO ────────────────────────────
// Pegamos a câmera ativa da view 0
var cam = camera_get_active();

// Posição atual da câmera
var cam_w = camera_get_view_width(cam);
var cam_h = camera_get_view_height(cam);

// Posição alvo: player centralizado na câmera
var target_x = x - cam_w / 2;
var target_y = y - cam_h / 2;

// Limita a câmera às bordas da room para não mostrar fora dela
target_x = clamp(target_x, 0, room_width  - cam_w);
target_y = clamp(target_y, 0, room_height - cam_h);

// Posição atual da câmera
var cur_x = camera_get_view_x(cam);
var cur_y = camera_get_view_y(cam);

// lerp(a, b, fator) interpola entre a e b.
// 0.15 = câmera suave, 0.3 = mais rápida, 1.0 = instantânea (sem suavização)
var new_x = lerp(cur_x, target_x, 0.15);
var new_y = lerp(cur_y, target_y, 0.15);

// Arredonda para pixel inteiro — elimina o tearing causado por subpixels
new_x = round(new_x);
new_y = round(new_y);

camera_set_view_pos(cam, new_x, new_y);



