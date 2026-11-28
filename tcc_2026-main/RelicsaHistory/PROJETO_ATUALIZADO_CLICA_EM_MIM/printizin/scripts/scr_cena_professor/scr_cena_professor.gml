function scr_cena_professor(_id) {
    switch (_id) {

        case "professor_livro":
            return [
                [cutscene_player_lock],
                [cutscene_wait, 30],
                [cutscene_dialogue, "professor_vemaqui"],
                [cutscene_move_axis, ObjPlayer, 231, 119, 0.5, "X_FIRST"],
                [cutscene_dialogue, "professor_fala"],
                [cutscene_screen_shake, 45, 3],
                [cutscene_fade_to_room, RoomLivro, 231, 119, "professor_livro_queda"], // <- ID novo
            ];

        // era "livro_queda"
        case "professor_livro_queda":
            var _cena = [
                [cutscene_camera_freeze],
                [cutscene_player_lock],
                [cutscene_wait, 40]
            ];

            // 4 olhadas lentas
            var _lentas = [26, 26, 22, 22];
            for (var i = 0; i < 4; i++) cena_olhar(_cena, (i mod 2 == 0) ? LEFT : RIGHT, _lentas[i]);

            // 8 olhadas rapidíssimas
            for (var i = 0; i < 8; i++) cena_olhar(_cena, (i mod 2 == 0) ? LEFT : RIGHT, 3);

            // encara a tela e cai
            array_push(_cena, [cutscene_wait, 15]);
            cena_olhar(_cena, DOWN, 25);
			array_push(_cena, [cutscene_player_fall_out, 0.2]);
			array_push(_cena, [cutscene_wait, 60]);   // (o vídeo da animação entra aqui depois)
			array_push(_cena, [cutscene_fade_to_room_slow, rm_inicio, 982, 316, "mundo_acordar"]);
			return _cena;
    }
    return [];
}

/// helper: adiciona "olhar pra _dir + esperar _frames" na cena
function cena_olhar(_cena, _dir, _frames) {
    array_push(_cena, [cutscene_face_dir, ObjPlayer, _dir], [cutscene_wait, _frames]);
}