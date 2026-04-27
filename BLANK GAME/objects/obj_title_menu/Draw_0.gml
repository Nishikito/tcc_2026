//draw_set_font(fnt_menu);
draw_set_halign(fa_left);

switch (state) {

    case MENU_STATE.TITLE:
        
        for (var i = 0; i < array_length(options); i++) {
            
            if (i == index) draw_set_color(c_yellow);
            else draw_set_color(c_white);
            
            draw_text(100, 100 + i * 30, options[i]);
        }
        
    break;


    case MENU_STATE.SAVE_SELECT:
        
        draw_set_color(c_white);
        draw_text(100, 60, "SELECT SAVE");
        
        for (var i = 0; i < array_length(save_options); i++) {
            
            if (i == save_index) draw_set_color(c_yellow);
            else draw_set_color(c_white);
            
            draw_text(100, 100 + i * 30, save_options[i]);
        }
        
    break;


    case MENU_STATE.NEW_SAVE:
        
        draw_set_color(c_white);
        draw_text(100, 80, "ENTER YOUR NAME:");
        
        draw_set_color(c_yellow);
        draw_text(100, 120, player_name + "_");
        
    break;
}