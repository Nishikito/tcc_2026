// TESTE REMOVIDO — use um obj_speakblock real para testar coleta de itens

/// scr_inventory_add(categoria, id, nome, descricao, sprite, quantidade)
/// categoria: "relic" | "mission" | "doc" | "consumable"
/*function scr_inventory_add(_cat, _id, _name, _desc, _spr, _qty) {
	var _item = {
		id: _id,
		name: _name,
		description: _desc,
		sprite: _spr,
		qty: _qty
};
 // Consumíveis: empilha se já existir no inventário
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
 // Demais categorias: ignora se o jogador já tem o item
 var _array = scr_inventory_get_array(_cat);
	for (var i = 0; i < array_length(_array); i++) {
		if (_array[i].id == _id)
			return;
		}
	array_push(_array, _item);
 // Mantém o contador de relíquias atualizado
 if (_cat == "relic") {
		global.relics_count = array_length(global.inventory_relics);
	}
}
/// Helper interno — retorna o array correto pela categoria
function scr_inventory_get_array(_cat) {
	switch (_cat) {
		case "relic": return global.inventory_relics;
		case "mission": return global.inventory_mission;
		case "doc": return global.inventory_docs;
		case "consumable": return global.inventory_consumables;
		}
}
