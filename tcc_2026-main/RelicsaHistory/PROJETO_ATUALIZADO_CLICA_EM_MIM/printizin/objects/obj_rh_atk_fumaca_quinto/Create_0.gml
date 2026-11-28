event_inherited();

sprite_index = spr_fumaca_attack;
image_speed  = 8 / 60;   // 5 quadros a ~8 fps
image_xscale = 0.6;
image_yscale = 0.6;
clip_to_box  = true;

// Hitbox própria (retângulo); a máscara padrão não machuca.
active         = false;
dmg_mult       = 1;
destroy_on_hit = false;   // a fumaça continua visível depois do primeiro acerto
was_hit        = false;

escala_fumaca = 0.6;
vel_fumaca    = -1.1;   // sobe 1,1 px/frame
// A fumaça vive até encostar no topo da arena (by1), não um número fixo de frames.
// Assim ela atravessa a caixa inteira mesmo com a altura mudando.
vida_fumaca   = max(40, ceil((y - by1) / abs(vel_fumaca)));
t             = 0;
