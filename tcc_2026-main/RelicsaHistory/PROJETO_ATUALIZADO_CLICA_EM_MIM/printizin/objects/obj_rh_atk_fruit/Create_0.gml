event_inherited();
// Apenas sprites da pasta guarana (sem abacaxi/cacau/caju/etc. de fora).
sprite_index = choose(spr_guarana_attack, spr_leaf_attack);   // (spr_pe_guarana_attack tem 65x123: maior que a caixa, impossível desviar)

mode = 0;        // 0 = voa reto (dir/spd)   1 = anel se fechando em volta de (cx, cy)
dir  = 180;
spd  = 2;
cx = x; cy = y;
ang  = 0;
rad  = 60;
rad_spd = 0.5;
ang_spd = 0;