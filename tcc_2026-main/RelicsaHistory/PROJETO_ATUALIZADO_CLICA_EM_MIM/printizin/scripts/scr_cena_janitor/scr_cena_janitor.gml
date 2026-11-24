function scr_cena_janitor(_id) {
    switch (_id) {

        case "janitor_recruit":
            if (party_has(ObjJanitor)) return [];
            return [
                [cutscene_player_lock],
                [cutscene_face_player, ObjJanitor],
                [cutscene_dialogue, "janitor_recrutar"],
                [cutscene_move_to_player_back, ObjJanitor, 24, 1, "X_FIRST"],
                [cutscene_dialogue, "janitor_simbora"],
                [cutscene_start_following, ObjJanitor],
                [cutscene_player_unlock]
            ];

        // era "exemplo_item" (o diálogo "item_teste_maca" já dá a maçã)
        case "janitor_item":
            return [
                [cutscene_player_lock],
                [cutscene_stop_following, ObjJanitor],
                [cutscene_move_to_player_front, ObjJanitor, 24, 1, "Y_FIRST"],
                [cutscene_dialogue, "janitor_item"],
                [cutscene_dialogue, "item_teste_maca"],
                [cutscene_start_following, ObjJanitor],
                [cutscene_player_unlock]
            ];
    }
    return [];
}