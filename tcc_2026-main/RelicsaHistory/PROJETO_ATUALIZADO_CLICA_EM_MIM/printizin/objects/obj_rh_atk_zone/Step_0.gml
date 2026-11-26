if (!inited) {
    inited = true;
    // O sprite da bala tem máscara 16x13 (com 2 px vazios no topo): escala para virar o retângulo pedido
    image_xscale = max(zone_w, 1) / 16;
    image_yscale = max(zone_h, 1) / 13;
    x = zone_x;
    y = zone_y - 2 * image_yscale;
}
t++;
// Só machuca dentro da janela de vida E se ainda não acertou o coração (antes reativava todo frame = vários acertos seguidos)
active = (!was_hit && t > zone_delay && t <= zone_delay + zone_life);
if (t > zone_delay + zone_life) { rh_debug_destroy("fim da vida"); instance_destroy(); }
