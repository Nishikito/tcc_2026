// Telegrafia enxuta: só uma faixa fina no centro da raia, para vários avisos
// não ficarem empilhados uns sobre os outros.
if (estado == "aviso") {
    var _meio = (warn_y1 + warn_y2) / 2;
    rh_draw_warning_rect(warn_x1, _meio - 2, warn_x2, _meio + 2, t);
    rh_draw_warning_line(warn_x1, _meio, warn_x2, _meio, t);
}

if (clip_to_box) {
    rh_draw_clipped(sprite_index, image_index, x, y, image_xscale, image_yscale, image_blend, image_alpha);
} else {
    draw_self();
}

// RH_ATK_DEBUG_ZONES: o contorno deve coincidir com o sprite desenhado.
if (RH_ATK_DEBUG_ZONES && active) {
    draw_set_color(c_red);
    draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);
    draw_set_color(c_white);
}
