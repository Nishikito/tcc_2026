//navegação entre abas

//por q/e
if (keyboard_check_pressed(ord("Q"))) {
	current_tab = max(0, current_tab - 1);
}
if (keyboard_check_pressed(ord("E"))) {
	current_tab = min(array_length(tabs) - 1, current_tab + 1);
}

//navegacção por itens
//por w/s
var _arr = scr_inventory_get_array_by_tab(current_tab);
var _len = (_arr != undefined) ? array_length(_arr) : 0;
if (_len > 0) {
	if (keyboard_check_pressed(global.key_up)) {
		tab_sel[current_tab] = max(0, tab_sel[current_tab] - 1);
	}
	if (keyboard_check_pressed(global.key_down)) {
		tab_sel[current_tab] = min(_len - 1, tab_sel[current_tab] + 1);
	}
}

//tecla para fechar inventario com esc ou a tecla de abrir o inventário
if (keyboard_check_pressed(vk_escape) || keyboard_check_pressed(global.key_inventory)) {
	instance_activate_all();
	global.paused = false;
	instance_destroy();
}