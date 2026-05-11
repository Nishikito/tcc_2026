// ── NAVEGAR ────────────────────────────────────────────
if (keyboard_check_pressed(ord("W")) || keyboard_check_pressed(vk_up)) {
    selected--;
    if (selected < 0) selected = array_length(menu_options) - 1;
    audio_play_sound(sfxSwitch, 0, false);
}
if (keyboard_check_pressed(ord("S")) || keyboard_check_pressed(vk_down)) {
    selected++;
    if (selected >= array_length(menu_options)) selected = 0;
    audio_play_sound(sfxSwitch, 0, false);
}

// ── CONFIRMAR ──────────────────────────────────────────
if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
    if (!instance_exists(obj_settings_menu)) {
        audio_play_sound(sfxSelect, 0, false);

        switch (selected) {
            case 0: // Resume Game
                instance_destroy();
                break;

            case 1: // Settings
                var s = instance_create_layer(0, 0, "Instances", obj_settings_menu);
                s.called_from = "pause";
                break;

            case 2: // Back to Title
                instance_activate_all();
                global.paused = false;
                if (instance_exists(ObjPlayer)) {
                    with (ObjPlayer) { instance_destroy(); }
                }
                room_goto(rm_title);
                break;
        }
    }
}

// ── FECHAR COM ESC ─────────────────────────────────────
if (keyboard_check_pressed(vk_escape)) {
    if (!instance_exists(obj_settings_menu)) {
        audio_play_sound(sfxSelect, 0, false);
        instance_destroy();
    }
}