event_inherited();

// ── FICHA ─────────────────────────────────────────────────────────
enemy_name   = "Trono Vazio";
enemy_max_hp = 560;
dmg_min      = 3;
dmg_max      = 4;

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

// REGRA DE JUSTIÇA (corrigido): nada de guardas instance_exists() e nada de nascer
// com a caixa totalmente fora da room. Todo padrão tem um perigo novo a cada <=48 frames.
// Atenção: GML aqui não aceita ternário aninhado; use if/else.

// ── PADRÃO 1: Espadas ── (colunas descendo; na fase 3 descem em chuva)
pat_espadas = function(_t) {
    var _p = trono_phase();
    var _mod = 36;
    if (_p == 3) { _mod = 24; }
    else if (_p == 2) { _mod = 30; }
    if (_t mod _mod != 10) exit;

    var _r = rh_box_inner();
    var _n = 1;
    if (_p == 3) _n = 2;

    for (var i = 0; i < _n; i++) {
        // y=35: a colisão (16x98) já toca a room; o desenho só aparece ao entrar na caixa.
        var _x = irandom_range(_r.x1 + 4, _r.x2 - 20);
        if (_p == 1) {
            _x = clamp(rh_heart_x() - 8 + irandom_range(-26, 26), _r.x1, _r.x2 - 16);
        }
        var _s = rh_spawn_attack(obj_rh_atk_espada, _x, 35);
        _s.vy = 2.9;
        if (_p == 3) _s.vy = 3.6;
    }
};

// ── PADRÃO 2: Chifres e cartas ── (alternância por TEMPO, sem travar por fantasmas)
pat_chifres_cartas = function(_t) {
    var _p = trono_phase();
    var _r = rh_box_inner();
    if (_t mod 40 == 8) {
        // Nasce dentro da room (x=66 ou x=184), nunca no Outside Room.
        var _fromLeft = ((_t div 40) mod 2 == 0);
        var _cx = _r.x2 - 20;
        var _dir = -1;
        if (_fromLeft) { _cx = _r.x1 - 40; _dir = 1; }
        var _c = rh_spawn_attack(obj_rh_atk_chifre, _cx,
                                 clamp(rh_heart_y() - 27, _r.y1 + 4, _r.y2 - 55));
        _c.vx = 2.5 * _dir;
        if (_p == 3) _c.vx = 3.1 * _dir;
    }
    if (_t mod 40 == 26) {
        var _n2 = 2;
        if (_p == 3) _n2 = 3;
        for (var i = 0; i < _n2; i++) {
            var _k = rh_spawn_attack(obj_rh_atk_carta, _r.x1 + 4,
                                     irandom_range(_r.y1 + 8, _r.y2 - 24));
            _k.vx = 2.0 + i * 0.15;
        }
    }
};

// ── PADRÃO 3: Icebergs ── (sobem do chão; 2 por leva, sempre com saída)
pat_icebergs = function(_t) {
    var _p = trono_phase();
    var _mod = 36;
    if (_p == 1) _mod = 44;
    if (_t mod _mod != 10) exit;
    var _r = rh_box_inner();
    for (var i = 0; i < 2; i++) {
        // y=149 (dentro da room) em vez de y2+8: a sprite 42x47 não é cortada no nascimento.
        var _ice = rh_spawn_attack(obj_rh_atk_iceberg,
                                   irandom_range(_r.x1 + 6, _r.x2 - 48), 149 + i * 16);
        _ice.vy = -2.1;
        if (_p == 3) _ice.vy = -2.6;
    }
};

patterns      = [pat_espadas, pat_chifres_cartas, pat_icebergs];
pattern_names = ["espadas", "chifres_e_cartas", "icebergs"];
