// Telegrafia enxuta: faixa fina no centro da coluna (evita avisos empilhados).
if (estado == "aviso") {
    var _meio = (warn_x1 + warn_x2) / 2;
    rh_draw_warning_rect(_meio - 2, warn_y1, _meio + 2, warn_y2, t);
    rh_draw_warning_line(_meio, warn_y1, _meio, warn_y2, t);
}

if (clip_to_box) {
    rh_draw_clipped(sprite_index, image_index, x, y, image_xscale, image_yscale, image_blend, image_alpha);
} else {
    draw_self();
}

if (RH_ATK_DEBUG_ZONES && active) {
    draw_set_color(c_red);
    draw_rectangle(bbox_left, bbox_top, bbox_right, bbox_bottom, true);
    draw_set_color(c_white);
}
