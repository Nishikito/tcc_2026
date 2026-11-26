event_inherited();
active = false;
clip_to_box = false;         // nasce/viaja fora da caixa (e às vezes fora da room)
visible = true;
sprite_index = spr_juiz_voador_attack;
image_speed  = 0;
image_xscale = 0.6;
image_yscale = 0.6;
is_true     = false;
ring_pos    = 0;
state       = 0;   // 0 = fade-in | 1 = telegrafia | 2 = investida | 3 = saída
telegraph_t = 0;
charge_t    = 0;
charge_spd  = 8.5; // alvo: 7 a 9 px/frame
aim         = 180;
jitter      = 0;
t           = 0;
dmg_mult    = 1.0;
destroy_on_hit = true;
// Só o verdadeiro empurra o coração (implementado no Step do coração).
kb_power = 0;
kb_dir   = 0;
