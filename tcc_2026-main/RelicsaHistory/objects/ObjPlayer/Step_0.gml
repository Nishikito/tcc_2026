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

    // Velocidade CONSTANTE (como no projeto alternativo): sem aceleração, sem deslize.
    // Andando = default_spd | segurando Shift = sprint_spd. Shift é lido a cada frame
    // (não depende de eventos de apertar/soltar, que se perdiam se o diálogo começasse com Shift pressionado).
    move_spd = default_spd;
    if (keyboard_check(global.key_sprint)) move_spd = sprint_spd;

    xspd = _in_x * move_spd;
    yspd = _in_y * move_spd;

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

    // ── Movimento em pixels INTEIROS, acumulando a fração ──────────
    x_remainder += xspd;
    y_remainder += yspd;

    var _move_x = round(x_remainder);
    var _move_y = round(y_remainder);

    x_remainder -= _move_x;
    y_remainder -= _move_y;

    // Colisão com paredes
    if (place_meeting(x + _move_x, y, ObjWall)) { _move_x = 0; x_remainder = 0; }
    if (place_meeting(x, y + _move_y, ObjWall)) { _move_y = 0; y_remainder = 0; }

    // Colisão com a Carol
    if (place_meeting(x + _move_x, y, ObjCarol) or place_meeting(x + _move_x, y, obj_carol_teachers_room)) {
        _move_x = 0; x_remainder = 0;
    }
    if (place_meeting(x, y + _move_y, ObjCarol) or place_meeting(x, y + _move_y, obj_carol_teachers_room)) {
        _move_y = 0; y_remainder = 0;
    }

    x += _move_x;
    y += _move_y;

    // Animação: 1x andando, 1.5x correndo (move_spd / default_spd)
    image_speed = move_spd / default_spd;

    if xspd == 0 && yspd == 0 {
        image_index = 0;
    }
}
else {
    image_speed = 0;
    image_index = 0;
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


