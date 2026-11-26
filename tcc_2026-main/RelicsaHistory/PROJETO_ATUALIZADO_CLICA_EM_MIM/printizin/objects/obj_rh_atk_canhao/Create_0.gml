event_inherited();
// Canhão: mira no coração por 38 frames, TRAVA, avisa até o frame 52 e
// dispara 5 balas de canhão em sequência (sem laser, sem perseguição).
active = false;
clip_to_box = false;
visible = true;      // o Draw desenha o canhão e o aviso por código
dmg_mult = 1.0;      // ficha do Monstro das Monções: 3-4
aim_t    = 38;       // para de perseguir aqui
warn_t   = 52;       // 14 frames extras com a mira travada antes da 1ª bala
shot_gap = 10;       // intervalo entre balas
shot_n   = 5;
t = 0;
aim = 180;
aim_lock = 180;
locked = false;
shots_left = 0;
next_shot = 0;
jitter = 0;
