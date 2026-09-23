function scr_dialogo_item(_text_id) {
    switch (_text_id) {

        // ── CONSUMÍVEL 1 — cura pequena ───────────────────────────
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

        // ── CONSUMÍVEL 2 — cura maior ─────────────────────────────
        // Existe pra testar a navegação da lista de itens na batalha:
        // com um item só não dá pra saber se as setas funcionam.
        case "item_teste_bolo":
            scr_text("Um Bolo da Cantina, ainda quentinho!", "");
            scr_text("Guardado no inventario.", "");
            scr_inventory_add(
                "consumable",
                "bolo_cantina",
                "Bolo da Cantina",
                "Restaura 5 pontos de vida. Meio duro, mas resolve.",
                noone,
                1,
                "effect_bolo_cantina"
            );
            break;

        // ── RELÍQUIA ──────────────────────────────────────────────
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