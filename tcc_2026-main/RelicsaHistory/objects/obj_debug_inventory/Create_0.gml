// OBJETO DE TESTE — remover antes do build final
 
// Simula dano para testar a cura
global.hp = 7;
 
// Erva Medicinal — protegido contra empilhamento ao reentrar na sala
var _ja_tem_erva = false;
for (var i = 0; i < array_length(global.inventory_consumables); i++) {
    if (global.inventory_consumables[i].id == "erva_medicinal") {
        _ja_tem_erva = true;
        break;
    }
}
if (!_ja_tem_erva) {
    scr_inventory_add(
        "consumable", "erva_medicinal", "Erva Medicinal",
        "Restaura 3 pontos de vida. Nao ultrapassa o maximo.",
        noone, 3, "effect_erva_cura"
    );
}
 
// Relíquia de teste
scr_inventory_add(
    "relic", "reliquia_teste", "Reliquia de Teste",
    "Item de teste. Descarte com Delete.",
    noone, 1
);
