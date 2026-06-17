function scr_inventory_get_array_by_tab(_tab) {
	switch (_tab) {
		case 0: return undefined; // Status não tem lista
		case 1: return global.inventory_relics;
		case 2: return global.inventory_mission;
		case 3: return global.inventory_docs;
		case 4: return global.inventory_consumables;
	}
}
