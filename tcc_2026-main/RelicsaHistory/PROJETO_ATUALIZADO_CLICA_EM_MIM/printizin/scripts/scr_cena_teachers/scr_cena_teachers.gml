/// Cenas da sala dos professores (RoomTeachers_1).
/// O prefixo do ID ("teachers") escolhe este script: "teachers_livro" -> scr_cena_teachers
function scr_cena_teachers(_id) {
    switch (_id) {

        // O player chega perto da mesa, vê o livro, a tela treme, tudo escurece e ele cai.
        case "teachers_livro":
            if (!instance_exists(ObjPlayer)) return [];

            // ── AJUSTES (pixels da room) ──────────────────────────────────────
            var _livro_x  = 227;   // x do livro em cima da mesa (centro)
            var _longe_y  = 126;   // 1ª parada: perto da mesa, ainda com folga
            var _perto_y  = 114;   // 2ª parada: encostado na frente da mesa
            // Pra onde ele cai quando termina (a mesma queda do "professor_livro_queda").
            // Troque aqui se a sequência for outra.
            var _destino   = Room23;
            var _destino_x = 982;
            var _destino_y = 316;

            // se o gatilho pegar o player já acima da 1ª parada, ele não desce
            var _y1 = min(ObjPlayer.y, _longe_y);

            return [
                [cutscene_player_lock],
                [cutscene_wait, 10],

                // 1) se aproxima da mesa e vê o livro
                [cutscene_walk_player, _livro_x, _y1, 1, "X_FIRST"],
                [cutscene_face_dir, ObjPlayer, UP],
                [cutscene_wait, 20],
                [cutscene_dialogue, "teachers_livro1"],          // "Um livro?"
                [cutscene_wait, 15],

                // 2) chega mais perto do livro, a tela começa a tremer
                [cutscene_walk_player, _livro_x, _perto_y, 0.5, "Y_FIRST"],
                [cutscene_wait, 25],
                [cutscene_shake_start, 1],
                [cutscene_wait, 45],
                [cutscene_shake_start, 2],
                [cutscene_dialogue, "teachers_livro2"],          // "O que tá acontecendo!?"

                // 3) escurece (sobra só uma luz em volta dele), a tremida aumenta e então para
                [cutscene_shake_start, 3],
                [cutscene_dark_in, 100, 190, 36, 0.97],
                [cutscene_shake_stop],
                [cutscene_wait, 90],                              // parado no escuro

                // 4) cai
                [cutscene_player_fall_out, 0.3],
                [cutscene_wait, 40],
                [cutscene_dark_to_black, 30],
                [cutscene_wait, 30],
                [cutscene_goto_room, rm_inicio, 193, 408, ""],
            ];
    }
    return [];
}
