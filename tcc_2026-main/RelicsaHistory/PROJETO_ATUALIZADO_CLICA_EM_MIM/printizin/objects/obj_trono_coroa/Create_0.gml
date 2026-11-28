event_inherited();

// Coroa do ataque Stars. A sequência toda é: aviso -> cresce -> avança -> pausa
// (onde solta os estilhaços) -> volta -> some. active só liga no avanço: o aviso
// e o crescimento são inofensivos, como manda a regra de justiça do projeto.
active         = false;
destroy_on_hit = false;   // was_hit já garante um acerto por coroa
clip_to_box    = true;
sprite_index   = spr_coroa_attack;
image_speed    = 0;
// Tamanho reduzido em 60% a pedido: antes crescia de 0.3 até 1, agora de 0.12 até 0.4.
// Mantemos a mesma proporção de crescimento para o aviso continuar legível.
image_xscale   = 0.12;
image_yscale   = 0.12;

// Valores enviados pelo obj_trono_attack_controller logo após rh_spawn_attack().
// Tempos em FRAMES (segundos * room_speed) para bater com o resto do projeto.
ctrl        = noone;
dir         = 0;          // direção do avanço (graus)
spd         = 2.4;
grow_time   = 0.8 * room_speed;
hold_time   = 0.2 * room_speed;
back_time   = 1.0 * room_speed;
warn_time   = 0.3 * room_speed;
fragment_life = 1.2 * room_speed;
fragment_n  = 3;          // nível 1: 3 dos 6 estilhaços possíveis
fragment_base_dir = 0;
trono_fixed_damage = 75;  // dano fixo do ataque (não usa o sorteio do inimigo)
trono_iframes      = 1.0 * room_speed;

t       = 0;
estado  = 0;   // 0 aviso | 1 cresce | 2 avança | 3 pausa | 4 volta | 5 some
grow_t  = 0;
hold_t  = 0;
back_t  = 0;
orig_x  = x;
orig_y  = y;
frag_spawned = false;
