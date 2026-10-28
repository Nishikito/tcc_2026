// ── CONFIGURAÇÃO (frames: 60 = 1 segundo) ──
t_alert = 30;    // fase 0: "!" sobre o player
t_dark  = 24;    // fase 1: fundo escurece, coração pisca
t_slide = 30;    // fase 2: todo mundo vai para a formação de batalha
t_hold  = 8;     // fase 3: pausa em preto antes da batalha

// posições de destino, em pixels da VIEW (320x240) — CENTRO de cada sprite
// ── Rastro: MESMOS valores da battle box (macros BOX_* em scr_damage_calculator) ──
trail_count = BOX_TRAIL_COUNT;      // quantas cópias ficam para trás
trail_alpha = BOX_TRAIL_ALPHA;      // transparência da cópia mais próxima
trail_gap   = 2 / t_slide;          // cada cópia fica 2 frames atrasada

// ── DESTINOS: centro de cada sprite, em pixels da VIEW (320x240 = tela da batalha) ──
// Têm que bater EXATAMENTE com o que o rm_rh_battle desenha. Se mudar lá, mude aqui.

// Coração: canto do HP
heart_tx  = 16;   heart_ty  = 182;

// Talai: spr_talaiB_battle, desenhado pelo obj_rh_battle_controller (Draw GUI)
// em (45, 95), escala 1.5, origem no canto superior esquerdo
battle_talai_spr   = spr_talaiB_battle;
battle_talai_scale = 1.5;
battle_talai_x     = 45;
battle_talai_y     = 95;
player_tx = battle_talai_x + (sprite_get_width(battle_talai_spr)  / 2 - sprite_get_xoffset(battle_talai_spr)) * battle_talai_scale;
player_ty = battle_talai_y + (sprite_get_height(battle_talai_spr) / 2 - sprite_get_yoffset(battle_talai_spr)) * battle_talai_scale;

// Inimigo: obj_rh_battle_enemy colocado em (267, 104) no rm_rh_battle,
// redimensionado para caber em ENEMY_MAX_W x ENEMY_MAX_H (mesma conta do Create dele)
battle_enemy_x   = 267;
battle_enemy_y   = 104;
battle_enemy_spr = object_get_sprite(obj_rh_battle_enemy);
battle_enemy_fit = 1;
if (battle_enemy_spr != -1) {
    battle_enemy_fit = min(ENEMY_MAX_W / sprite_get_width(battle_enemy_spr),
                           ENEMY_MAX_H / sprite_get_height(battle_enemy_spr));
    enemy_tx = battle_enemy_x + (sprite_get_width(battle_enemy_spr)  / 2 - sprite_get_xoffset(battle_enemy_spr)) * battle_enemy_fit;
    enemy_ty = battle_enemy_y + (sprite_get_height(battle_enemy_spr) / 2 - sprite_get_yoffset(battle_enemy_spr)) * battle_enemy_fit;
} else {
    enemy_tx = battle_enemy_x;  enemy_ty = battle_enemy_y;
}

// preenchidos por quem cria
enemy          = noone;
enemy_id_value = "";

phase = 0;
timer = 0;
depth = -50000;
global.fade_active = true;

// ── captura o visual do player e do inimigo (mundo) ──
player_id = noone;
p_spr = -1; p_img = 0; p_xs = 1; p_ys = 1; p_cx = 0; p_cy = 0;
heart_x0 = 0; heart_y0 = 0; alert_x = 0; alert_y = 0;

if (instance_exists(ObjPlayer)) {
    player_id = ObjPlayer.id;
    with (ObjPlayer) {
        other.p_spr = sprite_index;
        other.p_img = image_index;
        other.p_xs  = image_xscale;
        other.p_ys  = image_yscale;
        other.p_cx  = x - sprite_get_xoffset(sprite_index) * image_xscale + sprite_get_width(sprite_index)  * image_xscale * 0.5;
        other.p_cy  = y - sprite_get_yoffset(sprite_index) * image_yscale + sprite_get_height(sprite_index) * image_yscale * 0.5;
        other.heart_x0 = other.p_cx;
        other.heart_y0 = y - sprite_get_yoffset(sprite_index) * image_yscale + sprite_get_height(sprite_index) * image_yscale * 0.4;
        other.alert_x  = other.p_cx;
        other.alert_y  = y - sprite_get_yoffset(sprite_index) * image_yscale - 6;   // acima da cabeça
    }
}

e_spr = -1; e_img = 0; e_xs = 1; e_ys = 1; e_cx = 0; e_cy = 0;
if (instance_exists(enemy)) {
    with (enemy) {
        other.e_spr = sprite_index;
        other.e_img = image_index;
        other.e_xs  = image_xscale;
        other.e_ys  = image_yscale;
        other.e_cx  = x - sprite_get_xoffset(sprite_index) * image_xscale + sprite_get_width(sprite_index)  * image_xscale * 0.5;
        other.e_cy  = y - sprite_get_yoffset(sprite_index) * image_yscale + sprite_get_height(sprite_index) * image_yscale * 0.5;
    }
}

// Escala de partida: o sprite de batalha começa com a ALTURA que o sprite do mundo tinha
// e cresce até a escala final (sem pulo de tamanho)
p_start_scale = battle_talai_scale;
if (p_spr != -1) p_start_scale = (sprite_get_height(p_spr) * abs(p_ys)) / sprite_get_height(battle_talai_spr);

e_start_scale = battle_enemy_fit;
if (e_spr != -1) e_start_scale = abs(e_xs);

// Desenha um sprite pelo CENTRO, em coordenadas da GUI
draw_copy = function(_spr, _img, _xs, _ys, _gcx, _gcy, _a, _sx, _sy) {
    var _ox = _gcx + (sprite_get_xoffset(_spr) - sprite_get_width(_spr)  / 2) * _xs * _sx;
    var _oy = _gcy + (sprite_get_yoffset(_spr) - sprite_get_height(_spr) / 2) * _ys * _sy;
    draw_sprite_ext(_spr, _img, _ox, _oy, _xs * _sx, _ys * _sy, 0, c_white, _a);
}