event_inherited();

// ── FICHA ─────────────────────────────────────────────────────────
enemy_name   = "Juiz das Armas";
enemy_max_hp = 500;
dmg_min      = 3;
dmg_max      = 5;

// ── APARÊNCIA ─────────────────────────────────────────────────────
sprite_index = spr_juiz_das_armas;
spr_hit      = spr_juiz_das_armas_damage;
spr_defeated = spr_juiz_das_armas_defeated;
sway_y = 3;  sway_angle = 0;
alarm[0] = -1;

// RITMO DE ROUND (Undertale/Deltarune): ataques novos a cada <= 42 frames,
// do frame 8 até o fim do turno (300 frames). Nada de "um golpe e 3s parado".

// ── PADRÃO 1: Martelo que tomba ── (lado escolhido pelo próprio martelo)
pat_martelo_tomba = function(_t) {
    if (_t mod 42 != 8) exit;
    var _r = rh_box_inner();
    rh_spawn_attack(obj_rh_atk_hammer_tomba, _r.x1 + 40, _r.y2 - 4);
};

// ── PADRÃO 2: Círculo de juízes ── (duas levas: a 2ª começa antes da 1ª acabar)
pat_circulo = function(_t) {
    if (_t != 6 && _t != 150) exit;
    var _r = rh_box_inner();
    rh_spawn_attack(obj_rh_atk_juiz_circle,
                    (_r.x1 + _r.x2) / 2, (_r.y1 + _r.y2) / 2);
};

// ── PADRÃO 3: Bombas ── (mais frequente: 8 levas por round)
pat_bombas = function(_t) {
    if (_t mod 36 != 10) exit;
    var _r = rh_box_inner();
    var _b = rh_spawn_attack(obj_rh_atk_bomb,
                             irandom_range(_r.x1 + 10, _r.x2 - 22), _r.y1 - 20);
    _b.fuse_y = irandom_range(_r.y1 + 20, _r.y2 - 30);
    _b.vy = 1.8; _b.fuse_frames = 18; _b.shard_spd = 2.1;
};

patterns      = [pat_martelo_tomba, pat_circulo, pat_bombas];
pattern_names = ["martelo_que_tomba", "circulo_de_juizes", "bombas"];
