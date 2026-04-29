// De onde o settings foi aberto?
// "pause" = veio do obj_pause_menu
// "title" = veio da tela de título
// Quem criar este objeto deve definir called_from antes
called_from = "pause";

// ── ABAS DO MENU ──────────────────────────────────────
tabs        = ["Audio", "Controls"];
current_tab = 0; // 0 = Audio, 1 = Controls

// ── SEÇÃO AUDIO ───────────────────────────────────────
audio_items  = ["BGM Volume", "SFX Volume"];
audio_sel    = 0;

// ── SEÇÃO CONTROLS ────────────────────────────────────
key_items    = ["Move Up", "Move Down", "Move Left", "Move Right", "Sprint"];
key_globals  = ["key_up", "key_down", "key_left", "key_right", "key_sprint"];
key_sel      = 0;

// Estado de remapeamento: quando true, aguarda o próximo keypress
waiting_for_key = false;

// Posição na tela
menu_x = display_get_gui_width()  / 2;
menu_y = display_get_gui_height() / 2;

// Teclas reservadas que não podem ser remapeadas
reserved_keys = [vk_escape, vk_f11];

depth = -10; // garante que desenha por cima do obj_pause_menu

key_wait_timer = 0; // timer antes de aceitar input