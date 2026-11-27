t++;

if (estado == 0) {
    // Aviso de entrada: o cachorro ainda não machuca.
    if (t >= aviso_total) {
        estado = 1;
        t_cor  = 0;
        atualiza_sprite();
        var _entrada = bx1 - largura - 2;
        meio_x = (_entrada + bx2) / 2;
        meio_atingido = false;
    }
    exit;
}

if (estado == 3) {
    if (t >= t_fim + 6) {
        rh_debug_destroy("fim do cachorro");
        instance_destroy();
    }
    exit;
}

if (estado == 2) {
    // Parada no meio da travessia: treme e pisca em tom quente.
    t_parada++;
    x = base_x + random_range(-1.4, 1.4);
    image_blend = (((t_parada div 3) mod 2) == 0) ? make_color_rgb(255, 180, 80) : c_white;
    if (t_parada >= tempo_parada) {
        x = base_x;
        image_blend = c_white;
        if (atira) solta_fogos();
        paradas++;
        estado = 1;
        t_cor  = 0;
    }
} else {
    t_cor++;
    x += dir * vel_cachorro;
    image_index = (t_cor div 4) mod 2;   // 0,25 quadro/frame

    if (!meio_atingido && paradas < max_paradas
        && ((dir > 0 && x >= meio_x) || (dir < 0 && x <= meio_x))) {
        meio_atingido = true;
        base_x  = x;
        estado  = 2;
        t_parada = 0;
    }

    // Fim da travessia: vira e volta (ou termina, na cobrança).
    if ((dir > 0 && x >= bx2) || (dir < 0 && x + largura <= bx1)) {
        passagem++;
        if (passagem > max_passagens) {
            estado = 3;
            t_fim  = t;
            active = false;
        } else {
            dir = -dir;
            atualiza_sprite();
            x = (dir > 0) ? (bx1 - largura - 2) : (bx2 + 2);
            t_cor = 0;
            meio_atingido = false;
        }
    }
}

// Dano por geometria própria: 85% do sprite, uma vez só.
if (!was_hit && (estado == 1 || estado == 2)) {
    var _hw = largura * 0.85;
    var _hh = altura  * 0.85;
    var _x1 = x + (largura - _hw) / 2;
    var _y1 = y + (altura  - _hh) / 2;
    if (rh_rect_hits_heart(_x1, _y1, _x1 + _hw, _y1 + _hh)) {
        rh_hurt_heart(id);
    }
}
