audio_play_sound(sfxSwitch, 0, false);

// Se veio do pause menu, não precisa fazer nada especial
// O obj_pause_menu ainda existe e continua no controle

// Se veio da title screen, garante que o player não ficou bloqueado
if (called_from == "title") {
    // Nada extra necessário — o obj_title continua ativo normalmente
}