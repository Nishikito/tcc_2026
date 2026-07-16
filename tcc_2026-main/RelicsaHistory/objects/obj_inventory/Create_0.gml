//para pausar o jogo ao abrir
instance_deactivate_all(true);
instance_activate_object(obj_settings); // reativa o objeto persistente
global.paused = true;

//abas do inventário
tabs = ["Status", "Reliquias", "Missao", "Documentos", "Consumiveis"];
current_tab = 0;

//posição do inventário
menu_x = display_get_gui_width() / 2;
menu_y = display_get_gui_height() / 2;

//seleção por aba
// Cada aba pode ter um item selecionado independente
tab_sel = [0, 0, 0, 0, 0];


depth = -9999;
