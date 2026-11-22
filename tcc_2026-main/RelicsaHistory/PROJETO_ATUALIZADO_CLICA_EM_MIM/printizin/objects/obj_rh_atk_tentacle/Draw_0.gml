var _w = sprite_get_width(sprite_index);
if (t < warn_t) {
    // Aviso: a coluna onde a raiz vai subir (do chão até o topo da caixa)
    rh_draw_warning(x + _w / 2 - 9, by2 - tent_zone_h, x + _w / 2 + 9, by2, t);
}
else if (vis_h >= 1) {
    // Só a parte que já subiu (cortada no chão da caixa), esticada para chegar ao topo
    var _vh  = floor(vis_h);          // pixels visíveis na tela
    var _src = _vh / tent_ys;         // pixels correspondentes no arquivo do sprite
    draw_sprite_part_ext(sprite_index, 0, 0, sprite_get_height(sprite_index) - _src, _w, _src,
                         x, by2 - _vh, 1, tent_ys, c_white, 1);
}
