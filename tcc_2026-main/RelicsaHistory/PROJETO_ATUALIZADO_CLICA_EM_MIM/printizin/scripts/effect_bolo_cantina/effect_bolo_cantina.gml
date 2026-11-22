/// Efeito do Bolo da Cantina: restaura 10 HP, sem ultrapassar max_hp
function effect_bolo_cantina() {
    global.hp = min(global.hp + 10, global.max_hp);
}