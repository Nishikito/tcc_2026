event_inherited();

// Espada exclusiva do Trono Vazio: fade inofensivo -> telegrafia -> atraso -> avanço.
// active fica false: a colisão é resultado da geometria girada no Step.
active           = false;
destroy_on_hit   = false;   // single-hit feito por was_hit
clip_to_box      = true;
sprite_index     = spr_espada_attack;
image_speed      = 0;

// Ajustados pelo padrão logo após rh_spawn_attack().
esc              = 0.7;
image_xscale     = esc;
image_yscale     = esc;
dir              = 270;    // direção da PONTA (e do movimento)
spd              = 3.4;
fade_frames      = 12;
telegraph_frames = 26;
delay_frames     = 0;
warn_tipo        = 0;      // 0 = linha até a borda | 1 = linha até o centro do anel
warn_x2          = x;
warn_y2          = y;
warn_fraco       = false;

t             = 0;
estado        = 0;         // 0 fade | 1 telegrafia | 2 atraso | 3 avanço
telegraph_t   = 0;
delay_t       = 0;
jitter        = 0;
vida_max      = 240;
image_alpha   = 0.12;
