if (t < warn_t) {
    // Aviso: a faixa inteira por onde a onda vai varrer
    rh_draw_warning(bx1, y, bx2, y + sprite_height, t);
} else {
    event_inherited();
}
