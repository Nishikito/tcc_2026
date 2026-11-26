event_inherited();

// Lança vertical do Itagibe: aviso -> voo reto -> fim.
// Vy explícito evita a confusão de graus do GML (90° = baixo, 270° = cima).
clip_to_box     = true;
image_angle     = 0;
active          = false;
destroy_on_hit  = true;
dmg_mult        = 1.0;

vy              = 4.2;                       // >0 desce; <0 sobe
sair            = "baixo";                   // "baixo" = sai pela base; "cima" = sai pelo topo
warn_frames     = 20;
warn_x1         = x;
warn_x2         = x + 12;
warn_y1         = by1;
warn_y2         = by2;
estado          = "aviso";
t               = 0;
