if ((!global.new_game && !global.intro_played) || global.carol_defeated) {
    sprite_index = spr_fade_intro;
    image_index = image_number - 1;
    image_speed = -0.0667;
    depth = -10000;
    

    global.fade_active = true;
    
    if (global.carol_defeated) {
        audio_play_sound(sfxIntro, 0, false);
       
    } else {
        audio_play_sound(sfxIntro, 0, false);
        global.intro_played = true;
    }
} else {
    instance_destroy();
}