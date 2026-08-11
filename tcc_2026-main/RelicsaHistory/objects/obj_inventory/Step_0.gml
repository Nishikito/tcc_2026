// ── TROCAR ABA com Q / E ──────────────────────────────────────────
if (keyboard_check_pressed(ord("Q"))) {
    current_tab = max(0, current_tab - 1);
}
if (keyboard_check_pressed(ord("E"))) {
    current_tab = min(array_length(tabs) - 1, current_tab + 1);
}

// ── NAVEGAR ITENS com teclas remapeadas ───────────────────────────
var _arr = scr_inventory_get_array_by_tab(current_tab);
var _len = (_arr != undefined) ? array_length(_arr) : 0;

if (_len > 0) {
    if (keyboard_check_pressed(global.key_up)) {
        tab_sel[current_tab] = max(0, tab_sel[current_tab] - 1);
    }
    if (keyboard_check_pressed(global.key_down)) {
        tab_sel[current_tab] = min(_len - 1, tab_sel[current_tab] + 1);
    }

    // ── USAR ITEM com Enter (só na aba Consumíveis) ───────────────
    if (current_tab == 4 && keyboard_check_pressed(vk_enter)) {
        var _sel = tab_sel[4];
        scr_inventory_use(global.inventory_consumables, _sel);

        // Corrige o cursor se o item foi removido e era o último
        var _new_len = array_length(global.inventory_consumables);
        if (_new_len == 0) {
            tab_sel[4] = 0;
        } else {
            tab_sel[4] = min(tab_sel[4], _new_len - 1);
        }
    }

    // ── DESCARTAR ITEM com Delete ou Backspace ────────────────────
    if (current_tab != 0 && keyboard_check_pressed(vk_delete)
    ||  current_tab != 0 && keyboard_check_pressed(vk_backspace)) {
        var _sel = tab_sel[current_tab];
        scr_inventory_remove(_arr, _sel);

        // Corrige o cursor após remoção
        var _new_len = array_length(_arr);
        if (_new_len == 0) {
            tab_sel[current_tab] = 0;
        } else {
            tab_sel[current_tab] = min(tab_sel[current_tab], _new_len - 1);
        }

        // Atualiza contador de relíquias se necessário
        if (current_tab == 1) {
            global.relics_count = array_length(global.inventory_relics);
        }
    }
}

// ── FECHAR com ESC ou tecla do inventário ────────────────────────
if (keyboard_check_pressed(vk_escape) || keyboard_check_pressed(global.key_inventory)) {
    instance_activate_all();
    global.paused = false;
    instance_destroy();
}