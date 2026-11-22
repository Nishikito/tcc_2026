event_inherited();

// ── FICHA ─────────────────────────────────────────────────────────
enemy_name   = "Guaraná";
enemy_max_hp = 200;
dmg_min      = 2;
dmg_max      = 4;

// ── APARÊNCIA ─────────────────────────────────────────────────────
// Posição e escala vêm do obj_rh_battle_enemy (sprite encaixado na área do inimigo).
sprite_index = spr_guarana;
spr_hit      = spr_guarana_damage;
spr_defeated = spr_guarana_defeated;
sway_y = 3;  sway_angle = 0;
alarm[0] = -1;

// Inimigo TUTORIAL: só ataques de FRUTA, simples, lentos e sempre com saída óbvia.

// ── PADRÃO 1: Frutas ── (uma fruta por vez, devagar, na direção do coração: ensina a desviar)
pat_frutas = function(_t) {
    if (_t mod 62 == 20) {
        var _px = enemy_px(24);  var _py = enemy_py(28);   // boca da planta (ponto 24,28 do sprite)
        var _f = rh_spawn_attack(obj_rh_atk_fruit, _px, _py);
        _f.mode = 0;
        _f.dir  = point_direction(_px, _py, rh_heart_x(), rh_heart_y());
        _f.spd  = 1.45;
    }
};

// ── PADRÃO 2: Chuva de frutas ── (caem do topo da caixa, devagar e espaçadas)
pat_chuva = function(_t) {
    if (_t mod 36 == 0) {
        var _r = rh_box_inner();
        var _f = rh_spawn_attack(obj_rh_atk_fruit, irandom_range(_r.x1 + 2, _r.x2 - 16), _r.y1 - 14);
        _f.mode = 0;
        _f.dir  = 270;          // para baixo
        _f.spd  = 1.25;
        _f.clip_to_box = true;  // só aparece ao entrar na caixa
    }
};

// ── PADRÃO 3: Leque de frutas ── (três frutas abertas em leque, com vãos largos; dá para passar entre elas)
pat_leque = function(_t) {
    if (_t mod 85 == 20) {
        var _px = enemy_px(24);  var _py = enemy_py(28);
        var _base = point_direction(_px, _py, rh_heart_x(), rh_heart_y());
        for (var i = -1; i <= 1; i++) {
            var _f = rh_spawn_attack(obj_rh_atk_fruit, _px, _py);
            _f.mode = 0;
            _f.dir  = _base + i * 28;
            _f.spd  = 1.45;
        }
    }
};

patterns = [pat_frutas, pat_chuva, pat_leque];
