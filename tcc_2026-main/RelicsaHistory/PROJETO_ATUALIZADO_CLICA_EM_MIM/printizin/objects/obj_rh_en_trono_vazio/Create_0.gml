event_inherited();

// ── FICHA ─────────────────────────────────────────────────────────
enemy_name   = "Trono Vazio";
enemy_max_hp = 650;
dmg_min      = 5;
dmg_max      = 9;

// ── APARÊNCIA ─────────────────────────────────────────────────────
sprite_index = spr_trono_vazio;
spr_hit      = spr_trono_vazio_damage;
spr_defeated = spr_trono_vazio_defeated;
sway_y = 2;  sway_angle = 0;
alarm[0] = -1;

// Fase: 1 (cheio), 2 (abaixo de 2/3), 3 (abaixo de 1/3).
trono_phase = function() {
    var _hp = 1;
    if (instance_exists(obj_rh_battle_controller)) {
        _hp = obj_rh_battle_controller.enemy_hp / max(1, enemy_max_hp);
    }
    if (_hp <= 0.33) return 3;
    if (_hp <= 0.66) return 2;
    return 1;
};

// ── PADRÃO 1: Espadas ── (Knight: colunas descendo; na fase 3 descem em chuva)
pat_espadas = function(_t) {
    var _p = trono_phase();
    var _mod = (_p == 3) ? 26 : (_p == 2 ? 38 : 56);
    if (_t mod _mod == 8) {
        var _r = rh_box_inner();
        var _n = (_p == 3) ? 3 : 1;
        for (var i = 0; i < _n; i++) {
            var _x = (_p == 1) ? clamp(rh_heart_x() - 8 + irandom_range(-26, 26), _r.x1, _r.x2 - 16)
                               : irandom_range(_r.x1 + 4, _r.x2 - 20);
            var _s = rh_spawn_attack(obj_rh_atk_espada, _x, _r.y1 - 100);
            _s.vy = (_p == 3) ? 3.6 : 2.9;
        }
    }
};

// ── PADRÃO 2: Chifres e cartas ── (cada ataque com seu sprite, sem misturar)
trono_turn = false;
pat_chifres_cartas = function(_t) {
    var _p = trono_phase();
    if (_t mod (_p == 3 ? 34 : 50) != 10) exit;
    if (instance_exists(obj_rh_atk_chifre) || instance_exists(obj_rh_atk_carta)) exit;
    var _r = rh_box_inner();
    trono_turn = !trono_turn;
    if (trono_turn) {
        var _fromLeft = (_t mod 100 == 10);
        var _c = rh_spawn_attack(obj_rh_atk_chifre, _fromLeft ? _r.x1 - 60 : _r.x2, rh_heart_y() - 28);
        _c.vx = (_fromLeft ? 1 : -1) * (_p == 3 ? 3.1 : 2.5);
    } else {
        for (var i = 0; i < (_p == 3 ? 4 : 2); i++) {
            var _k = rh_spawn_attack(obj_rh_atk_carta, _r.x1 + 4, irandom_range(_r.y1 + 8, _r.y2 - 24));
            _k.vx = 2.0 + i * 0.15;
        }
    }
};

// ── PADRÃO 3: Icebergs ── (sobem do chão; na fase 3 vêm em sequência curta)
pat_icebergs = function(_t) {
    var _p = trono_phase();
    if (_p == 1 && (_t mod 96 != 14)) exit;
    if (_p >= 2 && (_t mod 62 != 12)) exit;
    var _r = rh_box_inner();
    var _n = (_p == 3) ? 3 : 2;
    for (var i = 0; i < _n; i++) {
        var _ice = rh_spawn_attack(obj_rh_atk_iceberg, irandom_range(_r.x1 + 6, _r.x2 - 48), _r.y2 + 8 + i * 18);
        _ice.vy = (_p == 3) ? -2.6 : -2.0;
    }
};

patterns = [pat_espadas, pat_chifres_cartas, pat_icebergs];