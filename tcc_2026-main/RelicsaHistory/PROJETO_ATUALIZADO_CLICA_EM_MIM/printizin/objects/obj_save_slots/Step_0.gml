// ── Inicialização (1º frame: o modo já foi definido por quem criou) ──
if (!init_done) {
    init_done = true;
    if (mode == "save") scr_pause_game();   // congela o jogo; o menu continua ativo
    refresh_slots();
    if (mode == "save" && global.save_slot >= 0) sel = global.save_slot;   // começa no slot ativo
}

cursor_timer += UI_CURSOR_BOB_SPEED;

// Primeiros frames: ignora teclas (o Enter que abriu o menu)
if (input_lock > 0) { input_lock--; exit; }

var _up    = keyboard_check_pressed(global.key_up)    || keyboard_check_pressed(vk_up);
var _down  = keyboard_check_pressed(global.key_down)  || keyboard_check_pressed(vk_down);
var _left  = keyboard_check_pressed(global.key_left)  || keyboard_check_pressed(vk_left);
var _right = keyboard_check_pressed(global.key_right) || keyboard_check_pressed(vk_right);
var _ok    = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space) || keyboard_check_pressed(ord("Z"));
var _back  = keyboard_check_pressed(vk_escape) || keyboard_check_pressed(ord("X"));

switch (menu_state) {

    // ── Slots e botões ────────────────────────────────────────────
    case SAVE_UI.SLOTS:
        if (_up)   { sel = (sel + 3) mod 4; audio_play_sound(sfxSwitch, 0, false); }
        if (_down) { sel = (sel + 1) mod 4; audio_play_sound(sfxSwitch, 0, false); }

        if (sel == 3) {
            if (_left)  { btn_sel = (btn_sel + 2) mod 3; audio_play_sound(sfxSwitch, 0, false); }
            if (_right) { btn_sel = (btn_sel + 1) mod 3; audio_play_sound(sfxSwitch, 0, false); }
        }

        if (_ok) {
            audio_play_sound(sfxSelect, 0, false);
            if (sel < 3) {
                act_sel    = 0;
                menu_state = SAVE_UI.ACTION;
            } else {
                switch (btn_sel) {
                    case 0: // Copiar
                        if (count_existing() == 0) { say("Não há arquivos para copiar.", false); }
                        else { move_to_existing(1); menu_state = SAVE_UI.COPY_SRC; }
                        break;
                    case 1: // Apagar
                        if (count_existing() == 0) { say("Não há arquivos para apagar.", false); }
                        else { move_to_existing(1); menu_state = SAVE_UI.ERASE_SEL; }
                        break;
                    case 2: // Voltar
                        close_menu();
                        break;
                }
            }
        }
        if (_back) close_menu();
        break;

    // ── Opções dentro do slot ─────────────────────────────────────
    case SAVE_UI.ACTION:
        if (_left || _right) { act_sel = 1 - act_sel; audio_play_sound(sfxSwitch, 0, false); }
        if (_ok) {
            audio_play_sound(sfxSelect, 0, false);
            if (act_sel == 1) menu_state = SAVE_UI.SLOTS;
            else do_slot_action(sel);
        }
        if (_back) menu_state = SAVE_UI.SLOTS;
        break;

    // ── Copiar: escolher a ORIGEM (só slots com arquivo) ──────────
    case SAVE_UI.COPY_SRC:
        if (_up)   { move_to_existing(-1); audio_play_sound(sfxSwitch, 0, false); }
        if (_down) { move_to_existing(1);  audio_play_sound(sfxSwitch, 0, false); }
        if (_ok) {
            audio_play_sound(sfxSelect, 0, false);
            copy_src = sel;
            move_skipping(1, copy_src);
            menu_state = SAVE_UI.COPY_DST;
        }
        if (_back) { sel = 3; menu_state = SAVE_UI.SLOTS; }
        break;

    // ── Copiar: escolher o DESTINO (vazio copia direto; ocupado pede confirmação) ──
    case SAVE_UI.COPY_DST:
        if (_up)   { move_skipping(-1, copy_src); audio_play_sound(sfxSwitch, 0, false); }
        if (_down) { move_skipping(1, copy_src);  audio_play_sound(sfxSwitch, 0, false); }
        if (_ok) {
            audio_play_sound(sfxSelect, 0, false);
            if (slot_info[sel].exists) {
                ask("Sobrescrever o arquivo " + string(sel + 1) + " com o " + string(copy_src + 1) + "?",
                    "copy", sel, SAVE_UI.COPY_DST);
            } else {
                do_copy(sel);
            }
        }
        if (_back) { sel = copy_src; menu_state = SAVE_UI.COPY_SRC; }
        break;

    // ── Apagar: escolher o arquivo ────────────────────────────────
    case SAVE_UI.ERASE_SEL:
        if (_up)   { move_to_existing(-1); audio_play_sound(sfxSwitch, 0, false); }
        if (_down) { move_to_existing(1);  audio_play_sound(sfxSwitch, 0, false); }
        if (_ok) {
            audio_play_sound(sfxSelect, 0, false);
            ask("Apagar o arquivo " + string(sel + 1) + "?", "erase", sel, SAVE_UI.ERASE_SEL);
        }
        if (_back) { sel = 3; menu_state = SAVE_UI.SLOTS; }
        break;

    // ── Pergunta Sim / Não ────────────────────────────────────────
    case SAVE_UI.CONFIRM:
        if (_left || _right) { confirm_sel = 1 - confirm_sel; audio_play_sound(sfxSwitch, 0, false); }
        if (_ok) {
            audio_play_sound(sfxSelect, 0, false);
            if (confirm_sel == 0) {
                switch (confirm_action) {
                    case "save":  do_save(confirm_slot);  break;
                    case "copy":  do_copy(confirm_slot);  break;
                    case "erase": do_erase(confirm_slot); break;
                }
            } else {
                menu_state = confirm_return;
            }
        }
        if (_back) menu_state = confirm_return;
        break;

    // ── Aviso curto ───────────────────────────────────────────────
    case SAVE_UI.MESSAGE:
        msg_timer--;
        if (_ok || _back || msg_timer <= 0) {
            if (msg_close) {
                close_menu();
            } else {
                sel        = 3;
                menu_state = SAVE_UI.SLOTS;
            }
        }
        break;
}
