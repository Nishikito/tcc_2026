event_inherited();
// Mordida do Apressador das Sombras: 24 frames de aviso -> 8 de bote -> 6 de mordida -> 16 de recuo.
// A aparição é o sprite "fechado" já existente (placeholder da mordida); o DANO vem
// de uma zona pequena na frente da boca, para não acertar o sprite inteiro.
active = false;
clip_to_box = false;
visible = true;
sprite_index = spr_apressador_fechado_attack;
image_speed = 0;
image_xscale = 0.9;
image_yscale = 0.9;
start_x = x;  start_y = y;
state = 0;    // 0 aviso | 1 bote | 2 mordida | 3 recuo
t = 0;
warn_t = 24;
lunge_t = 0;
bite_t = 0;
retreat_t = 0;
lunge_frames = 8;
bite_frames = 6;
retreat_frames = 16;
lunge_spd = 5.0;
retreat_spd = 3.2;
aim = 180;
dmg_mult = 1.0;
zone_inst = noone;
