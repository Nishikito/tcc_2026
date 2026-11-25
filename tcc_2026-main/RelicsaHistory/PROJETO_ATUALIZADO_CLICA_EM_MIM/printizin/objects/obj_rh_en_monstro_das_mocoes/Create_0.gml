event_inherited();

// ── FICHA ─────────────────────────────────────────────────────────
enemy_name   = "Monstro das Monções";
enemy_max_hp = 420;
dmg_min      = 4;
dmg_max      = 7;

// ── APARÊNCIA ─────────────────────────────────────────────────────
// Sem spr_hit próprio: usa o slot ANIM_SLOT_ENEMY_HIT_SPRITE (spr_monstro_das_mocoes).
sprite_index = spr_monstro_das_mocoes;
sway_y = 5;  sway_angle = 8;
alarm[0] = -1;

// Ajudante: onda numa faixa (0 alta, 1 meio, 2 baixa). Um pouco mais rápida que antes.
spawn_onda = function(_lane, _dir) {
    var _r = rh_box_inner();
    var _w = 73;
    var _o = rh_spawn_attack(obj_rh_atk_waves, (_dir > 0) ? _r.x1 - _w : _r.x2, _r.y1 + _lane * 27.5);
    _o.vx = 2.6 * _dir;
};

// ── PADRÃO 1: Canhões ── (Gaster Blaster: canhão sorteado, mira, 5 tiros rápidos em sequência)
pat_canhao = function(_t) {
    if (_t mod 96 != 12) exit;
    var _r = rh_box_inner();
    var _w = sprite_get_width(spr_canhao_attack);
    var _h = sprite_get_height(spr_canhao_attack);
    var _edge = irandom(3);
    var _cx = 0, _cy = 0;
    if (_edge == 0)      { _cx = irandom_range(_r.x1 + 4, _r.x2 - _w - 4); _cy = _r.y1 - _h + 6; }
    else if (_edge == 1) { _cx = _r.x2 - 6;                              _cy = irandom_range(_r.y1 + 4, _r.y2 - _h - 4); }
    else if (_edge == 2) { _cx = irandom_range(_r.x1 + 4, _r.x2 - _w - 4); _cy = _r.y2 - 6; }
    else                 { _cx = _r.x1 - _w + 6;                          _cy = irandom_range(_r.y1 + 4, _r.y2 - _h - 4); }
    var _c = rh_spawn_attack(obj_rh_atk_canhao, _cx, _cy);
    _c.warn_t  = 26;
    _c.n_shots = 5;
    _c.fire_t  = 7;
    _c.spd     = 5.4;
};

// ── PADRÃO 2: Tentáculos ── (sem receita: 3 colunas sorteadas, avisos curtos, um mirado no coração)
pat_tentaculos = function(_t) {
    var _r = rh_box_inner();
    if (_t == 10 || _t == 34 || _t == 58) {
        var _hx = clamp(rh_heart_x(), _r.x1 + 12, _r.x2 - 12);
        var _col = (_t == 34) ? _hx : irandom_range(_r.x1 + 14, _r.x2 - 14);
        var _a = rh_spawn_attack(obj_rh_atk_tentacle, _col - 20, _r.y2);
        _a.warn_t = 22;
    }
    if (_t mod 96 == 76) {
        var _b = rh_spawn_attack(obj_rh_atk_tentacle, clamp(_r.x2 - 40 - irandom(30), _r.x1, _r.x2 - 40), _r.y2);
        _b.warn_t = 18;
    }
};

// ── PADRÃO 3: Maré ── (mesmo formato de antes, só com a pasta do monstro)
// 1ª variante: duas faixas de ondas atravessam a caixa; 2ª variante: tentáculos
// sobem em colunas diferentes. Nada de gotas/estilhaços de outras pastas.
mare_turn = false;
pat_mare = function(_t) {
    if (_t mod 38 != 8) exit;
    if (instance_exists(obj_rh_atk_waves) || instance_exists(obj_rh_atk_tentacle)) exit;
    var _r = rh_box_inner();
    mare_turn = !mare_turn;
    if (mare_turn) {
        var _open = irandom(2);
        var _dir = choose(1, -1);
        for (var i = 0; i < 3; i++) if (i != _open) spawn_onda(i, _dir);
    } else {
        var _cols = [];
        var _tries = 0;
        while (array_length(_cols) < 2 && _tries < 40) {
            _tries++;
            var _c = irandom_range(_r.x1 + 6, _r.x2 - 46);
            var _far = true;
            for (var k = 0; k < array_length(_cols); k++) if (abs(_cols[k] - _c) < 26) _far = false;
            if (_far) array_push(_cols, _c);
        }
        for (var i = 0; i < array_length(_cols); i++) {
            var _a = rh_spawn_attack(obj_rh_atk_tentacle, _cols[i], _r.y2);
            _a.warn_t = 18 + i * 10;
        }
    }
};

patterns = [pat_canhao, pat_tentaculos, pat_mare];