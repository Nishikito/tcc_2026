scr_pause_game();
 
// Abas do inventário
tabs        = ["Status", "Reliquias", "Missao", "Documentos", "Consumiveis"];
current_tab = 0;
 
// Posição central na tela GUI
menu_x = display_get_gui_width()  / 2;
menu_y = display_get_gui_height() / 2;
 
// Cursor independente por aba
tab_sel = [0, 0, 0, 0, 0];
 
depth = -9999;