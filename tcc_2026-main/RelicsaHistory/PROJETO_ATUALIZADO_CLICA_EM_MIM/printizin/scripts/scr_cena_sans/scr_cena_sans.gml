function scr_cena_sans(_id) {
    switch (_id) {

        case "sans_seguir":
            var _sans = instance_nearest(ObjPlayer.x, ObjPlayer.y, ObjJanitor);
            if (_sans == noone) return [];
            return [
                [cutscene_player_lock],
                [cutscene_move_to_player_back, _sans, 24, 1.5, "X_FIRST"],
                [cutscene_start_following, _sans],
                [cutscene_player_unlock]
            ];
    }
    return [];
}