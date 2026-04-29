
draw_clear(c_black);


if (logo_alpha > 0) {
    var _center_x = room_width / 2 + shake_x;
    var _center_y = room_height / 2 + shake_y;
    
 
    var _logo_x = _center_x - (sprite_get_width(spr_title_deltarune) * logo_scale) / 2;
    var _logo_y = _center_y - (sprite_get_height(spr_title_deltarune) * logo_scale) / 2;
    
    draw_sprite_ext(spr_title_deltarune, 0, _logo_x, _logo_y, 
                    logo_scale, logo_scale, 0, c_white, logo_alpha);
}


if (show_enter_text && logo_ready) {
    if (variable_global_exists("font_main")) {
        draw_set_font(global.font_title);
    }
    
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_set_color(c_white);
    draw_set_alpha(enter_text_alpha);
    
    var _text_y = room_height / 2 + (sprite_get_height(spr_title_deltarune) * logo_scale) / 2 + 50;
    draw_text(room_width / 2, _text_y, "Pressione Enter");
    
    draw_set_alpha(1);
}