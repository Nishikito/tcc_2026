if (keyboard_check(vk_up)) {
    if (scroll_y > 0) {
        scroll_y -= scroll_speed;
        if (scroll_y < 0) scroll_y = 0; 
    }
}


if (keyboard_check(vk_down)) {
    if (scroll_y < max_scroll) {
        scroll_y += scroll_speed;
        if (scroll_y > max_scroll) scroll_y = max_scroll; 
    }
}


camera_set_view_pos(view_camera[0], 0, scroll_y);


if (keyboard_check_pressed(vk_enter)) {
    audio_play_sound(sfxSelect, 0, false)	
    room_goto(initial_room);
}
