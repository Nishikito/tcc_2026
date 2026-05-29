function src_dialogo_sans(_text_id){
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
				src_text("Tu quer o que?", "sans");
				break;
			}
			//primeira vez falando com ele
			src_text("Ah, e aí? Tá testando o sistema?", "sans - eye");
			src_text("Concorda que o programador é um vagabundo? ", "sans - eye");
			//opções de resposta do	jogador
			src_option("Sim", "clone_sim");
			src_option("Não", "clone_não");
			
			//marca que o jogador já falou com o clone
			global.sans1 = true;
			break;
			
		case "sans_sim"://jogador concorda com o clone
			src_text("Engraçado você dizer isso, já que você provavelmemte é o programador desse TCC que tá fazendo isso, larga a mão de ser vagabundo e vai ler sua bíblia!", "sans");
			src_text("Se não for, primeiro que cê foi longe pra descobrir isso, e segundo, me perdoe(mas vai ler a bíblia, é bom!", "sans");
			break;
			
		case "sans_não":
			src_text("Claro né, tu que é o programador dessa bagaça! ", "sans");
			src_text("E se não for você, tu tá defendendo ele é? Tá bom :D", "sans");
			global.sans = true;
			break;
		
	}
}