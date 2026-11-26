event_inherited();

// ── FICHA ─────────────────────────────────────────────────────────
enemy_name   = "Colonizador";
enemy_max_hp = 460;
dmg_min      = 4;
dmg_max      = 6;

// ── APARÊNCIA ─────────────────────────────────────────────────────
// Posição e escala vêm do obj_rh_battle_enemy (sprite encaixado na área do inimigo).
sprite_index = spr_colonizador;
spr_hit      = spr_colonizador_damage;
spr_defeated = spr_colonizador_defeated;
sway_y = 3;  sway_angle = 0;
alarm[0] = -1;

// ── PADRÃO 1: Pisão ── (a bota cai na coluna do coração; fique fora da sombra vermelha)
pat_pisao = function(_t) {
    if (_t mod 55 == 8) {
        var _r = rh_box_inner();
        var _b = rh_spawn_attack(obj_rh_atk_boot, 0, 0);
        _b.zone_w = 54;
        _b.zone_x = clamp(rh_heart_x() - 27 + irandom_range(-22, 22), _r.x1, _r.x2 - 54);
        _b.warn_t = 28;
    }
};

// ── PADRÃO 2: Bombardeio ── (bombas caem, acendem o pavio e explodem em 6 estilhaços)
pat_bombardeio = function(_t) {
    if (_t mod 50 == 10) {
        var _r = rh_box_inner();
        var _b = rh_spawn_attack(obj_rh_atk_bomb, irandom_range(_r.x1 + 10, _r.x2 - 22), _r.y1 - 20);
        _b.fuse_y = irandom_range(_r.y1 + 18, _r.y2 - 34);
        _b.vy = 1.7;  _b.fuse_frames = 22;  _b.shard_spd = 1.8;
    }
};

// ── PADRÃO 3: Fogo e dardos ── (UM DE CADA VEZ: chama sobe do chão; depois um dardo rápido cruza na altura do coração)
fogo_turn = false;
pat_fogo = function(_t) {
    if (_t mod 38 != 6) exit;
    if (instance_exists(obj_rh_atk_fire) || instance_exists(obj_rh_atk_dart)) exit;
    var _r = rh_box_inner();
    fogo_turn = !fogo_turn;
    if (fogo_turn) rh_spawn_attack(obj_rh_atk_fire, irandom_range(_r.x1, _r.x2 - 28), _r.y2);
    else           rh_spawn_attack(obj_rh_atk_dart, enemy_px(5), clamp(rh_heart_y() - 4, _r.y1, _r.y2 - 8));
};

patterns = [pat_pisao, pat_bombardeio, pat_fogo];
