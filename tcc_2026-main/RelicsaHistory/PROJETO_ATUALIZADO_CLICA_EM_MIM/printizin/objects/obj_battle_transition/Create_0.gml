// ── CONFIGURAÇÃO (frames: 60 = 1 segundo) ──
t_alert = 30;    // fase 0: "!" sobre o player
t_dark  = 24;    // fase 1: fundo escurece, coração pisca
t_slide = 30;    // fase 2: todo mundo vai para a formação de batalha
t_hold  = 8;     // fase 3: pausa antes da batalha

// ── Rastro: MESMOS valores da battle box ──
trail_count = BOX_TRAIL_COUNT;
trail_alpha = BOX_TRAIL_ALPHA;
trail_gap   = 2 / t_slide;

// ── DESTINOS: centro de cada sprite, em pixels da VIEW (320x240 = tela da batalha) ──
// Têm que bater com o que o rm_rh_battle desenha. Se mudar lá, mude aqui.
heart_tx = UI_MENU_HEART_X;
heart_ty = UI_MENU_HEART_Y;

battle_talai_spr   = spr_talaiB_battle;
battle_talai_scale = 1.5;
battle_talai_x     = 45;
battle_talai_y     = 95;
player_tx = battle_talai_x + (sprite_get_width(battle_talai_spr)  / 2 - sprite_get_xoffset(battle_talai_spr)) * battle_talai_scale;
player_ty = battle_talai_y + (sprite_get_height(battle_talai_spr) / 2 - sprite_get_yoffset(battle_talai_spr)) * battle_talai_scale;

// Chegam do struct do instance_create_depth. Só cria o padrão se faltarem.
if (!variable_instance_exists(id, "enemy"))          enemy          = noone;
if (!variable_instance_exists(id, "enemy_id_value")) enemy_id_value = "";

battle_enemy_x   = 267;
battle_enemy_y   = 104;
// Cada inimigo é um objeto (obj_rh_en_*) com sprite próprio: o destino é calculado pelo sprite DELE.
battle_enemy_spr = object_get_sprite(get_rh_enemy_object(enemy_id_value));
battle_enemy_fit = 1;
enemy_tx = battle_enemy_x;
enemy_ty = battle_enemy_y;
if (battle_enemy_spr != -1) {
    battle_enemy_fit = min(ENEMY_MAX_W / sprite_get_width(battle_enemy_spr),
                           ENEMY_MAX_H / sprite_get_height(battle_enemy_spr));
    enemy_tx = battle_enemy_x + (sprite_get_width(battle_enemy_spr)  / 2 - sprite_get_xoffset(battle_enemy_spr)) * battle_enemy_fit;
    enemy_ty = battle_enemy_y + (sprite_get_height(battle_enemy_spr) / 2 - sprite_get_yoffset(battle_enemy_spr)) * battle_enemy_fit;
}

phase = 0;
timer = 0;
depth = -50000;
global.fade_active = true;

// ── visual do player e do inimigo no MUNDO (recapturado todo frame nas fases 0 e 1) ──
player_id = noone;
p_spr = -1; p_img = 0; p_xs = 1; p_ys = 1; p_cx = 0; p_cy = 0;
heart_x0 = 0; heart_y0 = 0; alert_x = 0; alert_y = 0;
e_spr = -1; e_img = 0; e_xs = 1; e_ys = 1; e_cx = 0; e_cy = 0;
p_start_scale = battle_talai_scale;
e_start_scale = battle_enemy_fit;

capture_world = function() {
    var _p = instance_find(ObjPlayer, 0);
    if (_p != noone) {
        player_id = _p;
        p_spr = _p.sprite_index;
        p_img = _p.image_index;
        p_xs  = _p.image_xscale;
        p_ys  = _p.image_yscale;
        var _top = _p.y - sprite_get_yoffset(p_spr) * p_ys;
        p_cx = _p.x - sprite_get_xoffset(p_spr) * p_xs + sprite_get_width(p_spr) * p_xs * 0.5;
        p_cy = _top + sprite_get_height(p_spr) * p_ys * 0.5;
        heart_x0 = p_cx;
        heart_y0 = _top + sprite_get_height(p_spr) * p_ys * 0.4;
        alert_x  = p_cx;
        alert_y  = _top - 6;   // acima da cabeça
        // o sprite de batalha começa com a ALTURA do sprite do mundo (sem pulo de tamanho)
        p_start_scale = (sprite_get_height(p_spr) * abs(p_ys)) / sprite_get_height(battle_talai_spr);
    }
    if (instance_exists(enemy)) {
        e_spr = enemy.sprite_index;
        e_img = enemy.image_index;
        e_xs  = enemy.image_xscale;
        e_ys  = enemy.image_yscale;
        e_cx  = enemy.x - sprite_get_xoffset(e_spr) * e_xs + sprite_get_width(e_spr)  * e_xs * 0.5;
        e_cy  = enemy.y - sprite_get_yoffset(e_spr) * e_ys + sprite_get_height(e_spr) * e_ys * 0.5;
        e_start_scale = abs(e_xs);
    }
}

// Desenha um sprite pelo CENTRO, em coordenadas do MUNDO
draw_copy = function(_spr, _img, _xs, _ys, _cx, _cy, _a) {
    var _ox = _cx + (sprite_get_xoffset(_spr) - sprite_get_width(_spr)  / 2) * _xs;
    var _oy = _cy + (sprite_get_yoffset(_spr) - sprite_get_height(_spr) / 2) * _ys;
    draw_sprite_ext(_spr, _img, _ox, _oy, _xs, _ys, 0, c_white, _a);
}

capture_world();