event_inherited();

// Estilhaço da coroa: nasce dentro da caixa e sai em linha reta.
// active já vem true do pai: ele machuca no contato, uma vez só (was_hit).
// Estilhaço agora usa spr_donou_attack (a faixa fina pedida para as explosões).
sprite_index = spr_donou_attack;
image_speed  = 0;
image_xscale = 0.35;   // se ficar fino demais na tela, é só subir este valor
image_yscale = 0.35;
destroy_on_hit = false;

// Preenchidos pela coroa no momento do spawn.
ctrl = noone;
dir  = 0;
spd  = 2.0;
life = 1.2 * room_speed;
trono_fixed_damage = 75;
trono_iframes      = 1.0 * room_speed;

t = 0;
