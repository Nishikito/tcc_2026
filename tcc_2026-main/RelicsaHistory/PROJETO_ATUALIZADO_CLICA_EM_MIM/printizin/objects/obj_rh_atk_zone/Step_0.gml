if (!inited) {
    inited = true;
    // O sprite da bala tem máscara 16x13 (com 2 px vazios no topo): escala para virar o retângulo pedido
    image_xscale = max(zone_w, 1) / 16;
    image_yscale = max(zone_h, 1) / 13;
    x = zone_x;
    y = zone_y - 2 * image_yscale;
}
t++;
active = (t > zone_delay && t <= zone_delay + zone_life);
if (t > zone_delay + zone_life) instance_destroy();
