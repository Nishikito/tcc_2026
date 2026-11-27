event_inherited();

// ── MODOS (mesmo objeto, três comportamentos) ─────────────────────────
// "fileira": gota de aviso 18 frames, queda suave e respingo no chão (C1).
// "arco": tiro parabólico vindo dos cantos superiores (C3).
// "splash": gota lateral curta gerada ao bater no chão (C1); usa ESTE objeto.
modo = "fileira";

// Geometria própria: o coração só é machucado quando rh_rect_hits_heart() passa.
active         = false;
destroy_on_hit = false;   // was_hit controla o single-hit
was_hit        = false;
clip_to_box    = true;    // compatibilidade; o Draw chama rh_draw_clipped()

t       = 0;
warn_t  = 0;              // frames parado no topo com aviso (0 = sem aviso)
vida    = 240;            // autodestruição por tempo (Other_0 vazio)
vx      = 0;
vy      = 0.8;
grav    = 0.05;
vy_max  = 3.0;
image_alpha = 1;
image_speed = 0;
