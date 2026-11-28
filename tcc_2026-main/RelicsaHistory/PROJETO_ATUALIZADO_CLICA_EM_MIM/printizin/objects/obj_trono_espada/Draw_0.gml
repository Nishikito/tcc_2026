// Aviso: linha vermelha da espada até o coração enquanto ela acompanha o alvo.
// Pisca para o jogador perceber a direção antes do corte.
if (estado == 0) {
    // Oito avisos ao mesmo tempo: mais fracos para não poluir a caixa.
    var _al = 0.16;
    if (((t div 4) mod 2) == 0) _al = 0.38;

    draw_set_alpha(_al);
    draw_set_color(c_red);
    draw_line_width(x, y, rh_heart_x(), rh_heart_y(), 2);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

// A PONTA da lâmina fica embaixo (y=96, direção 90 em image_angle = 0): o
// topo é a guarda escura. Como dir é a posição da espada em relação ao coração,
// a ponta deve olhar para dentro (dir + 180), então o giro é dir + 90.
var _ang = dir + 90;

rh_draw_clipped_ext(sprite_index, image_index, x, y,
                    esc, esc, _ang, image_blend, image_alpha);

// No congelamento a espada já está vermelha; um brilho reforça o "agora".
if (estado == 1) {
    draw_set_alpha(0.5);
    draw_set_color(c_white);
    draw_circle(x, y, 5, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
}
