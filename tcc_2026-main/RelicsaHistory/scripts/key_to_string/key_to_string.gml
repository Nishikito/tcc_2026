function key_to_string(key) {
    // Letras A-Z
    if (key >= ord("A") && key <= ord("Z")) {
        return chr(key);
    }
    // Números 0-9
    if (key >= ord("0") && key <= ord("9")) {
        return chr(key);
    }
    // Teclas especiais
    switch (key) {
        case vk_shift:     return "SHIFT";
        case vk_control:   return "CTRL";
        case vk_alt:       return "ALT";
        case vk_enter:     return "ENTER";
        case vk_space:     return "SPACE";
        case vk_backspace: return "BACKSPACE";
        case vk_tab:       return "TAB";
        case vk_up:        return "UP";
        case vk_down:      return "DOWN";
        case vk_left:      return "LEFT";
        case vk_right:     return "RIGHT";
        case vk_f1:        return "F1";
        case vk_f2:        return "F2";
        case vk_f3:        return "F3";
        case vk_f4:        return "F4";
        case vk_f5:        return "F5";
        case vk_f6:        return "F6";
        case vk_f7:        return "F7";
        case vk_f8:        return "F8";
        case vk_f9:        return "F9";
        case vk_f10:       return "F10";
        case vk_f11:       return "F11";
        case vk_f12:       return "F12";
        default:           return "KEY" + string(key);
    }
}