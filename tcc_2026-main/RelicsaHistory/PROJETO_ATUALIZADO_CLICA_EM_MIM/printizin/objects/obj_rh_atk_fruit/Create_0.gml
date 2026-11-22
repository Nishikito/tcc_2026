event_inherited();
// Uma fruta aleatória das que existem no projeto
sprite_index = choose(spr_abacaxi, spr_cacau, spr_caju, spr_maracuja, spr_cupuacu_eu_acho);

mode = 0;        // 0 = voa reto (dir/spd)   1 = anel se fechando em volta de (cx, cy)
dir  = 180;
spd  = 2;
cx = x; cy = y;  // centro do anel (modo 1)
ang  = 0;        // ângulo da fruta no anel
rad  = 60;       // raio atual do anel
rad_spd = 0.5;   // quanto o raio encolhe por frame
ang_spd = 0;     // giro do anel (graus por frame; 0 = não gira)
