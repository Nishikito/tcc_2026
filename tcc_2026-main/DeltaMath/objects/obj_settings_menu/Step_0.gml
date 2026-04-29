// ── FECHAR COM ESC ────────────────────────────────────
if (keyboard_check_pressed(vk_escape)) {
    if (waiting_for_key) {
        // Cancela o remapeamento sem mudar nada
        waiting_for_key = false;
    } else {
        audio_play_sound(sfxSelect, 0, false);
        instance_destroy();
    }
    exit; // não processa mais nada neste frame
}

// ── SE ESTÁ AGUARDANDO UMA TECLA NOVA ─────────────────
if (waiting_for_key) {

    // Espera 2 frames antes de aceitar qualquer tecla
    // Isso evita capturar o ENTER que abriu o remapeamento
    if (key_wait_timer > 0) {
        key_wait_timer--;
        exit;
    }

    // Começa em 1 para ignorar vk_nokey (k=0)
    for (var k = 1; k < 256; k++) {
        if (keyboard_check_pressed(k)) {

            var is_reserved = false;
            for (var r = 0; r < array_length(reserved_keys); r++) {
                if (k == reserved_keys[r]) {
                    is_reserved = true;
                    break;
                }
            }

            if (!is_reserved) {
                variable_global_set(key_globals[key_sel], k);
                waiting_for_key = false;
                audio_play_sound(sfxSelect, 0, false);
            }
			// Dentro do bloco current_tab == 1, no ENTER:
			if (keyboard_check_pressed(vk_enter)) {
				waiting_for_key  = true;
				key_wait_timer   = 2; // aguarda 2 frames antes de escutar
				audio_play_sound(sfxSelect, 0, false);
			}
        }
    }
    exit;
}
// ── NAVEGAR ENTRE ABAS (Q / E) ────────────────────────
if (keyboard_check_pressed(ord("Q"))) {
    current_tab = max(0, current_tab - 1);
    audio_play_sound(sfxSwitch, 0, false);
}
if (keyboard_check_pressed(ord("E"))) {
    current_tab = min(array_length(tabs) - 1, current_tab + 1);
    audio_play_sound(sfxSwitch, 0, false);
}

// ── ABA AUDIO ─────────────────────────────────────────
if (current_tab == 0) {

    if (keyboard_check_pressed(vk_up)   || keyboard_check_pressed(ord("W"))) {
        audio_sel = max(0, audio_sel - 1);
        audio_play_sound(sfxSwitch, 0, false);
    }
    if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) {
        audio_sel = min(array_length(audio_items) - 1, audio_sel + 1);
        audio_play_sound(sfxSwitch, 0, false);
    }

    // Seta esquerda/direita ajusta o volume em passos de 0.1
    if (keyboard_check_pressed(vk_left)  || keyboard_check_pressed(ord("A"))) {
        if (audio_sel == 0) {
            global.vol_bgm = max(0.0, global.vol_bgm - 0.1);
            audio_master_gain(global.vol_bgm); // aplica imediatamente
        } else {
            global.vol_sfx = max(0.0, global.vol_sfx - 0.1);
        }
        audio_play_sound(sfxSwitch, 0, false);
    }
    if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(ord("D"))) {
        if (audio_sel == 0) {
            global.vol_bgm = min(1.0, global.vol_bgm + 0.1);
            audio_master_gain(global.vol_bgm);
        } else {
            global.vol_sfx = min(1.0, global.vol_sfx + 0.1);
        }
        audio_play_sound(sfxSwitch, 0, false);
    }
}

// ── ABA CONTROLS ──────────────────────────────────────
if (current_tab == 1) {

    if (keyboard_check_pressed(vk_up)   || keyboard_check_pressed(ord("W"))) {
        key_sel = max(0, key_sel - 1);
        audio_play_sound(sfxSwitch, 0, false);
    }
    if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(ord("S"))) {
        key_sel = min(array_length(key_items) - 1, key_sel + 1);
        audio_play_sound(sfxSwitch, 0, false);
    }

    // ENTER inicia o remapeamento da tecla selecionada
    if (keyboard_check_pressed(vk_enter)) {
        waiting_for_key = true;
        audio_play_sound(sfxSelect, 0, false);
    }
}