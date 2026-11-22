event_inherited();

// ── FICHA ─────────────────────────────────────────────────────────
enemy_name   = "Caravela";
enemy_max_hp = 240;
dmg_min      = 2;
dmg_max      = 5;

// ── APARÊNCIA ─────────────────────────────────────────────────────
// Posição e escala vêm do obj_rh_battle_enemy (sprite encaixado na área do inimigo).
// Sem spr_hit: usa o slot ANIM_SLOT_ENEMY_HIT_SPRITE, como o inimigo antigo. Mantém o balanço antigo no turno inimigo.
sprite_index = spr_caravela;
alarm[0] = -1;   // o tiro mirado antigo agora é o padrão 1 (abaixo)

// ── Ajudantes ──
// Onda numa "faixa" (0 = alta, 1 = meio, 2 = baixa); _dir = 1 (->) ou -1 (<-)
spawn_onda = function(_lane, _dir) {
    var _r = rh_box_inner();
    var _w = 73;
    var _o = rh_spawn_attack(obj_rh_atk_waves, (_dir > 0) ? _r.x1 - _w : _r.x2,  _r.y1 + _lane * 27.5);
    _o.vx = 2.1 * _dir;
};

// ── PADRÃO 1: Tiro mirado ── (o ataque clássico da caravela: uma bala por vez rumo ao coração)
pat_tiro = function(_t) {
    if (_t mod 46 == 15) {
        var _b = rh_spawn_attack(obj_rh_battle_bullet, x, y);
        _b.direction = point_direction(x, y, rh_heart_x(), rh_heart_y());
        _b.speed     = 2.6;
    }
};

// ── PADRÃO 2: Tentáculos ── (sobem do chão com aviso vermelho: um na coluna do coração,
//    outro no lado oposto da caixa, um pouco depois)
pat_tentaculos = function(_t) {
    var _r  = rh_box_inner();
    var _cx = (_r.x1 + _r.x2) / 2;
    if (_t mod 82 == 10) {
        var _hx = clamp(rh_heart_x(), _r.x1 + 12, _r.x2 - 12);
        var _a  = rh_spawn_attack(obj_rh_atk_tentacle, _hx - 20, _r.y2);   // x = canto esq. do sprite (largura 40)
        _a.warn_t = 34;
    }
    if (_t mod 82 == 44) {
        var _ox = clamp(_cx * 2 - rh_heart_x(), _r.x1 + 12, _r.x2 - 12);
        var _b  = rh_spawn_attack(obj_rh_atk_tentacle, _ox - 20, _r.y2);
        _b.warn_t = 34;
    }
};

// ── PADRÃO 3: Maré ── (UM DE CADA VEZ: ondas varrem duas faixas, uma livre; depois caem 3 gotas
//    escalonadas, cada uma com a coluna de aviso piscando no ponto onde vai espirrar)
mare_turn = false;
pat_mare = function(_t) {
    if (_t mod 40 != 10) exit;
    if (instance_exists(obj_rh_atk_waves) || instance_exists(obj_rh_atk_drop) || instance_exists(obj_rh_atk_splash)) exit;
    var _r = rh_box_inner();
    mare_turn = !mare_turn;
    if (mare_turn) {
        var _open = irandom(2);
        var _dir  = choose(1, -1);
        for (var i = 0; i < 3; i++) {
            if (i != _open) spawn_onda(i, _dir);
        }
    } else {
        // 3 gotas em colunas diferentes (afastadas), caindo uma após a outra
        var _cols = [];
        var _tries = 0;
        while (array_length(_cols) < 3 && _tries < 40) {
            _tries++;
            var _cx2 = irandom_range(_r.x1 + 2, _r.x2 - 12);
            var _far = true;
            for (var k = 0; k < array_length(_cols); k++) if (abs(_cols[k] - _cx2) < 24) _far = false;
            if (_far) array_push(_cols, _cx2);
        }
        for (var i = 0; i < array_length(_cols); i++) {
            var _d = rh_spawn_attack(obj_rh_atk_drop, _cols[i], _r.y1 - 18);
            _d.warn_t = 24 + i * 14;   // escalonadas
        }
    }
};

patterns = [pat_tiro, pat_tentaculos, pat_mare];
