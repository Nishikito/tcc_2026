/// @param text_id
function scr_game_text(_text_id){
switch(_text_id){
	
	case "npc1"://-----------FALA DO SANS-------------//
		if global.sans1 = true{
			scr_text("Enfim, boa sorte", "sans")
			break
		}
		scr_text("Opa, bom? Sou Sans, Sans o faxineiro, um prazer te conhecer", "sans - eye");
		scr_text("voce e novo por aqui ne?, ja conheceu a carol?", "sans");
			scr_option("Sim","npc1 - sim");
			scr_option("Nao","npc1 - nao");
			global.sans1 = true;
		break
		
		case "npc1 - sim":
				scr_text("Tomara que ela nao bata em voce, ela faz isso com alunos novos", "sans")
			break
			
		case "npc1 - nao":
				scr_text("Entao toma cuidado para nao encontrar ela por ai", "sans - eye")
				global.sans = true;
			break
		
		
		
	case "npcFilipe"://-----------FALA DO FILIPE-------------//
		scr_text("Opa, eai?")
		scr_text("Eu vi a Carol passando correndo para o corredor de baixo")
		scr_text("Acho que ela foi para a esquerda")
		
		break	
		
		
		
	case "npcDaniel": //-----------FALA DO DANIEL-------------//

		scr_text("Eu quero voltar logo pra casa", "daniel")
		scr_text("Mal dormi, fiquei jogando forsaken", "daniel-feliz")
		scr_text("Eu amo forsaken", "daniel")		
		break
	
	case "danielEncounter":
		scr_text("Kroks! voce ta aqui!")
		scr_text("Eu estava te procurando")
		scr_text("Aconteceu um negocio bizarro comigo")
		scr_text("Eu estava passando no bebedouro e o galao de agua caiu em mim")
		scr_text("Ai eu desmaiei")
		scr_text("E depois eu acordei aqui nesse lugar estranho")
		scr_text("Ate que eu estava andando e te achei agora")
		scr_text("Enfim, como voce veio parar aqui?")
			scr_option("E eu sei la", "nao sei")
			scr_option("A professora me bateu", "professora")
		break;
		
		case "nao sei":
			scr_text("A, compreendo")
			scr_text("Acho que agora a gente tem que sair daqui ne?")
			scr_text("Eu vou indo na frente, te encontro por ai")
			scr_text("TCHAUUU :)")
			break
			
		case "professora":
			scr_text("SERIO????")
			scr_text("Eu vou mostrar pra ela o que ela merece")
			scr_text("A gente tem que sair logo daqui")
			scr_text("Eu vou indo na frente")
			scr_text("Te encontro por ai")
			scr_text("TCHAU AMIGO :P")
			break
			

		
	case "npcBlub": //-----------FALA DO BEBEDOURO-------------//
		scr_text("Blub Blub Blub")
		scr_text("Uma forte aura emanece do bebedouro")
		scr_text("Blub Blub Blub")
		break




	case "mictorio"://-----------FALA DO MICTORIO-------------//
		scr_text("Voce encara com nojo...")
		break




	case"papel": //-----------FALA DO PAPEL-------------//
		if global.papel = true{
			scr_text("Venha para a nossa festa de dia das bruxas")	
			scr_text("Nao se esqueca da sua fantasia")
			break
		}else if global.papel1 = true{
			scr_text("Oficina de matematica na proxima semana")
			break
		}
		if global.gustavo_fala = true{
			scr_text("Voce observa alguns papeis interessantes")
			scr_text("Ler?")
				scr_option("Ler papel um", "papel 1")
				scr_option("Ler papel dois", "papel 2")
		break
		}
		scr_text("Voce observa alguns papeis interessantes")
		break
		
		
		case"papel 1":
			scr_text("Voce pega o papel meio amassado e le")
			scr_text("Venha para a nossa festa de dia das bruxas")	
			scr_text("Nao se esqueca da sua fantasia")
			global.papel = true
			break
		
		case"papel 2":
			scr_text("Voce pega o papel e le")
			scr_text("Oficina de matematica na proxima semana")
			global.papel1 = true	
		break
		
		
		
		
	case"gustavo": //-----------FALA DO GUSTAVO-------------//
		if global.papel1 = true{
			scr_text("Que legal")
			scr_text("Poderimos ir se quiser, gosto de matematica")
			break
		}else if global.papel = true{
			scr_text("QUE LEGAL")
			scr_text("Podemos ir se quiser")
			scr_text("Nem me apresentei, mas o meu nome e Gustavo")
			break
		}
	
		scr_text("Ola!")
		scr_text("Poderia ler um papel que esta no corredor para mim?")
		global.gustavo_fala = true;
		break
		
	case "carol":
	    scr_text("Entao...");
	    scr_text("Voce que e o aluno novo, ne?");
		scr_text("Tenho apenas uma pergunta para voce.");
		scr_text("Gosta de matematica?");
			scr_option("Talvez...","depende")
			scr_option("Depende...","depende")
			scr_option("Mais ou menos...","depende")
		break
		
	case "depende":
	    scr_text("Interessante...");
	    scr_text("Me encontre na sala dos professores mais tarde.");
	    scr_text("Tenho um teste para voce.");			
	    scr_text("Um teste que apenas poucos passam.");	
	    scr_text("Aproveite o intervalo por enquanto...");	
	    global.carol_dialog_finished = true;
		global.carol_dialogue_end = true;
	    break;

	case "Cantina":
		scr_text("O que tu quer?")
			scr_option("Coxinha - R$9999","123")
			scr_option("Pao de queijo - R$ 10","123")
			scr_option("Alguma coisa - R$24,69","123")
		break
		case"123":
			scr_text("Infelizmente os devs nao fizeram um sistema de inventario ainda")
			scr_text("Esses desempregados")						
			scr_text("Volte mais tarde quando tiver...")
		break
	case"coxinha":
		scr_text("Eu....")
		scr_text("Porque eu comprei isso?????????")
		scr_text("Como que uma, UMA unidade de coxinha custa é 99999 reais")
		scr_text("Vou ter que vender um orgao meu")
		break
		
	case"armario":
		scr_text("A. R. M. A. R. I. O.", "armario")
		break


	case "BattleCarol":
	    scr_text("Finalmente chegou");
	    scr_text("Esta pronto?");
	    scr_option("Sim", "CarolBattleConfirm")
	    scr_option("Nao", "CarolBattleDecline")
	    break;

	case "CarolBattleConfirm":
	    scr_text("Entao SE PREPARE")
	    // Define que após este diálogo terminar, deve ir para a batalha
	    global.after_dialog_action = "battle_carol";
	    break;
    
	case "CarolBattleDecline":
	    scr_text("Hmmmm")
	    scr_text("Entao volte daqui a pouco....")
	    break;
	}
}