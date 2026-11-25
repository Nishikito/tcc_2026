event_inherited();

// ── FICHA ─────────────────────────────────────────────────────────
enemy_name   = "Juiz das Armas";
enemy_max_hp = 520;
dmg_min      = 5;
dmg_max      = 8;

// ── APARÊNCIA ─────────────────────────────────────────────────────
sprite_index = spr_juiz_das_armas;
spr_hit      = spr_juiz_das_armas_damage;
spr_defeated = spr_juiz_das_armas_defeated;
sway_y = 3;  sway_angle = 0;
alarm[0] = -1;

// ── PADRÃO 1: Martelo girando ── (gira sozinho, cai com gravidade e encolhe 30%)
pat_martelo_giro = function(_t) {
    if (_t mod 96 == 10) {
        var _r = rh_box_inner();
        var _m = rh_spawn_attack(obj_rh_atk_hammer_giro, 0, 0);
        _m.zone_w = 58;
        _m.zone_x = clamp(rh_heart_x() - 29 + irandom_range(-26, 26), _r.x1, _r.x2 - 58);
        _m.warn_t = 32;
        _m.spin = choose(-8, 8);
        _m.shrink = 0.70;
    }
};

// ── PADRÃO 2: Clones ── (estilo Gerson: 5 juízes; só o último é verdadeiro e tem linha vermelha)
pat_clones = function(_t) {
    if (_t mod 110 == 10) {
        var _r = rh_box_inner();
        for (var i = 0; i < 5; i++) {
            var _c = rh_spawn_attack(obj_rh_atk_juiz_clone, _r.x1 - 40 - i * 34, _r.y1 + 12 + (i mod 2) * 28);
            _c.is_true = (i == 4);
            _c.vx = 2.3 + i * 0.18;
            // Mini-juízes (o último vem no tamanho normal e é o verdadeiro).
            if (i < 4) {
                _c.image_alpha = 0.72;
                _c.image_xscale = 0.6;
                _c.image_yscale = 0.6;
            }
            if (i == 2 || i == 4) _c.sprite_index = spr_juiz_voador_attack;
        }
    }
};

// ── PADRÃO 3: Bombas ── (spr_bomb_attack da própria pasta)
pat_bombas = function(_t) {
    if (_t mod 74 == 12) {
        var _r = rh_box_inner();
        var _b = rh_spawn_attack(obj_rh_atk_bomb, irandom_range(_r.x1 + 10, _r.x2 - 22), _r.y1 - 20);
        _b.fuse_y = irandom_range(_r.y1 + 20, _r.y2 - 30);
        _b.vy = 1.8; _b.fuse_frames = 20; _b.shard_spd = 2.0;
    }
};

patterns = [pat_martelo_giro, pat_clones, pat_bombas];