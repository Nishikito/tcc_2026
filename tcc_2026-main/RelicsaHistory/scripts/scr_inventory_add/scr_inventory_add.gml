/// scr_inventory_add(categoria, id, nome, descricao, sprite, quantidade, efeito)
/// categoria: "relic" | "mission" | "doc" | "consumable"
/// efeito: nome da função de efeito como string (ex: "effect_erva_cura") ou "" para nenhum
function scr_inventory_add(_cat, _id, _name, _desc, _spr, _qty, _effect = "") {
    var _item = {
        id:          _id,
        name:        _name,
        description: _desc,
        sprite:      _spr,
        qty:         _qty,
        effect:      _effect
    };
 
    if (_cat == "consumable") {
        for (var i = 0; i < array_length(global.inventory_consumables); i++) {
            if (global.inventory_consumables[i].id == _id) {
                global.inventory_consumables[i].qty += _qty;
                return;
            }
        }
        array_push(global.inventory_consumables, _item);
        return;
    }
 
    var _array = scr_inventory_get_array(_cat);
    for (var i = 0; i < array_length(_array); i++) {
        if (_array[i].id == _id) return; // já tem, ignora
    }
    array_push(_array, _item);
 
    if (_cat == "relic") {
        global.relics_count = array_length(global.inventory_relics);
    }
}