function scr_dialogo_carol_fim(){
	switch (_text_id) {

        case "carol_fim":
            scr_text("Se lasca ou.", "carol");
            scr_text("Vou toma um cafezin com o Arnaldin.", "carol");
            // Flag que dispara a cutscene de saída (carol_step_cutscene no ObjCarol)
            global.carol_dialog_finished = true;
            // Flag que faz o speakblock da RoomClass1 se destruir
            global.carol_dialogo_fim = true;
            break;
	}
}