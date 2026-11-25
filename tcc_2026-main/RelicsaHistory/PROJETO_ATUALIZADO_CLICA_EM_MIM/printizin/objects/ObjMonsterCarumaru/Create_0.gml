// Inimigo do MAPA: persegue o jogador e inicia a batalha (lógica herdada de ObjMonsterTest).
// O inimigo da BATALHA é o obj_rh_en_* correspondente (ver get_rh_enemy_object).
enemy_id = "Carumaru";   // ANTES do event_inherited(): o pai usa para checar se já foi derrotado
event_inherited();

// Sprite de batalha reduzido para o mapa (altura ~48 px; a máscara de colisão acompanha a escala)
var _s = 48 / sprite_get_height(sprite_index);
image_xscale = _s;
image_yscale = _s;