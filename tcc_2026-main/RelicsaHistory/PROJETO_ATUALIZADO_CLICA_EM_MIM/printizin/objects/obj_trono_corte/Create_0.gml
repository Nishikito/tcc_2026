event_inherited();

// Corte branco do Tracking Swords: uma linha reta atravessando a Battle Box.
// Desenho e hitbox são por geometria própria, então não usa sprite nem colisão.
active         = false;
destroy_on_hit = false;
clip_to_box    = false;
sprite_index   = noone;

ctrl       = noone;
angle      = 0;       // direção da linha (perpendicular à espada)
slash_time = 0.26 * room_speed;
trono_fixed_damage = 30;             // escalado para os 50 HP do projeto
trono_iframes      = 0.4 * room_speed;  // iframes do ataque na wiki

t = 0;
