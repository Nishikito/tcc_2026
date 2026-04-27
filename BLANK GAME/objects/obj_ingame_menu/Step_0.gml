if (!variable_global_exists("paused")) {
    global.paused = false;
}

// só funciona se estiver pausado
if (!global.paused) exit;


// navegação
if (keyboard_check_pressed(vk_up)) index--;
if (keyboard_check_pressed(vk_down)) index++;

if (index < 0) index = array_length(options) - 1;
if (index >= array_length(options)) index = 0;


// seleção
if (keyboard_check_pressed(vk_enter)) {

    switch (index) {

        case 0: // RESUME
            global.paused = false;
        break;

        case 1: // MENU
            
            global.paused = false;

            // destrói player antes de sair
            with (obj_player) instance_destroy();

            room_goto(rm_menu); // usa o nome correto
        break;

        case 2: // EXIT
            game_end();
        break;
    }
}