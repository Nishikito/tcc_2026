xspd     = 0;
yspd     = 0;
move_spd = 2;
sprite_index = spr_rh_battle_player;
depth = -1; // na frente da caixa

// ── KNOCKBACK (investida verdadeira do Juiz) ──────────────────────
// Velocidade extra somada ao movimento; decai com atrito e some em ~12 frames.
kb_x      = 0;
kb_y      = 0;
kb_time   = 0;
kb_flash  = 0;   // frames de flash/tremida curta depois do empurrão

// ── IFRAMES ────────────────────────────────────────────────────────
// 60 frames = 1 segundo a 60 fps. Depois de levar dano o coração não pode ser
// acertado de novo e pisca enquanto o tempo dura.
iframe_max   = 60;
iframe_timer = 0;
