/// @param text
function scr_set_defaults_for_text(){
	line_break_pos[0, page_number]=999;
	line_break_num[page_number]=0;
	line_break_offset[page_number]=0;
	
	txtb_spr[page_number] = spr_textbox;
	speaker_sprite[page_number]= noone;
	speaker_side[page_number] = 1;
	snd[page_number] = sfxNada;
	snd_delay_array[page_number]= 4;
}
///@param text
///@param [portrait]
function scr_text(_text){
	
	scr_set_defaults_for_text()
	
	text[page_number] =_text;
	text_lenght[page_number] = string_length(_text);
	
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
				txtb_spr[page_number] = spr_textbox;
				snd[page_number] = sfxSansVoice;
				snd_delay_array[page_number] = 6;
				break;
				
			case"sans - eye":
				speaker_sprite[page_number] = SprNpcSansCloseEye;
				txtb_spr[page_number] = spr_textbox;
				snd[page_number] = sfxSansVoice;
				snd_delay_array[page_number] = 6;
				break;
			
			case"armario":
				speaker_sprite[page_number] = SprAmarioSpk;
				txtb_spr[page_number] = spr_textbox;
				break;
		}
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
		scr_game_text(_text_id)
	}  
}