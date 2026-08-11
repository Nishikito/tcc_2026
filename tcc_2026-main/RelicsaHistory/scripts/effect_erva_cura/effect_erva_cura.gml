/// Efeito da Erva Medicinal: restaura 3 HP, sem ultrapassar max_hp
function effect_erva_cura() {
    global.hp = min(global.hp + 3, global.max_hp);
    // Futuramente: audio_play_sound(sfxCura, 0, false);
}