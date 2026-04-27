if (!global.paused) exit;

// fundo
draw_set_color(c_black);
draw_set_alpha(0.6);
draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
draw_set_alpha(1);

// texto
draw_set_halign(fa_center);

var cx = display_get_gui_width()/2;
var cy = display_get_gui_height()/2;

draw_text(cx, cy - 80, "PAUSED");

for (var i = 0; i < array_length(options); i++) {
    
    if (i == index) draw_set_color(c_yellow);
    else draw_set_color(c_white);
    
    draw_text(cx, cy + i * 40, options[i]);
}