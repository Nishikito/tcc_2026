/// item_is_heal(effect)
/// true se o efeito é de CURA. Cura não deve ser gasta com HP cheio.
/// Ao criar um novo item de cura, adicione o nome do efeito AQUI (único lugar).
function item_is_heal(_effect) {
    return (_effect == "effect_erva_cura" || _effect == "effect_bolo_cantina");
}

/// scr_inventory_use(array, index)
/// Executa o efeito do item e decrementa a quantidade.
/// Se qty chegar a 0, remove do array.
/// Usa um item: executa o efeito e decrementa a quantidade.
function scr_inventory_use(_array, _index) {
    if (_index < 0 || _index >= array_length(_array)) return;
    var _item = _array[_index];
    if (_item.effect != "" && script_exists(asset_get_index(_item.effect))) {
        script_execute(asset_get_index(_item.effect));
    }
    _array[_index].qty -= 1;
    if (_array[_index].qty <= 0) {
        array_delete(_array, _index, 1);
    }
}


