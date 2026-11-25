event_inherited();

// ── FICHA ─────────────────────────────────────────────────────────
enemy_name   = "Itagibe";
enemy_max_hp = 300;
dmg_min      = 3;
dmg_max      = 5;

// ── APARÊNCIA ─────────────────────────────────────────────────────
sprite_index = spr_itagibe;
spr_hit      = spr_itagibe_damage;
spr_defeated = spr_itagibe_defeated;
sway_y = 4;  sway_angle = 0;
alarm[0] = -1;

// ── PADRÃO 1: Lanças retas ── (estilo Deltarune Knight: linhas retas, rápidas, com saída óbvia)
pat_lancas = function(_t) {
    if (_t mod 72 == 10) {
        var _r = rh_box_inner();
        var _y = clamp(rh_heart_y() - 6 + irandom_range(-18, 18), _r.y1 + 4, _r.y2 - 16);
        for (var i = 0; i < 3; i++) {
            var _l = rh_spawn_attack(obj_rh_atk_lanca, _r.x2 + 8 + i * 74, _y);
            _l.dir = 180;
            _l.spd = 3.1;
        }
    }
};

// ── PADRÃO 2: Lanças do teto ── (colunas descendo; uma delas mira o coração)
pat_lancas_teto = function(_t) {
    if (_t mod 80 == 16) {
        var _r = rh_box_inner();
        var _cols = [clamp(rh_heart_x() - 33, _r.x1, _r.x2 - 66), irandom_range(_r.x1 + 6, _r.x2 - 66)];
        for (var i = 0; i < array_length(_cols); i++) {
            var _l = rh_spawn_attack(obj_rh_atk_lanca, _cols[i], _r.y1 + i * 26);
            _l.dir = 270;
            _l.spd = 2.8;
        }
    }
};

// ── PADRÃO 3: Vasos com chuva de ossos ── (ossos da pasta do apressador: exceção permitida)
pat_vasos = function(_t) {
    if (_t mod 96 == 12) {
        var _r = rh_box_inner();
        var _v = rh_spawn_attack(obj_rh_atk_vaso, irandom_range(_r.x1 + 8, _r.x2 - 36), _r.y2 - 15);
        _v.n_drops = 7;
        _v.interval = 8;
    }
    if (_t mod 96 == 52) {
        var _r2 = rh_box_inner();
        var _v2 = rh_spawn_attack(obj_rh_atk_vaso, irandom_range(_r2.x1 + 8, _r2.x2 - 36), _r2.y2 - 15);
        _v2.n_drops = 5;
        _v2.interval = 10;
    }
};

patterns = [pat_lancas, pat_lancas_teto, pat_vasos];