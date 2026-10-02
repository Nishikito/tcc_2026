image_xscale = 2;
image_yscale = 2;
tempo       = 0;
centro_y    = y;
cadencia    = 40;
spd_bala    = 2.5;
alarm[0]    = cadencia + irandom(cadencia);

// ── Reação de dano (VISUAL) ───────────────────────────────────────
// O controller liga isto no momento do impacto (hit_timer = duração).
// O Step desconta 1 por frame; o Draw usa hit_timer para tremer/piscar.
// hit_timer == 0  →  inimigo normal.
hit_timer    = 0;
hit_duration = 1; // nunca 0 (evita divisão por zero); é sobrescrito pelo controller
