function scr_inventory_get_array(_cat) {
    switch (_cat) {
        case "relic":      return global.inventory_relics;
        case "mission":    return global.inventory_mission;
        case "doc":        return global.inventory_docs;
        case "consumable": return global.inventory_consumables;
    }
}
