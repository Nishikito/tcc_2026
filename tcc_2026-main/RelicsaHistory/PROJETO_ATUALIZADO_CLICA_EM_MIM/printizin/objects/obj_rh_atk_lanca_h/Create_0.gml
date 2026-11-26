event_inherited();

// Lança horizontal do Itagibe: aviso -> voo reto -> fim.
// NUNCA usamos image_angle: o sprite já vem alinhado ao eixo horizontal.
// Assim o desenho recortado e a máscara de colisão são exatamente o mesmo retângulo.
clip_to_box     = true;
image_angle     = 0;
active          = false;
destroy_on_hit  = true;
dmg_mult        = 1.0;

dir             = 180;   // 180 = ponta à esquerda (vem da direita); 0 = ponta à direita
spd             = 4.2;
warn_frames     = 22;
warn_x1         = bx1;
warn_x2         = bx2;
warn_y1         = y - 3.5;
warn_y2         = y + 15.5;
estado          = "aviso";
t               = 0;
