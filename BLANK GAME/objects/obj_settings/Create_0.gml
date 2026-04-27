// Evento Create do object_settings

// Adiciona a fonte como uma variável global
global.font_menu = font_add_sprite(spr_font, 0, true, 0, 0, 1); // ajuste o sprite e as configurações conforme necessário

// Variáveis adicionais para o menu
global.current_menu = 0; // Índice do menu atual
global.menu_options = []; // Armazena as opções do menu