if (instance_exists(obj_save_slots) || instance_exists(obj_settings_menu)) exit;   // menu aberto: o título não se mexe
if(image_index !=3){
	image_index += 1
	audio_play_sound(sfxSwitch, 0, false)
}else{
	image_index = 0
	audio_play_sound(sfxSwitch, 0, false)
}