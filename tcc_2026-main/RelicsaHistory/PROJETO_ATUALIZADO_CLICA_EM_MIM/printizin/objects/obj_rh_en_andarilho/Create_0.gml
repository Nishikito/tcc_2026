event_inherited();

// ── FICHA ─────────────────────────────────────────────────────────
enemy_name   = "Andarilho";
enemy_max_hp = 320;
dmg_min      = 3;
dmg_max      = 5;

// ── APARÊNCIA ─────────────────────────────────────────────────────
// Posição e escala vêm do obj_rh_battle_enemy (sprite encaixado na área do inimigo).
sprite_index = spr_mercante;
spr_hit      = spr_mercante_damage;
spr_defeated = spr_mercante_defeated;
sway_y = 4;  sway_angle = 0;          // balanço leve no turno inimigo
alarm[0] = -1;                        // sem tiro mirado antigo: ataca pelos padrões abaixo

// ── PADRÃO 1: Chuva de moedas ── (estilo "chuva" de Undertale: cai de cima, acelera)
pat_chuva = function(_t) {
    if (_t mod 13 == 0) {
        var _r = rh_box_inner();
        var _c = rh_spawn_attack(obj_rh_atk_coin, irandom_range(_r.x1 + 2, _r.x2 - 11), _r.y1 - 12);
        _c.vy   = 1.1;
        _c.grav = 0.04;
    }
};

// ── PADRÃO 2: Leque de diamantes ── (5 diamantes mirados no coração, com vãos entre eles)
pat_leque = function(_t) {
    if (_t mod 58 == 20) {
        var _bx = enemy_px(14);   // a trouxa (de onde saem os diamantes): ponto 14,46 do sprite
        var _by = enemy_py(46);
        var _base = point_direction(_bx, _by, rh_heart_x(), rh_heart_y());
        for (var i = -2; i <= 2; i++) {
            var _d = rh_spawn_attack(obj_rh_atk_diamond, _bx - 8, _by - 6);
            _d.dir = _base + i * 18;
            _d.spd = 1.9;
        }
    }
};

// ── PADRÃO 3: Bolas quicantes ── (quicam 2x nas paredes da caixa)
pat_bolas = function(_t) {
    if (_t mod 70 == 10) {
        var _r = rh_box_inner();
        var _b = rh_spawn_attack(obj_rh_atk_ball, _r.x2 - 12, choose(_r.y1 + 6, _r.y2 - 16));
        var _a = irandom_range(150, 210);   // rumo à esquerda
        _b.vx = lengthdir_x(1.8, _a);
        _b.vy = lengthdir_y(1.8, _a);
        _b.bounces_left = 3;
    }
};

patterns = [pat_chuva, pat_leque, pat_bolas];
