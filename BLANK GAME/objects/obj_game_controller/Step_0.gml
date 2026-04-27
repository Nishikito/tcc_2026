global.paused = false;

// toggle pause SEMPRE funciona
if (keyboard_check_pressed(vk_escape)) {
    global.paused = !global.paused;
}

// garante que o player existe no jogo
if (room == rm_game) {
    if (!instance_exists(obj_player)) {
        instance_create_layer(100, 100, "Instances", obj_player);
    }
}