if (logo_alpha < 1) {
    logo_alpha += fade_speed;
    logo_scale = lerp(logo_scale, target_scale, scale_speed);
    

    shake_x = random_range(-shake_amount, shake_amount);
    shake_y = random_range(-shake_amount, shake_amount);
} else {

    logo_ready = true;
    show_enter_text = true;
    

    shake_x = random_range(-1, 1);
    shake_y = random_range(-1, 1);
}


if (show_enter_text) {
    enter_text_alpha = 0.5 + sin(current_time * 0.005) * 0.5;
}


if (logo_ready && keyboard_check_pressed(vk_enter)) {
    audio_play_sound(sfxSelect, 0, false);
    room_goto(rm_title); 
}