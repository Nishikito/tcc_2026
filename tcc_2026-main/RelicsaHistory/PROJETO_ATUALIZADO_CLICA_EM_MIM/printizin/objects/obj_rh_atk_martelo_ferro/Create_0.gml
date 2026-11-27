event_inherited();

// Martelo de ferro: dano por GEOMETRIA PRÓPRIA (cabeça rotacionada).
// active = false: a máscara padrão NÃO machuca; o Step chama rh_hurt_heart(id).
active         = false;
destroy_on_hit = false;   // single-hit controlado por was_hit
clip_to_box    = false;   // desenho próprio com rh_draw_clipped_pivot
sprite_index   = spr_hammer_attack;

// ── Geometria do arquivo (spr_hammer_attack: 102x78) ──────────────
PIVOT_X = 2;    PIVOT_Y = 76;   // ponta da haste (canto inferior esquerdo)
HEAD_X  = 82;   HEAD_Y  = 10;   // centro aproximado da cabeça no arquivo
HEAD_W  = 72;   HEAD_H  = 44;   // -> 36x22 px após a escala
SCALE_H    = 0.5;    // martelo pequeno
ANG_IMPACT = 130;    // ÂNGULO que faz a CABEÇA apontar para baixo
ANG_UP     = -60;    // descanso: haste inclinada, cabeça fora da caixa
ANG_PREP   = -82;    // preparação: inclinada ainda mais para trás

// Variáveis configuradas pelo inimigo (valores padrão seguros).
mode        = 0;    // 0 = martelada (I1); 1 = esmagar a barra (I3)
px          = x;    // ponta da haste no mundo
py          = y;
ang         = ANG_UP;
t           = 0;
warn_frames = 30;
prep_frames = 14;
fall_frames = 6;
zone_frames = 10;
lock_heart  = false;
lock_frame  = 30;
smash_frames = 6;
py_start    = y;
py_end      = y;
target_bar  = noone;
shake_t     = 0;
dmg_mult    = 1.5;

// Centro da cabeça no mundo para um dado ângulo: mesma conta no aviso e no dano.
head_pos = function(_ang) {
    var _vx = (HEAD_X - PIVOT_X) * SCALE_H;   //  40
    var _vy = (HEAD_Y - PIVOT_Y) * SCALE_H;   // -33
    var _a  = degtorad(_ang);
    return {
        x: px + _vx * cos(_a) - _vy * sin(_a),
        y: py + _vx * sin(_a) + _vy * cos(_a)
    };
};

// Aviso: retângulo exato onde a cabeça vai bater (já recortado na caixa).
var _hp = head_pos(ANG_IMPACT);
var _hw = HEAD_W * SCALE_H / 2;
var _hh = HEAD_H * SCALE_H / 2;
zone_x1 = max(bx1, _hp.x - _hw);
zone_y1 = max(by1, _hp.y - _hh);
zone_x2 = min(bx2, _hp.x + _hw);
zone_y2 = min(by2, _hp.y + _hh);
