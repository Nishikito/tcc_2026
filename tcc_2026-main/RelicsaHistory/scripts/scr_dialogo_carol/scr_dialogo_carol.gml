function scr_dialogo_carol(_text_id){
	switch(_text_id){
		case "carol":
		if (global.carol1 == true) {
			scr_text("aaaaaaaaaaaaaaaa", "carol");
		}
		scr_text("Tava dormindo?", "carol");
		scr_text("Vai tomar uma ocorrênciazinha pra parar de ser trouxa", "carol");
		global.carol1 = true;
		break;
	}
}