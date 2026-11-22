function scr_dialogo_sans(_text_id){
	//inicializa as varáveis globais do personagem caso não existam ainda
	if(!variable_global_exists("sans")){
		global.sans = false;
	}
	if(!variable_global_exists("sans1")){
		global.sans1 = false;
	}
	
	switch(_text_id){
		case"sans": //fala do clone quando o jogador interage com ele
			//se o jogador já falou o clone antes, mostra a fala diferente
			if(global.sans1 == true){
				scr_text("Tu quer o quer?", "sans");
				break;
			}
			//primeira vez falando com ele
			scr_text("Ah, e aí? Tá testando o sistema?", "sans - eye");
			scr_text("Concorda que o programador é um vagabundo? ", "sans - eye");
			//opções de resposta do	jogador
			scr_option("Sim", "sans_sim");
			scr_option("Não", "sans_não");
			
			//marca que o jogador já falou com o clone
			global.sans1 = true;
			break;
			
		case "sans_sim"://jogador concorda com o clone
			scr_text("Engraçado você dizer isso, já que você provavelmemte é o programador desse TCC que tá fazendo isso!", "sans");
			scr_text("Larga a mão de ser vagabundo ", "sans - eye");
			scr_text("Se não for, primeiro que cê foi longe pra descobrir isso.", "sans");
			scr_text("E segundo, me perdoekkkkkkkkk", "sans");
			break;
			
		case "sans_não":
			scr_text("Claro né, tu que é o programador dessa bagaça! ", "sans");
			scr_text("E se não for você, tu tá defendendo ele é? Tá bom :D", "sans");
			global.sans = true;
			break;
		
	}
}