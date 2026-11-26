event_inherited();

// ── FICHA ─────────────────────────────────────────────────────────
enemy_name   = "Carumaru";
enemy_max_hp = 240;
dmg_min      = 2;
dmg_max      = 4;

// ── APARÊNCIA ─────────────────────────────────────────────────────
sprite_index = spr_carumaru;
spr_hit      = spr_carumaru_damage;
spr_defeated = spr_carumaru_defeated;
sway_y = 6;  sway_angle = 0;
alarm[0] = -1;

// CORRIGIDO: as guardas instance_exists() foram trocadas por contadores de tempo.
// Um fantasma vive 220 frames; com a guarda antiga o padrão misto ficava vazio quase o turno inteiro.

// ── PADRÃO 1: Lágrimas ── (gotas com aviso, moderado)
pat_lagrimas = function(_t) {
    if (_t mod 32 != 8) exit;
    var _r = rh_box_inner();
    var _d = rh_spawn_attack(obj_rh_atk_drop,
                             irandom_range(_r.x1 + 2, _r.x2 - 12), _r.y1 - 16);
    _d.warn_t = 26;
};

// ── PADRÃO 2: Fantasmas ── (perseguindo devagar, sempre com saída)
pat_fantasmas = function(_t) {
    var _r = rh_box_inner();
    if (_t mod 48 == 8) {
        var _g = rh_spawn_attack(obj_rh_atk_fantasma_carumaru,
                                 choose(_r.x1 + 2, _r.x2 - 34),
                                 random_range(_r.y1 + 8, _r.y2 - 66));
        _g.spd = 0.85;
    }
    if (_t mod 48 == 30) {
        var _g2 = rh_spawn_attack(obj_rh_atk_fantasma_carumaru,
                                  random_range(_r.x1 + 4, _r.x2 - 36), _r.y1 + 4);
        _g2.spd = 0.95;
    }
};

// ── PADRÃO 3: Tristeza mista ── (alterna lágrima/fantasma por tempo, nunca vazio)
pat_misto = function(_t) {
    var _r = rh_box_inner();
    if (_t mod 48 == 8) {
        var _d = rh_spawn_attack(obj_rh_atk_drop,
                                 irandom_range(_r.x1 + 2, _r.x2 - 12), _r.y1 - 16);
        _d.warn_t = 22;
    }
    if (_t mod 48 == 30) {
        var _g = rh_spawn_attack(obj_rh_atk_fantasma_carumaru,
                                 _r.x1 + 4, _r.y2 - 66);
        _g.spd = 0.9;
    }
};

patterns      = [pat_lagrimas, pat_fantasmas, pat_misto];
pattern_names = ["lagrimas", "fantasmas", "misto"];
