function scr_dialogo_sans1(_text_id){
	//inicializa as varáveis globais do personagem caso não existam ainda
	//(o primeiro teste era duplicado e deixava global.sans sem inicializar)
	if(!variable_global_exists("sans")){
		global.sans = false;
	}
	if(!variable_global_exists("sans1")){
		global.sans1 = false;
	}
	
	switch(_text_id){
		// O speakblock do banheiro 1 usa text_id "sans1"; sem este case o
		// despachante chamava o script certo mas não encontrava nenhuma fala.
		case "sans1":
		case "sans": //fala do clone quando o jogador interage com ele
			//se o jogador já falou o clone antes, mostra a fala diferente
			if(global.sans1 == true){
				scr_text("Bem, tenho que terminar aqui.", "sans");
				break;
			}
			//primeira vez falando com ele
			scr_text("Opa, tudo bem?", "sans - eye");
			// Prefixo "sans1" faz scr_game_text chamar este mesmo script;
			// com "sans_..." as opções caíam no diálogo do outro Sans.
			scr_option("Tudo. E contigo?", "sans1_tudo");
			scr_option("Por que o banheiro tá todo cagado?", "sans1_cagado");
			//opções de resposta do	jogador
			
			
			//marca que o jogador já falou com o clone
			global.sans1 = true;
			break;
			
		case "sans1_tudo"://jogador concorda com o clone
			scr_text("Que bom, Tô bem também.", "sans");
			scr_text("Não liga muito pro banheiro não, eu vou limpar tudo.", "sans - eye");
			break;
			
		case "sans1_cagado":
			scr_text("Ah, um aluno decidiu que seria uma boa ideia cagar no mictório.", "sans");
			scr_text("Mas, acabou que ele foi flagrado por um dos alunos e tentou correr...", "sans");
			scr_text("E derrubou um dos dejetos no chão.", "sans - eye");
			global.sans = true;
			break;
		
	}
}