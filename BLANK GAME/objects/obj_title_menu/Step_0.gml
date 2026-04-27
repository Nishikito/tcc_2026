switch (state) {

    case MENU_STATE.TITLE:
        
        if (keyboard_check_pressed(vk_up)) index--;
        if (keyboard_check_pressed(vk_down)) index++;

        if (index < 0) index = array_length(options) - 1;
        if (index >= array_length(options)) index = 0;

        if (keyboard_check_pressed(vk_enter)) {
            switch (index) {
                case 0:
                    state = MENU_STATE.SAVE_SELECT;
                break;

                case 1:
                    show_debug_message("Settings depois");
                break;

                case 2:
                    game_end();
                break;
            }
        }
        
    break;


    case MENU_STATE.SAVE_SELECT:
        
        if (keyboard_check_pressed(vk_up)) save_index--;
        if (keyboard_check_pressed(vk_down)) save_index++;

        if (save_index < 0) save_index = array_length(save_options) - 1;
        if (save_index >= array_length(save_options)) save_index = 0;

        if (keyboard_check_pressed(vk_enter)) {
            switch (save_index) {
                case 0:
                    state = MENU_STATE.NEW_SAVE;
                break;

                case 1:
                    show_debug_message("Load depois");
                break;

                case 2:
                    state = MENU_STATE.TITLE;
                break;
            }
        }
        
    break;


    case MENU_STATE.NEW_SAVE:
    
    // =========================
    // INPUT DE TEXTO (CORRIGIDO)
    // =========================
    
    if (string_length(keyboard_string) > 0) {
        
        for (var i = 1; i <= string_length(keyboard_string); i++) {
            
            var char = string_char_at(keyboard_string, i);
            
            // ignora teclas especiais
            if (char != chr(13) && char != chr(8)) {
                
                if (string_length(player_name) < max_name_length) {
                    player_name += string_upper(char);
                }
            }
        }
        
        // limpa depois de usar (ESSENCIAL)
        keyboard_string = "";
    }
    
    
    // =========================
    // BACKSPACE
    // =========================
    
    if (keyboard_check_pressed(vk_backspace)) {
        if (string_length(player_name) > 0) {
            player_name = string_delete(player_name, string_length(player_name), 1);
        }
    }
    
    
    // =========================
    // CONFIRMAR NOME
    // =========================
    
    if (keyboard_check_pressed(vk_enter)) {
        if (string_length(player_name) > 0) {
            
            show_debug_message("Nome: " + player_name);
            
            room_goto(rm_game);
        }
    }
    
    
    // =========================
    // VOLTAR
    // =========================
    
    if (keyboard_check_pressed(vk_escape)) {
        player_name = "";
        state = MENU_STATE.SAVE_SELECT;
    }

	break;
}