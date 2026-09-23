/// Efeito do Bolo da Cantina: restaura 5 HP, sem ultrapassar max_hp
function effect_bolo_cantina() {
    global.hp = min(global.hp + 5, global.max_hp);
}