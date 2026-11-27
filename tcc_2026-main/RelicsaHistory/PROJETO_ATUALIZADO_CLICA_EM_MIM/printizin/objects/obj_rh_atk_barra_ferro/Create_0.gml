event_inherited();

// Barra de ferro: dano por GEOMETRIA PRÓPRIA (retângulo da barra).
// active = false: a máscara padrão NÃO machuca; o Step chama rh_hurt_heart(id).
active         = false;
destroy_on_hit = false;   // single-hit controlado por was_hit
clip_to_box    = false;   // desenho próprio com rh_draw_clipped
sprite_index   = spr_donou2_attack;

BAR_SCALE = 0.6;
bar_w = sprite_get_width(sprite_index)  * BAR_SCALE;   // ~25.8 px
bar_h = sprite_get_height(sprite_index) * BAR_SCALE;   //  ~8.4 px

// Variáveis configuradas pelo inimigo (valores padrão seguros).
mode        = 0;   // 0 = salvo das Barras; 1 = Sentença
t           = 0;
warn_frames = 22;  // aviso no ponto de pouso antes de aparecer
vy          = 0;
grav        = 0.12;
vy_max      = 3.4;
ground_y    = by2 - bar_h;
landed      = false;
flash_t     = 0;

// Só usados pela Sentença (modo 1).
rest_frames      = 30;
rest_t           = 0;
warn_line_frames = 20;
smash_frames     = 6;
smash_spawned    = false;
launch_now       = false;   // ligado pelo martelo que esmaga
launched         = false;
launch_dir       = 1;
launch_speed     = 5;
dmg_mult         = 1.0;

// Rastro da barra lançada (6 posições, em anel).
trail   = [0, 0, 0, 0, 0, 0];
trail_i = 0;
