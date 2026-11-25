event_inherited();

// ── FICHA ─────────────────────────────────────────────────────────
enemy_name   = "Carumaru";
enemy_max_hp = 260;
dmg_min      = 3;
dmg_max      = 5;

// ── APARÊNCIA ─────────────────────────────────────────────────────
sprite_index = spr_carumaru;
spr_hit      = spr_carumaru_damage;
spr_defeated = spr_carumaru_defeated;
sway_y = 6;  sway_angle = 0;
alarm[0] = -1;

// ── PADRÃO 1: Lágrimas ── (Napstablook: gotas com aviso, moderado)
pat_lagrimas = function(_t) {
    if (_t mod 54 == 10) {
        var _r = rh_box_inner();
        var _d = rh_spawn_attack(obj_rh_atk_drop, irandom_range(_r.x1 + 2, _r.x2 - 12), _r.y1 - 18);
        _d.warn_t = 26;
    }
};

// ── PADRÃO 2: Fantasmas ── (fantasma da própria pasta perseguindo devagar)
pat_fantasmas = function(_t) {
    if (_t mod 84 == 12) {
        var _r = rh_box_inner();
        var _g = rh_spawn_attack(obj_rh_atk_fantasma_carumaru, choose(_r.x1 + 2, _r.x2 - 34), random_range(_r.y1 + 8, _r.y2 - 66));
        _g.spd = 0.75;
    }
    if (_t mod 84 == 46) {
        var _r2 = rh_box_inner();
        var _g2 = rh_spawn_attack(obj_rh_atk_fantasma_carumaru, random_range(_r2.x1 + 4, _r2.x2 - 36), _r2.y1 + 4);
        _g2.spd = 0.9;
    }
};

// ── PADRÃO 3: Tristeza mista ── (uma lágrima, depois um fantasma, nunca os dois juntos)
carumaru_turn = false;
pat_misto = function(_t) {
    if (_t mod 44 != 10) exit;
    if (instance_exists(obj_rh_atk_drop) || instance_exists(obj_rh_atk_fantasma_carumaru)) exit;
    var _r = rh_box_inner();
    carumaru_turn = !carumaru_turn;
    if (carumaru_turn) {
        var _d = rh_spawn_attack(obj_rh_atk_drop, irandom_range(_r.x1 + 2, _r.x2 - 12), _r.y1 - 18);
        _d.warn_t = 22;
    } else {
        var _g = rh_spawn_attack(obj_rh_atk_fantasma_carumaru, _r.x1 + 4, _r.y2 - 66);
        _g.spd = 0.85;
    }
};

patterns = [pat_lagrimas, pat_fantasmas, pat_misto];