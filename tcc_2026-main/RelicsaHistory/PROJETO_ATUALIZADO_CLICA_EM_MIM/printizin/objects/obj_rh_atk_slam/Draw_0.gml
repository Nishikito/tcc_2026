if (t < warn_t) {
    rh_draw_warning(zone_x, by1, zone_x + zone_w, by2, t);   // aviso: a coluna que vai ser atingida
} else {
    // Golpe na metade direita da caixa: o martelo vem virado (espelhado), como se viesse "de lá"
    var _flip = flip_on_right && ((zone_x + zone_w / 2) > (bx1 + bx2) / 2);
    if (_flip) {
        draw_sprite_ext(sprite_index, image_index, x + sprite_get_width(sprite_index), y, -1, 1, image_angle, c_white, image_alpha);
    } else {
        draw_self();
    }
}
