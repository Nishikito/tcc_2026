if (variable_global_exists("font_main")) {
    if (font_exists(global.font_main)) {
        font_delete(global.font_main);
    } 
}