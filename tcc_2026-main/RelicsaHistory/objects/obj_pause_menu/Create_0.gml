// Pausa o jogo desativando todos os objetos (exceto este)
// O "true" significa "not me" — não desativa a si mesmo
instance_deactivate_all(true);

global.paused = true;

// Array com os textos de cada opção
menu_options = ["Resume Game", "Settings", "Back to Title"];

// Qual opção está selecionada (0 = primeira)
selected = 0;

// Posição central do menu na tela GUI
menu_x = display_get_gui_width()  / 2;
menu_y = display_get_gui_height() / 2;

// Altura entre cada opção
option_height = 38;

// Adiciona junto com as outras variáveis de Create
cursor_timer = 0; // controla a animação do coração