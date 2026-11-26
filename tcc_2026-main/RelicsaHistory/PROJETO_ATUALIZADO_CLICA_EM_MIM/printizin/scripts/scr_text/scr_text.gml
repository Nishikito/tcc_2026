/// @param text
function scr_set_defaults_for_text(){
	line_break_pos[0, page_number]=999;
	line_break_num[page_number]=0;
	line_break_offset[page_number]=0;
	
	txtb_spr[page_number] = spr_textbox;
	speaker_sprite[page_number]= noone;
	speaker_large_sprite[page_number] = noone;   // sprite GRANDE de visual novel (Talai / Rasiel); noone = sem
	speaker_side[page_number] = 1;
	snd[page_number] = sfxNada;
	snd_delay_array[page_number]= 4;
}
///@param text
///@param [portrait]
function scr_text(_text){
	
	scr_set_defaults_for_text()
	
	text[page_number] =_text;
	text_length[page_number] = string_length(_text);
	
	//get character info
	if argument_count >1 {
		switch(argument[1]){
			
			case"daniel":
				speaker_sprite[page_number] = SprNpcDanielSpk;
				txtb_spr[page_number] = spr_textbox;
				snd[page_number]= sfxDanielVc;
				snd_delay_array[page_number] = 4;
				global.daniel_sprite_state = "normal";
				break;
				
			case"daniel-assustado":
				speaker_sprite[page_number] = SprNpxDanielScared;
				txtb_spr[page_number] = spr_textbox;
				snd[page_number]= sfxDanielVc;
				snd_delay_array[page_number] = 4;
				global.daniel_sprite_state = "assustado";
				break;
				
			case"daniel-feliz":
			    speaker_sprite[page_number] = SprNpcDanielSpkHappy;
			    txtb_spr[page_number] = spr_textbox;
			    snd[page_number]= sfxDanielVc;
			    snd_delay_array[page_number] = 4;
			    global.daniel_sprite_state = "feliz";
			    break;
				
			case"sans":			
				speaker_sprite[page_number] = SprNpcSansNormal;
				speaker_large_sprite[page_number] = noone;
				txtb_spr[page_number] = spr_textbox;
				snd[page_number] = sfxSansVoice;
				snd_delay_array[page_number] = 6;
				break;
				
			case"sans - eye":
				speaker_sprite[page_number] = SprNpcSansCloseEye;
				speaker_large_sprite[page_number] = noone;//escolha de usar o noone para que eu não tenha que criar um sprite vazio 
				txtb_spr[page_number] = spr_textbox;
				snd[page_number] = sfxSansVoice;
				snd_delay_array[page_number] = 6;
				break;
			
			case"armario":
				speaker_sprite[page_number] = SprAmarioSpk;
				txtb_spr[page_number] = spr_textbox;
				break;
				
			case "carol":
				speaker_sprite[page_number] = SprCarol; // use o sprite correto da Carol
				txtb_spr[page_number] = spr_textbox;
				snd[page_number] = sfxNada;             // troque pelo som de voz da Carol quando tiver
				snd_delay_array[page_number] = 4;
				break;
		}
	}
	
	// ── Visual novel: "talai", "talai-<emoção>", "talaib-<emoção>", "rasiel", "rasiel-<emoção>" ──
	if (argument_count > 1) {
		var _who = string_lower(string(argument[1]));
		// talaiB explícito: usa os sprites do explorador, independente da sala.
		if (_who == "talaib" || string_pos("talaib-", _who) == 1) {
			speaker_large_sprite[page_number] = talaiB_vn_sprite(_who == "talaib" ? "falando" : string_delete(_who, 1, 7));
			speaker_side[page_number]   = 1;      // Talai à esquerda
			txtb_spr[page_number]       = spr_textbox;
			snd[page_number]            = sfxDanielVc;   // voz do Talai
			snd_delay_array[page_number] = 4;
		}
		else if (_who == "talai" || string_pos("talai-", _who) == 1) {
			speaker_large_sprite[page_number] = talai_vn_sprite(_who == "talai" ? "falando" : string_delete(_who, 1, 6));
			speaker_side[page_number]   = 1;      // Talai à esquerda
			txtb_spr[page_number]       = spr_textbox;
			snd[page_number]            = sfxDanielVc;   // voz do Talai
			snd_delay_array[page_number] = 4;
		}
		else if (_who == "rasiel" || string_pos("rasiel-", _who) == 1 || _who == "companion" || _who == "charles") {
			var _emo = (string_pos("-", _who) > 0) ? string_delete(_who, 1, string_pos("-", _who)) : "falando";
			speaker_large_sprite[page_number] = rasiel_vn_sprite(_emo);
			speaker_side[page_number]   = -1;     // companion à direita
			txtb_spr[page_number]       = spr_textbox;
		}
	}

	// Falas SEM retrato (scr_text("...") sem o 2º argumento): voz de texto.
	// As falas com retrato de Daniel/Talai já escolheram sfxDanielVc acima.
	if (argument_count <= 1) {
		snd[page_number]             = vc_text;
		snd_delay_array[page_number] = 4;
	}
	
	page_number++;
}
/// @param option
/// @param link_id
function scr_option(_option, link_id){
	option[option_number] = _option;
	option_link_id[option_number] = link_id;
	
	option_number++;
}
/// @param text id
function create_textbox(_text_id){
	with(instance_create_depth(0,0,-99999, obj_textbox)){
		scr_game_text(_text_id);
	}  
}