event_inherited();

// ── FICHA ─────────────────────────────────────────────────────────
enemy_name   = "Estatueta";
enemy_max_hp = 280;
dmg_min      = 3;
dmg_max      = 5;

// ── APARÊNCIA ─────────────────────────────────────────────────────
// Posição e escala vêm do obj_rh_battle_enemy (sprite encaixado na área do inimigo).
sprite_index = spr_estatueta;
spr_hit      = spr_estatueta_damage;
spr_defeated = spr_estatueta_defeated;
sway_y = 4;  sway_angle = 0;
alarm[0] = -1;

wall_right = true;   // de que lado vem a próxima muralha (alterna)

// ── PADRÃO 1: Muralha de ossos ── (dois ossos com um vão de 32 px; o vão muda de altura)
pat_muralha = function(_t) {
    if (_t mod 46 == 10) {
        var _r   = rh_box_inner();
        var _h   = _r.y2 - _r.y1;                 // altura interna da caixa
        var _gap = 30;
        var _top = irandom_range(8, _h - _gap - 8);   // comprimento do osso de cima
        var _bot = _h - _gap - _top;                  // o de baixo completa a caixa
        wall_right = (irandom(1) == 0);   // lado sorteado
        var _sx  = wall_right ? _r.x2 + 2 : _r.x1 - 9;
        var _vx  = wall_right ? -1.8 : 1.8;
        var _b1 = rh_spawn_attack(obj_rh_atk_bone, _sx, _r.y1);
        _b1.image_yscale = _top / 50;  _b1.vx = _vx;
        var _b2 = rh_spawn_attack(obj_rh_atk_bone, _sx, _r.y2 - _bot);
        _b2.image_yscale = _bot / 50;  _b2.vx = _vx;
    }
};

// ── PADRÃO 2: Ossos em zigue-zague ── (um osso por vez, alternando teto e chão: pule de lado)
pat_zigzague = function(_t) {
    if (_t mod 28 == 8) {
        var _r  = rh_box_inner();
        var _len = 44;
        var _top = (irandom(1) == 0);   // teto ou chão sorteado
        var _b = rh_spawn_attack(obj_rh_atk_bone, _r.x2 + 2, _top ? _r.y1 : _r.y2 - _len);
        _b.image_yscale = _len / 50;
        _b.vx = -2.0;
    }
};

// ── PADRÃO 3: Chuva de gravetos ── (giram caindo do céu)
pat_gravetos = function(_t) {
    if (_t mod 15 == 0) {
        var _r = rh_box_inner();
        var _s = rh_spawn_attack(obj_rh_atk_stick, irandom_range(_r.x1, _r.x2 - 8), _r.y1 - 34);
        _s.vy = 1.3;
    }
};

patterns = [pat_muralha, pat_zigzague, pat_gravetos];
