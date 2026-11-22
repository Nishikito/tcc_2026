event_inherited();
active = false;          // o dano vem da zona (obj_rh_atk_zone), não do sprite inteiro
warn_t = 32;             // frames de AVISO antes de subir
rise_t = 8;              // frames subindo
hold_t = 22;             // frames parado em cima
fall_t = 10;             // frames descendo
// A raiz vai do chão ATÉ O TOPO da caixa (o sprite é esticado na vertical): não sobra espaço livre por cima.
tent_h      = by2 - by1;                                   // altura na tela
tent_ys     = tent_h / sprite_get_height(sprite_index);    // fator de esticada do sprite
tent_zone_h = tent_h - 2;                                  // zona que machuca (quase a caixa toda)
t      = 0;
vis_h  = 0;
zone_made = false;
