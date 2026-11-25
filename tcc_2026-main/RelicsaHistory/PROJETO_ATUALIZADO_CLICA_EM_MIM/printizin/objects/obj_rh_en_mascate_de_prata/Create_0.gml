event_inherited();

// ── FICHA ─────────────────────────────────────────────────────────
enemy_name   = "Mascate de Prata";
enemy_max_hp = 360;
dmg_min      = 4;
dmg_max      = 6;

// ── APARÊNCIA ─────────────────────────────────────────────────────
sprite_index = spr_mascate_de_prata;
spr_hit      = spr_mascate_de_prata_damage;
spr_defeated = spr_mascate_de_prata_defeated;
sway_y = 4;  sway_angle = 0;
alarm[0] = -1;

// ── Ajudantes (todos os sprites vêm da pasta mascate_de_prata) ──────
spawn_joia = function(_spr, _vx, _vy) {
    var _r = rh_box_inner();
    var _o = rh_spawn_attack(_spr, random_range(_r.x1 + 4, _r.x2 - 20), _r.y1 - 30);
    _o.vx = _vx;  _o.vy = _vy;
    _o.clip_to_box = true;
};

// ── PADRÃO 1: Joias ── (anel, brinco e colar caem em colunas diferentes)
pat_joias = function(_t) {
    if (_t mod 64 == 10) {
        spawn_joia(obj_rh_atk_anel,   -0.4, 1.0);
        spawn_joia(obj_rh_atk_brinco,  0.3, 1.3);
        spawn_joia(obj_rh_atk_colar,   0.0, 0.9);
    }
};

// ── PADRÃO 2: Espirais ── (3 espirais fechando em direções diferentes)
pat_espiral = function(_t) {
    if (_t mod 78 == 14) {
        for (var i = 0; i < 3; i++) {
            var _s = rh_spawn_attack(obj_rh_atk_espiral, rh_heart_x(), rh_heart_y());
            _s.ang = i * 120 + irandom(30);
            _s.ang_spd = (i == 1) ? -6 : 6;
        }
    }
};

// ── PADRÃO 3: Saco ── (aviso vermelho, queda com gravidade e zona machucando)
pat_saco = function(_t) {
    if (_t mod 90 == 12) {
        var _r = rh_box_inner();
        var _b = rh_spawn_attack(obj_rh_atk_saco, 0, 0);
        _b.zone_w = 54;
        _b.zone_x = clamp(rh_heart_x() - 27 + irandom_range(-24, 24), _r.x1, _r.x2 - 54);
        _b.warn_t = 30;
    }
};

// ── PADRÃO 4: Setas e "bla" ── (um de cada vez, alternating)
mascate_turn = false;
pat_setas = function(_t) {
    if (_t mod 42 != 12) exit;
    if (instance_exists(obj_rh_atk_seta) || instance_exists(obj_rh_atk_bla)) exit;
    var _r = rh_box_inner();
    mascate_turn = !mascate_turn;
    if (mascate_turn) {
        var _s = rh_spawn_attack(obj_rh_atk_seta, _r.x2 + 6, clamp(rh_heart_y() - 15, _r.y1, _r.y2 - 30));
        _s.dir = 180 + irandom_range(-8, 8);
    } else {
        var _b = rh_spawn_attack(obj_rh_atk_bla, _r.x1 + 4, irandom_range(_r.y1 + 6, _r.y2 - 25));
        _b.vx = 2.3;
    }
};

// ── PADRÃO 5: Chuva de moedas ── (só com sprite da própria pasta)
pat_moedas = function(_t) {
    if (_t mod 15 == 0) {
        var _r = rh_box_inner();
        var _c = rh_spawn_attack(obj_rh_atk_coin, irandom_range(_r.x1 + 2, _r.x2 - 11), _r.y1 - 12);
        _c.vy = 1.1;
        _c.grav = 0.04;
    }
};

patterns = [pat_joias, pat_espiral, pat_saco, pat_setas, pat_moedas];