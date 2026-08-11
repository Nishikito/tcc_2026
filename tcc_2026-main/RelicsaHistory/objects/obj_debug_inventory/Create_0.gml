// ── REDUZ HP PARA TESTAR CURA ─────────────────────────────────────
global.hp = 7; // simula dano sofrido (máximo é 10)

// ── ERVA MEDICINAL ────────────────────────────────────────────────
// Proteção contra empilhamento ao reentrar na sala
var _ja_tem_erva = false;
for (var i = 0; i < array_length(global.inventory_consumables); i++) {
    if (global.inventory_consumables[i].id == "erva_medicinal") {
        _ja_tem_erva = true;
        break;
    }
}

if (!_ja_tem_erva) {
    scr_inventory_add(
        "consumable",
        "erva_medicinal",
        "Erva Medicinal",
        "Restaura 3 pontos de vida. Nao ultrapassa o maximo.",
        noone,
        3,
        "effect_erva_cura"
    );
}

// ── RELÍQUIA DE TESTE ─────────────────────────────────────────────
scr_inventory_add(
    "relic",
    "reliquia_teste",
    "Reliquia de Teste",
    "Item de teste. Descarte com Delete.",
    noone,
    1
);