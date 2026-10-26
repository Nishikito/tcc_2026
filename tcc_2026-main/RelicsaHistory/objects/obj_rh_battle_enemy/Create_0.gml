var _fit = min(ENEMY_MAX_W / sprite_get_width(sprite_index),
               ENEMY_MAX_H / sprite_get_height(sprite_index));
image_xscale = _fit;
image_yscale = _fit;
tempo       = 0;
centro_y    = y;
// Cadência e velocidade da bala vêm da definição do inimigo (get_rh_enemy_data)
var _data   = get_rh_enemy_data(global.current_enemy_id);
cadencia    = _data.cadence;
spd_bala    = _data.bullet_speed;
alarm[0]    = cadencia + irandom(cadencia);

// ── Reação de dano (VISUAL) ───────────────────────────────────────
// O controller liga isto no momento do impacto (hit_timer = duração).
// O Step desconta 1 por frame; o Draw usa hit_timer para tremer/piscar.
// hit_timer == 0  →  inimigo normal.
hit_timer    = 0;
hit_duration = 1; // nunca 0 (evita divisão por zero); é sobrescrito pelo controller
