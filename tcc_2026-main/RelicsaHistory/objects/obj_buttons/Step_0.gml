// O Enter que FECHA um menu não pode agir aqui no mesmo instante (senão abriria o menu de novo
// ou dispararia outra opção). Com algum menu aberto, e por 10 frames depois, o título fica parado.
if (!variable_instance_exists(id, "input_cooldown")) input_cooldown = 0;
if (instance_exists(obj_settings_menu) || instance_exists(obj_save_slots)) {
    input_cooldown = 10;
    exit;
}
if (input_cooldown > 0) {
    input_cooldown--;
    exit;
}

if (true) {

    if (image_index = 0 and keyboard_check_pressed(vk_enter)) {
        audio_play_sound(sfxSelect, 0, false);

        // BEGIN GAME abre a tela de arquivos. Ela decide: slot vazio = NOVO JOGO,
        // slot com save = CONTINUAR (a lógica está em game_start_new / game_load, scr_save_system).
        var _slots = instance_create_layer(0, 0, "Instances", obj_save_slots);
        _slots.mode = "title";

    } else if (image_index = 1 and keyboard_check_pressed(vk_enter)) {
        audio_play_sound(sfxSelect, 0, false);
        var s = instance_create_layer(0, 0, "Instances", obj_settings_menu);
        s.called_from = "title";

    } else if (image_index = 2 and keyboard_check_pressed(vk_enter)) {
        audio_play_sound(sfxSelect, 0, false);

    } else if (image_index = 3 and keyboard_check_pressed(vk_enter)) {
        room_goto(RoomCredits);
        audio_play_sound(sfxSelect, 0, false);
    }

}
