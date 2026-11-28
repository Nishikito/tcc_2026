event_inherited();

sprite_index = spr_fire_attack;
image_speed  = 0;
image_xscale = 0.5;   // 28x35 -> ~14x17
image_yscale = 0.5;
clip_to_box  = true;

// Colisão por geometria própria; a máscara padrão não machuca.
active         = false;
dmg_mult       = 1;
destroy_on_hit = true;    // some ao acertar o coração
was_hit        = false;

vx      = 0;
vy      = -1.4;   // 30% mais lento (era -2); o cachorro sobrescreve ao atirar
t       = 0;
rebotes = 0;
puff    = 0;
largura = sprite_get_width(sprite_index)  * image_xscale;
altura  = sprite_get_height(sprite_index) * image_yscale;
