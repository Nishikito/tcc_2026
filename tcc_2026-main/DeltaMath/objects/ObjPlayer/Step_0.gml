
if (global.player_knocked_down) {

    if (keyboard_check(ord("D")) || keyboard_check(ord("A")) || 
        keyboard_check(ord("W")) || keyboard_check(ord("S"))) {

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
    xspd = (right_key - left_key) * move_spd;
    yspd = (down_key - up_key) * move_spd;

    if keyboard_check_pressed(global.key_sprint) {
		move_spd    = sprint_spd;
		image_speed = 1.3;
	} else if keyboard_check_released(global.key_sprint) {
		move_spd    = default_spd;
		image_speed = 1;
	}

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
if (!global.dialog_active && !global.fade_active) {
    image_speed = 1; 
}

//menu de pausa
if (keyboard_check_pressed(vk_escape)) {
    // Só abre se não tiver nenhum outro sistema ativo
    if (!global.dialog_active && !global.fade_active && !global.math_battle_active) {
        instance_create_layer(0, 0, "Instances", obj_pause_menu);
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