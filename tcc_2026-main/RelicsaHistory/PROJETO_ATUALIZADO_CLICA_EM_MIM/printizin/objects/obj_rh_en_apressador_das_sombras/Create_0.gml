event_inherited();

// ── FICHA ─────────────────────────────────────────────────────────
enemy_name   = "Apressador das Sombras";
enemy_max_hp = 360;
dmg_min      = 3;
dmg_max      = 4;

// ── APARÊNCIA ─────────────────────────────────────────────────────
// Corpo do próprio Apressador das Sombras (sprites de ataque reaproveitados
// como aparência, como no projeto original — sem placeholder novo).
sprite_index = spr_apressador_aberto_attack;
spr_hit      = spr_apressador_fechado_attack;
spr_defeated = spr_apressador_fechado_attack;
sway_y = 4;  sway_angle = 0;
alarm[0] = -1;

// ── PADRÃO 1 (INALTERADO): Pisão — bota cai na coluna do coração ──
pat_pisao = function(_t) {
    if (_t mod 40 == 8) {
        var _r = rh_box_inner();
        var _b = rh_spawn_attack(obj_rh_atk_boot, 0, 0);
        _b.zone_w = 54;
        _b.zone_x = clamp(rh_heart_x() - 27 + irandom_range(-22, 22), _r.x1, _r.x2 - 54);
        _b.warn_t = 28;
    }
};

// ── PADRÃO 2: Muralha de ossos (mesmo formato antigo, sprite da própria pasta) ──
pat_ossos = function(_t) {
    if (_t mod 38 == 10) {
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
    if (_t mod 44 == 14) {
        var _r = rh_box_inner();
        var _base = point_direction(_r.x2 + 6, rh_heart_y(), rh_heart_x(), rh_heart_y());
        for (var i = -1; i <= 1; i++) {
            var _d = rh_spawn_attack(obj_rh_atk_diamond, _r.x2 + 6, rh_heart_y() - 6);
            _d.dir = _base + i * 22;
            _d.spd = 2.0;
        }
    }
};

// ── PADRÃO 4 (NOVO): Mordida do Apressador das Sombras ──
// aviso 24 -> bote 8 -> mordida 6 -> recuo 16; mira travada no início do bote.
pat_mordida = function(_t) {
    if (_t mod 60 != 12) exit;
    var _r = rh_box_inner();
    var _fromRight = (irandom(1) == 0);
    var _x = _fromRight ? _r.x2 + 8 : _r.x1 - 48;
    var _y = clamp(rh_heart_y() - 24, _r.y1 + 4, _r.y2 - 48);
    var _m = rh_spawn_attack(obj_rh_atk_mordida, _x, _y);
    _m.start_x = _x;  _m.start_y = _y;
    _m.warn_t = 24;
};

patterns      = [pat_pisao, pat_ossos, pat_diamantes, pat_mordida];
pattern_names = ["pisao", "ossos", "diamantes", "mordida"];