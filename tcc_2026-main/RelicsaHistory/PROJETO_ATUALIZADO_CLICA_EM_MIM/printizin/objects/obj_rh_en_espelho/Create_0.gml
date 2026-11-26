event_inherited();

// ── FICHA ─────────────────────────────────────────────────────────
enemy_name   = "Espelho";
enemy_max_hp = 320;
dmg_min      = 4;
dmg_max      = 5;

// ── APARÊNCIA ─────────────────────────────────────────────────────
// Posição e escala vêm do obj_rh_battle_enemy (sprite encaixado na área do inimigo).
sprite_index = spr_espelho;
spr_hit      = spr_espelho_damage;
spr_defeated = spr_espelho_defeated;
sway_y = 5;  sway_angle = 0;
alarm[0] = -1;

// ── Ajudantes ──
// Fantasma em um ponto ALEATÓRIO da caixa, sempre a pelo menos 45 px do coração
// (nunca nasce em cima dele). Tenta algumas vezes; se não achar, nasce na parede mais longe.
spawn_fantasma = function() {
    var _r  = rh_box_inner();
    var _hx = rh_heart_x();
    var _hy = rh_heart_y();
    var _gx = 0, _gy = 0, _ok = false;
    repeat (12) {
        _gx = irandom_range(_r.x1, _r.x2 - 22);
        _gy = irandom_range(_r.y1, _r.y2 - 46);
        if (point_distance(_gx + 11, _gy + 23, _hx, _hy) >= 45) { _ok = true; break; }
    }
    if (!_ok) {
        var _cx = (_r.x1 + _r.x2) / 2;
        _gx = (_hx < _cx) ? _r.x2 - 22 : _r.x1;
        _gy = (_hy < (_r.y1 + _r.y2) / 2) ? _r.y2 - 46 : _r.y1;
    }
    rh_spawn_attack(obj_rh_atk_ghost, _gx, _gy);
};
// Onda numa "faixa" (0 = alta, 1 = meio, 2 = baixa); _dir = 1 (->) ou -1 (<-)
spawn_onda = function(_lane, _dir) {
    var _r = rh_box_inner();
    var _w = 73;
    var _o = rh_spawn_attack(obj_rh_atk_waves, (_dir > 0) ? _r.x1 - _w : _r.x2,  _r.y1 + _lane * 27.5);
    _o.vx = 2.1 * _dir;
};

// ── PADRÃO 1: Fantasmas ── (surgem em lugares aleatórios, longe do coração, e perseguem)
pat_reflexo = function(_t) {
    if (_t mod 80 == 10) spawn_fantasma();
};

// ── PADRÃO 2: Ondas ── (duas faixas varridas, uma livre; a direção é sorteada)
onda_dir = 1;
pat_ondas = function(_t) {
    if (_t mod 95 == 10) {
        var _open = irandom(2);
        onda_dir = choose(1, -1);
        for (var i = 0; i < 3; i++) {
            if (i != _open) spawn_onda(i, onda_dir);
        }
    }
};

// ── PADRÃO 3: Fantasmas e ondas ── (UM DE CADA VEZ: o próximo só entra quando o anterior sumiu)
combo_turn = false;
pat_combo = function(_t) {
    if (_t mod 35 != 10) exit;
    if (instance_exists(obj_rh_atk_ghost) || instance_exists(obj_rh_atk_waves)) exit;
    combo_turn = !combo_turn;
    if (combo_turn) spawn_fantasma();
    else            spawn_onda(irandom(2), choose(1, -1));
};

patterns = [pat_reflexo, pat_ondas, pat_combo];
