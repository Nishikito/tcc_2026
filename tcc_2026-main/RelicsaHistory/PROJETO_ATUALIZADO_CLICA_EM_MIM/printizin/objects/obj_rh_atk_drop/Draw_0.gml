if (t < warn_t) {
    // Aviso: a coluna por onde a gota vai cair, até o chão da caixa
    rh_draw_warning(x - 2, by1, x + sprite_width + 2, by2, t);
} else {
    event_inherited();
}
