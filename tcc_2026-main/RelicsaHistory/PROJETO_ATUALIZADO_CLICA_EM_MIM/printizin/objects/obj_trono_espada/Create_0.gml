event_inherited();

// Tracking Swords (Ataque 2): oito espadas cercam o coração, giram e pulsam
// devagar, depois disparam em sequência virando cortes brancos.
// active fica false: o dano é do corte, nunca da espada em telegrafia.
active         = false;
destroy_on_hit = false;
clip_to_box    = true;
sprite_index   = spr_espada_attack;
image_speed    = 0;

// 16x98 px: 0.3 dá ~5x29 px. Com 8 espadas, radius 24 mantém todas na caixa.
esc = 0.3;
image_xscale = esc;
image_yscale = esc;
image_alpha  = 1;

// Preenchidos por trono_tick_controller() logo após rh_spawn_attack().
ctrl         = noone;
dir          = 90;   // ângulo da espada ao redor do coração (gira devagar)
base_radius  = 24;   // distância do coração; pulsa ±2 px
estado       = 0;    // 0 rastreia | 1 vermelha, esperando o disparo

warn_time   = 1.0 * room_speed;   // quando começa a fase de disparo
fire_at     = warn_time;          // frame do controller em que vira corte
freeze_time = 0.12 * room_speed;  // aviso vermelho antes do corte

t  = 0;
fx = 0;   // onde o coração estava quando a espada congelou
fy = 0;
