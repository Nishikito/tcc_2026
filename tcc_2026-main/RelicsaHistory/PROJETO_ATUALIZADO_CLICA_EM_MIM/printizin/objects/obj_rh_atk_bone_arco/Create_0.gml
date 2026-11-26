event_inherited();

// Osso em arco, exclusivo da chuva do Itagibe (não altera obj_rh_atk_bone,
// que continua sendo usado pelo Apressador das Sombras com o comportamento antigo).
clip_to_box    = true;
active         = true;
destroy_on_hit = true;
dmg_mult       = 1.0;

vx       = 0;
vy       = -3.5;
grav     = 0.16;
t        = 0;

// Giro por código ao sair do vaso (sentido sorteado por osso).
spin_dir = (random(1) < 0.5) ? -1 : 1;
spin_max = 14;   // graus: mantém a cobertura dentro do limite de 40% da caixa
