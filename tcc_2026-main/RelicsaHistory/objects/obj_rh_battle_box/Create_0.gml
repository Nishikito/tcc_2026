depth = 10;

// ── ANIMAÇÃO (valores configuráveis: macros BOX_* em scr_damage_calculator) ──
anim_frame = 0;      // contador INTEIRO 0..BOX_ANIM_FRAMES (soma exata, sem erro de ponto flutuante)
anim       = 0;      // 0 = fechada ... 1 = aberta (anim_frame / BOX_ANIM_FRAMES)
anim_dir   = 1;      // 1 = abrindo | -1 = fechando (o rastro usa isto)
moving     = false;  // true no frame em que a caixa está se movendo
is_open    = false;  // true SÓ com a caixa 100% aberta (coração/tiros dependem disto)
trail_gap  = 2 / BOX_ANIM_FRAMES;   // distância do rastro: 2 frames de animação