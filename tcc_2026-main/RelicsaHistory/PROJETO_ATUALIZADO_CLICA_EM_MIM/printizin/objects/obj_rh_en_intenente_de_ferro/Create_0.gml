event_inherited();

// ── FICHA ─────────────────────────────────────────────────────────
enemy_name   = "Intenente de Ferro";
enemy_max_hp = 400;
dmg_min      = 5;
dmg_max      = 6;

// ── APARÊNCIA ─────────────────────────────────────────────────────
// Posição e escala vêm do obj_rh_battle_enemy (sprite encaixado na área do inimigo).
sprite_index = spr_intenente_de_ferro;
spr_hit      = spr_intenente_de_ferro_damage;
spr_defeated = spr_intenente_de_ferro_defeated;
sway_y = 4;  sway_angle = 0;
alarm[0] = -1;

slam_left = true;   // alterna o lado da martelada

// ── PADRÃO 1: Martelada ── (aviso vermelho de ~0,5 s numa METADE da caixa; alterna esquerda/direita)
pat_martelada = function(_t) {
    if (_t mod 92 == 5) {
        var _r = rh_box_inner();
        var _h = rh_spawn_attack(obj_rh_atk_hammer, 0, 0);
        _h.zone_w = 52;
        slam_left = (irandom(1) == 0);   // lado sorteado
        _h.zone_x = slam_left ? _r.x1 : _r.x2 - 52;
        _h.warn_t = 34;
    }
};

// ── PADRÃO 2: Gangorra ── (uma viga desce por vez, alternando esquerda/direita)
pat_gangorra = function(_t) {
    if (_t mod 55 == 5) {
        var _r = rh_box_inner();
        var _left = (irandom(1) == 0);   // lado sorteado
        rh_spawn_attack(obj_rh_atk_beam, _left ? _r.x1 + 2 : _r.x2 - 45, _r.y1 - 14);
    }
};

// ── PADRÃO 3: Sentença ── (martelada MIRADA onde o coração está; depois uma viga, nunca as duas juntas)
pat_sentenca = function(_t) {
    var _r = rh_box_inner();
    if (_t mod 98 == 5) {
        var _zx = clamp(rh_heart_x() - 22, _r.x1, _r.x2 - 44);
        var _h = rh_spawn_attack(obj_rh_atk_hammer, 0, 0);
        _h.zone_w = 44;
        _h.zone_x = _zx;
        _h.warn_t = 32;
    }
    if (_t mod 98 == 72 && !instance_exists(obj_rh_atk_hammer)) {   // só depois que o martelo saiu
        var _left = (irandom(1) == 0);
        rh_spawn_attack(obj_rh_atk_beam, _left ? _r.x1 + 2 : _r.x2 - 45, _r.y1 - 14);
    }
};

patterns = [pat_martelada, pat_gangorra, pat_sentenca];
