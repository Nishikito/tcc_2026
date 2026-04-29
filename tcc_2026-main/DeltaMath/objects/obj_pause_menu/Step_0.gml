// ── NAVEGAR PARA CIMA ──────────────────────────────────
if (keyboard_check_pressed(ord("W")) || keyboard_check_pressed(vk_up)) {
    selected--;
    // Se passou do topo, vai para o último item (navegação circular)
    if (selected < 0) selected = array_length(menu_options) - 1;
    audio_play_sound(sfxSwitch, 0, false);
}

// ── NAVEGAR PARA BAIXO ─────────────────────────────────
if (keyboard_check_pressed(ord("S")) || keyboard_check_pressed(vk_down)) {
    selected++;
    // Se passou do fim, volta para o primeiro
    if (selected >= array_length(menu_options)) selected = 0;
    audio_play_sound(sfxSwitch, 0, false);
}

// ── CONFIRMAR SELEÇÃO ──────────────────────────────────
if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
    audio_play_sound(sfxSelect, 0, false);

    switch (selected) {

        case 0: // Resume Game
            // Destruir o menu já ativa tudo no CleanUp
            instance_destroy();
            break;

        case 1: // Settings
            // Por agora, só um placeholder — você vai expandir isso depois
            show_debug_message("Settings: ainda não implementado");
            break;

        case 2: // Back to Title
			audio_play_sound(sfxSelect, 0, false);
			instance_activate_all();
			global.paused = false;

    // Destrói o player antes de trocar de room
    // O "if instance_exists" é segurança — evita erro se o player não existir
			if (instance_exists(ObjPlayer)) {
				with (ObjPlayer) { instance_destroy(); }
			}

			room_goto(rm_title);
			break;
}

// ── FECHAR COM ESC TAMBÉM ──────────────────────────────
if (keyboard_check_pressed(vk_escape)) {
    audio_play_sound(sfxSelect, 0, false);
    instance_destroy(); // CleanUp cuida do resto
}
}