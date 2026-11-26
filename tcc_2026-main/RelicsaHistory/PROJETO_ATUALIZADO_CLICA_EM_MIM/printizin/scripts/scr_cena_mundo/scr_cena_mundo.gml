function scr_cena_mundo(_id) {
    // O objeto do celular (ObjCelular) ainda não existe no projeto: procura pelo nome, então
    // a cena não quebra enquanto ele não for criado (-1 = inexistente).
    var _cel     = asset_get_index("ObjCelular");
    var _has_cel = (_cel != -1) && instance_exists(_cel);
    switch (_id) {

        // chegada no outro mundo: caído, treme, levanta e pensa
        case "mundo_acordar":
            var _cx = _has_cel ? _cel.x + 80 : ObjPlayer.x - 150;
            var _cy = _has_cel ? _cel.y : ObjPlayer.y;
            return [
                [cutscene_player_lock],
                [cutscene_lie_down, ObjPlayer],
                [cutscene_wait_fade],                          // espera o fade terminar de clarear
                [cutscene_wait, 40],
                [cutscene_shake_inst, ObjPlayer, 30, 1],       // umas tremidas...
                [cutscene_wait, 30],
                [cutscene_shake_inst, ObjPlayer, 24, 1],
                [cutscene_wait, 40],
                [cutscene_shake_inst, ObjPlayer, 20, 1],       // ...e levanta com outra tremida
                [cutscene_stand_up, ObjPlayer],
                [cutscene_shake_inst, ObjPlayer, 16, 1],
                [cutscene_wait, 30],
                [cutscene_dialogue, "mundo_quelugar"],
                [cutscene_dialogue, "mundo_dor"],
                [cutscene_camera_pan, _cx, _cy, 90],           // a tela vai pra esquerda: mostra o celular
                [cutscene_wait, 90],
                [cutscene_camera_pan, ObjPlayer.x, ObjPlayer.y, 70],   // e volta pro player
                [cutscene_camera_follow_player],
                [cutscene_player_unlock]
            ];

        // o player pisa perto do celular: ele explode e o Charles aparece
        case "mundo_celular":
            if (!_has_cel) return [];

            // ── AJUSTE MANUAL (em pixels: + = direita/baixo, - = esquerda/cima) ──
            var _expl_dx = 0, _expl_dy = 0;     // onde a explosão aparece, em relação ao centro do celular
            var _char_dx = 0, _char_dy = 0;     // onde o Charles aparece, em relação ao chão do celular

            // centro e "chão" do celular (funciona com qualquer origem do sprite)
            var _spr = _cel.sprite_index;
            var _cx  = _cel.x - sprite_get_xoffset(_spr) + sprite_get_width(_spr) / 2;
            var _cy  = _cel.y - sprite_get_yoffset(_spr) + sprite_get_height(_spr) / 2;
            var _fy  = _cel.y - sprite_get_yoffset(_spr) + sprite_get_height(_spr);

            // o pé do Charles fica no chão do celular (pé = altura do sprite - origem)
            var _chx = _cx + _char_dx;
            var _chy = _fy - (sprite_get_height(spr_cgpt_down) - sprite_get_yoffset(spr_cgpt_down)) + _char_dy;

            return [
                [cutscene_player_lock],
                [cutscene_wait, 20],
                [cutscene_explode, _cx + _expl_dx, _cy + _expl_dy],
                [cutscene_wait, 30],
                [cutscene_destroy_instance, _cel],       // o celular some dentro da explosão...
                [cutscene_create_instance, _chx, _chy, ObjJanitor],   // ...e o Charles nasce por baixo dela
                [cutscene_wait, 70],                           // deixa a explosão terminar
                [cutscene_face_player, ObjJanitor],
                [cutscene_dialogue, "mundo_cgpt"],             // falas + as duas opções
                [cutscene_start_following, ObjJanitor],        // entra na party
                [cutscene_player_unlock]
            ];

        // rm_inicio: o guaraná escondido entre as árvores rola até o Talai,
        // ele se surpreende, o guaraná se aproxima e a batalha começa.
        case "mundo_guarana_encontro":
            // Derrota já registrada no save: nunca repetir o encontro.
            if (save_enemy_defeated("Guarana")) return [];
            var _g = instance_find(obj_rh_en_guarana, 0);
            if (_g == noone || !instance_exists(ObjPlayer)) return [];

            // Para onde ele rola: ao lado do Talai, na MESMA altura dos pés dele.
            // Antes de aparecer, o guaraná é alinhado a essa altura; assim a rolagem
            // acontece em linha reta na horizontal (sem diagonal).
            var _stop_x = ObjPlayer.x - 88;
            var _stop_y = ObjPlayer.y;
            if (_stop_x < 40) _stop_x = ObjPlayer.x + 88;
            var _face = (ObjPlayer.x > _stop_x) ? LEFT : RIGHT;

            // Depois da fala ele chega mais perto, já na frente do Talai.
            var _near_x = ObjPlayer.x - 30;
            var _near_y = ObjPlayer.y;
            if (_near_x < 40) _near_x = ObjPlayer.x + 30;

            return [
                [cutscene_player_lock],
                [cutscene_face_dir, ObjPlayer, _face],
                [cutscene_place_at, _g, _g.x, _stop_y],        // mesma altura do Talai
                [cutscene_set_visible, _g, true],
                [cutscene_roll_to, _g, _stop_x, _stop_y, 3],   // aparece rolando em linha reta e para
                [cutscene_face_player, _g],                    // fica de frente para o Talai
                [cutscene_wait, 18],
                [cutscene_dialogue, "mundo_guarana_surpreso"],
                [cutscene_move_axis, _g, _near_x, _near_y, 2, "X_FIRST"], // se aproxima
                [cutscene_face_player, _g],
                [cutscene_wait, 12],
                [cutscene_battle_encounter, _g, "Guarana", "mundo_guarana_encontro"]
            ];
    }
    return [];
}