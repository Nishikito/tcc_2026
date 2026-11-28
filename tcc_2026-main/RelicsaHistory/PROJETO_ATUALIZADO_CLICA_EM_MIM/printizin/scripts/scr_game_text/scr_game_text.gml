///@param text_id
function scr_game_text(_text_id){
	// ── Diálogos da história ───────────────────────────────────────────
	// Ficam aqui, dentro de um script já registrado, porque o IDE reescreve o
	// .yyp ao salvar e descarta scripts novos que ainda não foram abertos nele.
	// scr_text() resolve "talai-<emoção>" para os sprites *_visual_novel.
	switch (_text_id) {
		case "historia_acordar":
			scr_text("Nossa... Eu dormi pra caramba... Já até deu o horário do almoço...", "talai-preocupado");
			return;

		case "historia_corredor":
			scr_text("Onde será que o René deve estar? Vou ver com alguém da nossa sala.", "talai-pensando");
			return;

		// Encontro com o guaraná em rm_inicio (retrato talaiB explícito).
		case "mundo_guarana_surpreso":
			scr_text("Oxi, o que um guaraná ta fazendo aqui???", "talaib-surpreso");
			return;

		// Primeira vez que o Talai avista o save point: ele pergunta e o Rodapé explica.
		// "talai-"/"rasiel-" (sem o B) escolhem o retrato conforme a sala automaticamente.
		case "mundo_savepoint_visto":
			scr_text("Ei... o que é aquela coisa amarela flutuando ali?", "talaib-surpreso");
			scr_text("Isso é um savepoint, Talai.", "rasiel-explicando");
			scr_text("Serve pra você guardar seu progresso.", "rasiel-falando");
			scr_text("E caso você seja derrotado, você volta a partir daqui.", "rasiel-sorrindo");
			scr_text("COMO ASSIM SER DERROTADO???", "talaib-preocupado");
			scr_text("Enfim", "rasiel-desacreditado");
			scr_text("É só chegar perto de um que você vai ver o que acontece.", "rasiel-sorrindo");
			return;

		case "historia_bobalhao":
			scr_text("E aí mano, tudo bem?", "talai-falando");
			scr_text("opa, tô bem.");                                  // Bobalhao: sem retrato
			scr_text("Cê ciu pra onde o René foi por acaso?", "talai-falando");
			scr_text("acho que ele foi pra sala do professor de matemática"); // sem retrato
			scr_text("Ah, valeu", "talai-sorrindo");
			return;

		// Companion Rasiel: fala ao apertar ENTER perto dele (retrato dele à direita).
		case "rasiel_conversa":
			scr_text("Vamos em frente, Talai. Eu estou com você.", "rasiel-falando");
			return;

		// Primeira conversa ao chegar em rm_inicio: termina com Rodapé entrando na party.
		case "rodape_intro":
			scr_text("Olá, tudo bem?", "rasiel-sorrindo");
			scr_text("Você teve uma baita queda, está machucado?", "rasiel-preocupado");
			scr_text("O-Onde eu tô?!?!", "talaib-preocupado");
			scr_text("Você tá no Brasil", "rasiel-explicando");
			scr_text("Como assim???", "talaib-preocupado");
			scr_text("Você está no Brasil, especificamente na época do descobrimento.", "rasiel-explicando");
			scr_text("O QUE??? COMO ISSO É POSSÍVEL?????", "talaib-surpreso");
			scr_text("(Vish, o muleke vai endoidar)", "rasiel-desacreditado");
			scr_text("Olha, eu não sei como te explicar isso, mas vou te ajudar a voltar pra casa. E aliás, meu nome é Rodapé!", "rasiel-sorrindo");
			scr_text("(Rodapé, sério mesmo?)", "talaib-pensando");
			scr_text("Tá... o meu nome é Talai", "talaib-falando");
			scr_text("Prazer em te conhecer! Irei te seguir pra te ajudar nessa aventura.", "rasiel-sorrindo");
			scr_text("Rodapé entrou para a party");   // sem retrato
			return;
		
		case "colonizador_primeiro_contato":
			scr_text("Mas que é isto? Quem sois vós? Não me pareceis com homem algum desta tripulação.");
			scr_text("A-ah, é....", "talaiB-preocupado");
			scr_text("Talai, tá tudo bem?", "rasiel-preocupado");
			scr_text("Eu não faço ideia do que falar pra ele!", "talaiB-preocupado");
			scr_text("Que dissestes? Não logrei ouvir-vos.");
			scr_text("A-ah, é....", "talaiB-preocupado");
			scr_text("Desculpa senhor... E-eu entrei no barco sem q-querer, eu queria te ajudar com as viagens de caravela!", "talaiB-preocupado");
			scr_text("Não compreendo palavra do que dizeis. Que mal vos aflige, homem? Sois acaso algum tolo?");
			scr_text("Ele não fala o mesmo português que você.", "rasiel-falando");
			scr_text("C-como que eu falo com ele??", "talaiB-preocupado");
			scr_text("Já sei!", "rasiel-falando");
			scr_text("Você recebeu a Relíquia da Linguísica");
			scr_text("Pronto!", "rasiel-sorrindo");
			scr_text("I-isso funciona??", "talaiB-preocupado");
			scr_text("Ah, agora sim te compreendo!");
			scr_text("Agora, responda minha pergunta.");
			scr_text("Quem é você?");
	}

	//Pega o prefixo do text_id(tudo antes do primeiro _)
	var _prefix = string_split(_text_id, "_")[0];
	
	//monta o nome do script automaticamente
	var _script_name = "scr_dialogo_" + _prefix;
	var _script = asset_get_index(_script_name);
	
	//se o script existir, chama ele
	if(script_exists(_script)){
		script_execute(_script, _text_id);
		return;
	}
	
	//se não achar o script, avisa no console
	show_debug_message("DIALOGO NÂO ENCONTRADO: " + _text_id + "|Script procurado: "+ _script_name);
}
