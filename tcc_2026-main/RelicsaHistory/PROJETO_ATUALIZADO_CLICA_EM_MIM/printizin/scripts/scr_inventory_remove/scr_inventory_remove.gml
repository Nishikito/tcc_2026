/// scr_inventory_remove(array, index)
/// Descarta um item completamente do inventário.
function scr_inventory_remove(_array, _index) {
    if (_index < 0 || _index >= array_length(_array)) return;
    array_delete(_array, _index, 1);
}
