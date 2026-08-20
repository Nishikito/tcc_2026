function scr_dialogo_item(_text_id) {
    switch (_text_id) {
 
        case "item_teste_erva":
            scr_text("Voce encontrou uma Erva Medicinal!", "");
            scr_text("Ela foi adicionada ao seu inventario.", "");
            scr_inventory_add(
                "consumable",
                "erva_medicinal",
                "Erva Medicinal",
                "Restaura 3 pontos de vida. Nao ultrapassa o maximo.",
                noone,
                1,
                "effect_erva_cura"
            );
            break;
 
        case "item_teste_reliquia":
            scr_text("Uma antiga moeda foi encontrada!", "");
            scr_text("Ela foi registrada no seu inventario.", "");
            scr_inventory_add(
                "relic",
                "reliquia_moeda",
                "Moeda Romana",
                "Uma moeda do seculo II encontrada nas ruinas.",
                noone,
                1
            );
            break;
    }
}
