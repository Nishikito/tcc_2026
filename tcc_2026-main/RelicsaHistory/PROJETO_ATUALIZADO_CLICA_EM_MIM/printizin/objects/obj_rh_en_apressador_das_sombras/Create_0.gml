event_inherited();

// ── FICHA ─────────────────────────────────────────────────────────
enemy_name   = "Apressador das Sombras";
enemy_max_hp = 380;
dmg_min      = 4;
dmg_max      = 6;

// ── APARÊNCIA ─────────────────────────────────────────────────────
sprite_index = spr_apressador_aberto_attack;
spr_hit      = spr_apressador_fechado_attack;
spr_defeated = spr_apressador_fechado_attack;
sway_y = 4;  sway_angle = 0;
alarm[0] = -1;

// ── PADRÃO 1 (INALTERADO): Pisão — bota cai na coluna do coração ──
pat_pisao = function(_t) {
    if (_t mod 55 == 8) {
        var _r = rh_box_inner();
        var _b = rh_spawn_attack(obj_rh_atk_boot, 0, 0);
        _b.zone_w = 54;
        _b.zone_x = clamp(rh_heart_x() - 27 + irandom_range(-22, 22), _r.x1, _r.x2 - 54);
        _b.warn_t = 28;
    }
};

// ── PADRÃO 2: Muralha de ossos (mesmo formato antigo, sprite da própria pasta) ──
pat_ossos = function(_t) {
    if (_t mod 52 == 10) {
        var _r = rh_box_inner();
        var _h = _r.y2 - _r.y1;
        var _gap = 34;
        var _top = irandom_range(8, _h - _gap - 8);
        var _bot = _h - _gap - _top;
        var _fromRight = (irandom(1) == 0);
        var _sx = _fromRight ? _r.x2 + 2 : _r.x1 - 9;
        var _vx = _fromRight ? -1.85 : 1.85;
        var _a = rh_spawn_attack(obj_rh_atk_bone, _sx, _r.y1);
        _a.image_yscale = _top / 50; _a.vx = _vx;
        var _b = rh_spawn_attack(obj_rh_atk_bone, _sx, _r.y2 - _bot);
        _b.image_yscale = _bot / 50; _b.vx = _vx;
    }
};

// ── PADRÃO 3: Diamantes em leque ──
pat_diamantes = function(_t) {
    if (_t mod 70 == 14) {
        var _r = rh_box_inner();
        var _base = point_direction(_r.x2 + 6, rh_heart_y(), rh_heart_x(), rh_heart_y());
        for (var i = -1; i <= 1; i++) {
            var _d = rh_spawn_attack(obj_rh_atk_diamond, _r.x2 + 6, rh_heart_y() - 6);
            _d.dir = _base + i * 22;
            _d.spd = 2.0;
        }
    }
};

// ── PADRÃO 4: Aberto/fechado ── (um abre e corre, outro cai com aviso)
pat_formas = function(_t) {
    if (_t mod 80 == 12) {
        var _r = rh_box_inner();
        var _a = rh_spawn_attack(obj_rh_atk_apressador_aberto, _r.x2 + 6, clamp(rh_heart_y() - 24, _r.y1, _r.y2 - 48));
        _a.dir = 180; _a.spd = 2.5;
    }
    if (_t mod 80 == 50) {
        var _r2 = rh_box_inner();
        var _b2 = rh_spawn_attack(obj_rh_atk_apressador_fechado, irandom_range(_r2.x1 + 4, _r2.x2 - 54), _r2.y1 - 50);
        _b2.warn_t = 22;
    }
};

patterns = [pat_pisao, pat_ossos, pat_diamantes, pat_formas];