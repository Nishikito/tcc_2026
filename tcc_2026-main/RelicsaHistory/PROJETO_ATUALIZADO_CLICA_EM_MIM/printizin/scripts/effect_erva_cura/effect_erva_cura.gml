/// Efeito da Erva Medicinal: restaura 6 HP, sem ultrapassar max_hp
function effect_erva_cura() {
    global.hp = min(global.hp + 6, global.max_hp);
   // Futuramente: mostrar texto flutuante com "+" + string(_cura)
    // Futuramente: audio_play_sound(sfxCura, 0, false);
}