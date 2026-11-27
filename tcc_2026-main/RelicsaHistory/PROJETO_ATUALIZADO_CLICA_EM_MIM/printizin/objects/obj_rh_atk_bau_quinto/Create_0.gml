event_inherited();

sprite_index = spr_bau_fechado_attack;
image_speed  = 0;
image_index  = 0;
image_xscale = 0.85;
image_yscale = 0.85;

// O baú só avisa; quem machuca é a fumaça (geometria própria).
active         = false;
dmg_mult       = 1;
destroy_on_hit = false;
was_hit        = false;
clip_to_box    = RH_BAU_DENTRO;

tele_total = 90;
bau_idx    = 0;
escala_bau = 0.85;
base_x     = x;
t          = 0;
estado     = 0;   // 0 = treme/vermelho, 1 = aberto com flash, 2 = fechado escurecido
pop        = 0;
