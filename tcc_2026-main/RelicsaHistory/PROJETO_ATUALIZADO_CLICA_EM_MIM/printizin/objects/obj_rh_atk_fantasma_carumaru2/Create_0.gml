event_inherited();

// (x,y) = CENTRO do sprite (o Draw usa rh_draw_clipped_ext, que centraliza a origem).
// Personalidades definidas pelo inimigo: "seguidor" / "eco" / "parede".
personality = "seguidor";

// spr_ghost_attack 22x46 = seguidor/eco; spr_fantasma_carumaru_attack 33x65 = parede.
sprite_index = spr_ghost_attack;
image_speed  = 0;
image_alpha  = 0.15;

// Geometria própria: active=false e rh_hurt_heart() no Step. Hitbox = 80% do sprite.
active         = false;
destroy_on_hit = false;   // was_hit controla o single-hit
was_hit        = false;

t           = 0;
vida        = 200;
fade_in     = 30;         // semi-transparente e INOFENSIVO
fade_out    = 20;         // fade final, também inofensivo
vel         = 0.8;
turn_every  = 60;         // a parede muda de lado/borda a cada 60 frames
turn_t      = 0;
borda_eixo  = "cima";     // cima / baixo / esquerda / direita
borda_dir   = 1;
eco_buffer  = [];         // array de structs {x,y}, uma posição por frame
