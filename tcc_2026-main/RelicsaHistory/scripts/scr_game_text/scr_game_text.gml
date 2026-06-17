///@param text_id
function scr_game_text(_text_id){
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