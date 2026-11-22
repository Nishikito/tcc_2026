event_inherited();
image_alpha = 0;     // invisível (o aviso/sprite bonito é desenhado pelo dono da zona)
active      = false; // só liga depois do delay e de se posicionar
zone_x = 0; zone_y = 0; zone_w = 16; zone_h = 16;   // retângulo (pixels da room)
zone_delay = 0;      // frames antes de começar a machucar
zone_life  = 10;     // frames machucando
t      = 0;
inited = false;
destroy_on_hit = false;   // continua existindo, mas active = false após acertar (1 dano por zona)
