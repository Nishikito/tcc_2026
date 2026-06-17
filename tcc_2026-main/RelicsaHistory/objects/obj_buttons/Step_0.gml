if (!instance_exists(obj_settings_menu)) {

    if (image_index = 0 and keyboard_check_pressed(vk_enter)) {
        audio_play_sound(sfxSelect, 0, false);
        global.intro_played = false;
        audio_stop_sound(sfxTitle);
        room_goto(global.start_room);
        var instantiaed = instance_create_layer(global.start_x, global.start_y, "Player", ObjPlayer);
        instantiaed.face = UP;
        instantiaed.sprite_index = instantiaed.sprite[UP];
        global.new_game = false;

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