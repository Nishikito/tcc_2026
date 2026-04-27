// Mudança de Opções com Teclas
if (keyboard_check_pressed(vk_up)) {
    pause = max(pause - 1, 0);
} else if (keyboard_check_pressed(vk_down)) {
    pause = min(pause + 1, op_length - 1);
}

// Implementação do Sistema de Menu
switch (option[pause]) {
    case "Start Game":
        // Código para iniciar o jogo
        break;
    case "Settings":
        // Código para acessar configurações
        break;
    case "Quick Game":
        // Código para jogo rápido
        break;
}