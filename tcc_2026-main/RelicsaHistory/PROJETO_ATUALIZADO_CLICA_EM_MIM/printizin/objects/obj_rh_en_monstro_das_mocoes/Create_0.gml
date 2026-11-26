event_inherited();

// ── FICHA (mini boss: dano reduzido de 5-6 para 3-4) ────────────────
enemy_name   = "Monstro das Monções";
enemy_max_hp = 420;
dmg_min      = 3;
dmg_max      = 4;

// ── APARÊNCIA ─────────────────────────────────────────────────────
sprite_index = spr_monstro_das_mocoes;
sway_y = 5;  sway_angle = 8;
alarm[0] = -1;

// Ajudante: onda numa faixa (0 alta, 1 meio, 2 baixa).
spawn_onda = function(_lane, _dir) {
    var _r = rh_box_inner();
    var _w = 73;
    var _o = rh_spawn_attack(obj_rh_atk_waves, (_dir > 0) ? _r.x1 - _w : _r.x2,
                             _r.y1 + _lane * 27.5);
    _o.vx = 2.6 * _dir;
};

// ── PADRÃO 1: canhões com 5 balas, aviso longo e mira travada ──────
// (função de instância: GML não captura `var` locais dentro de function() anônima)
spawn_blaster = function(_slot) {
    var _r = rh_box_inner();
    var _w = sprite_get_width(spr_canhao_attack);
    var _h = sprite_get_height(spr_canhao_attack);
    var _edge = irandom(3);
    var _cx = 0, _cy = 0;
    if (_edge == 0)      { _cx = irandom_range(_r.x1 + 4, _r.x2 - _w - 4); _cy = _r.y1 - _h + 8; }
    else if (_edge == 1) { _cx = _r.x2 - 10;                              _cy = irandom_range(_r.y1 + 4, _r.y2 - _h - 4); }
    else if (_edge == 2) { _cx = irandom_range(_r.x1 + 4, _r.x2 - _w - 4); _cy = _r.y2 - 10; }
    else                 { _cx = _r.x1 - _w + 10;                          _cy = irandom_range(_r.y1 + 4, _r.y2 - _h - 4); }
    var _c = rh_spawn_attack(obj_rh_atk_canhao, _cx, _cy);
    // NÃO mexe em warn_t/aim_t: o canhão já vem com aviso de 52 e mira travada no 38.
    _c.shot_gap = 10;
    _c.shot_n   = 5;
};

pat_canhao = function(_t) {
    // 4 levas de 5 balas, aviso de 52 frames: dá tempo de desviar.
    if (_t == 14 || _t == 84 || _t == 154 || _t == 224) {
        spawn_blaster((_t - 14) div 70);
    }
};

// ── PADRÃO 2: tentáculos (no máximo 2, aviso >= 30, 1 mirado só no início) ──
pat_tentaculos = function(_t) {
    var _r = rh_box_inner();
    if (_t mod 48 == 12) {
        var _hx = clamp(rh_heart_x(), _r.x1 + 12, _r.x2 - 12);
        var _a = rh_spawn_attack(obj_rh_atk_tentacle, _hx - 20, _r.y2);
        _a.warn_t = 34;   // era 22
    }
    if (_t mod 48 == 36) {
        // Segundo tentáculo longe do primeiro: 2 colunas de 18 px = 36 px < 50% da caixa.
        var _b = rh_spawn_attack(obj_rh_atk_tentacle,
                                 clamp(_r.x2 - 40 - irandom(28), _r.x1 + 4, _r.x2 - 40), _r.y2);
        _b.warn_t = 34;
    }
};

// ── PADRÃO 3: Maré (mantido; sem guardas que travam o turno) ───────
mare_turn = false;
pat_mare = function(_t) {
    var _r = rh_box_inner();
    if (_t mod 64 == 16) {
        mare_turn = !mare_turn;
        if (mare_turn) {
            var _open = irandom(2);
            var _dir = choose(1, -1);
            for (var i = 0; i < 3; i++) if (i != _open) spawn_onda(i, _dir);
        } else {
            // Duas colunas separadas, no máximo 36 px bloqueados de cada vez.
            var _c1 = irandom_range(_r.x1 + 6, _r.x2 - 46);
            var _c2 = clamp(_c1 + 54 + irandom(12), _r.x1 + 6, _r.x2 - 46);
            var _a = rh_spawn_attack(obj_rh_atk_tentacle, _c1, _r.y2); _a.warn_t = 32;
            var _b = rh_spawn_attack(obj_rh_atk_tentacle, _c2, _r.y2); _b.warn_t = 38;
        }
    }
};

patterns      = [pat_canhao, pat_tentaculos, pat_mare];
pattern_names = ["gaster_blasters", "tentaculos", "mare"];
