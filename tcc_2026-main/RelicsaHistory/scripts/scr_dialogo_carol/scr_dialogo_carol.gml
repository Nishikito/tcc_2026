function scr_dialogo_carol(){
	if(!variable_global_exists("carol")){
		global.carol = false;
	}
	
	if(!variable_global_exists("carol")){
		global.carol1 = false;
	}
	
	switch(_text_id){
		case "carol":
			if(global.carol1 == true){
				scr_text("aaaaaaaaaaaaaaaa");
			}
		scr_text("Tava dormindo?");
		scr_text("Vai tomar uma ocorrênciazinha pra parar de ser trouxa");
		
	}
}