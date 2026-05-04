// ── FECHAR COM ESC ─────────────────────────────────────
if (keyboard_check_pressed(vk_escape)) {
    if (waiting_for_key) {
        waiting_for_key = false;
    } else {
        audio_play_sound(sfxSelect, 0, false);
        instance_destroy();
    }
    exit;
}

// ── AGUARDANDO NOVA TECLA ──────────────────────────────
if (waiting_for_key) {
    if (key_wait_timer > 0) {
        key_wait_timer--;
        exit;
    }
    for (var k = 1; k < 256; k++) {
        if (keyboard_check_pressed(k)) {
            var is_reserved = false;
            for (var r = 0; r < array_length(reserved_keys); r++) {
                if (k == reserved_keys[r]) { is_reserved = true; break; }
            }
            if (!is_reserved) {
                variable_global_set(key_globals[key_sel], k);
                waiting_for_key = false;
                audio_play_sound(sfxSelect, 0, false);
            }
        }
    }
    exit;
}

// ── TROCAR ABA (Q / E) ─────────────────────────────────
if (keyboard_check_pressed(ord("Q"))) {
    current_tab = max(0, current_tab - 1);
    audio_play_sound(sfxSwitch, 0, false);
}
if (keyboard_check_pressed(ord("E"))) {
    current_tab = min(array_length(tabs) - 1, current_tab + 1);
    audio_play_sound(sfxSwitch, 0, false);
}

// ── ABA AUDIO ──────────────────────────────────────────
if (current_tab == 0) {
    if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"))) {
        audio_sel = max(0, audio_sel - 1);
        audio_play_sound(sfxSwitch, 0, false);
    }
    if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) {
        audio_sel = min(array_length(audio_items) - 1, audio_sel + 1);
        audio_play_sound(sfxSwitch, 0, false);
    }

    if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(ord("A"))) {
        if (audio_sel == 0) {
            // BGM — aplica direto nos assets de música
            global.vol_bgm = max(0.0, global.vol_bgm - 0.1);
            audio_sound_gain(SndCastleFunk, global.vol_bgm, 0);
            audio_sound_gain(sfxTitle,      global.vol_bgm, 0);
        } else {
            // SFX — aplica em todos os efeitos sonoros
            global.vol_sfx = max(0.0, global.vol_sfx - 0.1);
            audio_sound_gain(sfxSelect,      global.vol_sfx, 0);
            audio_sound_gain(sfxSwitch,      global.vol_sfx, 0);
            audio_sound_gain(sfxIntro,       global.vol_sfx, 0);
            audio_sound_gain(sfxDanielVc,    global.vol_sfx, 0);
            audio_sound_gain(sfxSansVoice,   global.vol_sfx, 0);
            audio_sound_gain(sfxRalseiSplat, global.vol_sfx, 0);
            audio_sound_gain(sfxNada,        global.vol_sfx, 0);
            audio_sound_gain(vc_text,        global.vol_sfx, 0);
        }
        audio_play_sound(sfxSwitch, 0, false);
    }

    if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) {
        if (audio_sel == 0) {
            global.vol_bgm = min(1.0, global.vol_bgm + 0.1);
            audio_sound_gain(SndCastleFunk, global.vol_bgm, 0);
            audio_sound_gain(sfxTitle,      global.vol_bgm, 0);
        } else {
            global.vol_sfx = min(1.0, global.vol_sfx + 0.1);
            audio_sound_gain(sfxSelect,      global.vol_sfx, 0);
            audio_sound_gain(sfxSwitch,      global.vol_sfx, 0);
            audio_sound_gain(sfxIntro,       global.vol_sfx, 0);
            audio_sound_gain(sfxDanielVc,    global.vol_sfx, 0);
            audio_sound_gain(sfxSansVoice,   global.vol_sfx, 0);
            audio_sound_gain(sfxRalseiSplat, global.vol_sfx, 0);
            audio_sound_gain(sfxNada,        global.vol_sfx, 0);
            audio_sound_gain(vc_text,        global.vol_sfx, 0);
        }
        audio_play_sound(sfxSwitch, 0, false);
    }
}

// ── ABA CONTROLS ───────────────────────────────────────
if (current_tab == 1) {
    if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"))) {
        key_sel = max(0, key_sel - 1);
        audio_play_sound(sfxSwitch, 0, false);
    }
    if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) {
        key_sel = min(array_length(key_items) - 1, key_sel + 1);
        audio_play_sound(sfxSwitch, 0, false);
    }
    if (keyboard_check_pressed(vk_enter)) {
        waiting_for_key = true;
        key_wait_timer  = 2;
        audio_play_sound(sfxSelect, 0, false);
    }
}