// Desenha o inimigo. Substitui o draw_self automático para poder aplicar a
// reação de dano (tremida + piscada vermelha, ou o sprite de dano) e o sprite de derrota.
// Tudo controlado por hit_timer / hit_duration (ligados pelo controller).
// Sprites trocados (dano/derrota) são alinhados pelo CENTRO-BAIXO do sprite normal, qualquer que seja
// a origem de cada um (os de dano/derrota têm tamanho e origem um pouco diferentes do idle).
var _spr   = sprite_index;
var _img   = image_index;
var _ox    = 0;
var _oy    = 0;
var _blend = c_white;

// Âncora (em pixels da room): centro-baixo do sprite normal
var _ax = x + (sprite_get_width(sprite_index)  / 2 - sprite_get_xoffset(sprite_index)) * image_xscale;
var _ay = y + (sprite_get_height(sprite_index)     - sprite_get_yoffset(sprite_index)) * image_yscale;

var _won = (instance_exists(obj_rh_battle_controller)
         && obj_rh_battle_controller.state == BATTLE_STATE.VICTORY);

if (_won && spr_defeated != noone) {
    _spr = spr_defeated;
    _img = 0;
    _ox  = (_ax - (sprite_get_width(_spr)  / 2 - sprite_get_xoffset(_spr)) * image_xscale) - x;
    _oy  = (_ay - (sprite_get_height(_spr)     - sprite_get_yoffset(_spr)) * image_yscale) - y;
}
else if (hit_timer > 0) {
    var _elapsed = hit_duration - hit_timer;   // frames desde o início da reação
    var _fade    = hit_timer / hit_duration;   // 1 → 0: a tremida enfraquece

    _ox = dsin(_elapsed * 90) * ANIM_ENEMY_HIT_SHAKE_PIXELS * _fade;

    var _hspr = spr_hit;
    if (_hspr == noone) _hspr = ANIM_SLOT_ENEMY_HIT_SPRITE;

    if (_hspr != noone) {
        // Sprite de dano (sem loop: trava no último frame)
        _spr = _hspr;
        _img = min(floor(_elapsed * ANIM_ENEMY_HIT_SPRITE_SPEED), sprite_get_number(_spr) - 1);
        _ox += (_ax - (sprite_get_width(_spr)  / 2 - sprite_get_xoffset(_spr)) * image_xscale) - x;
        _oy  = (_ay - (sprite_get_height(_spr)     - sprite_get_yoffset(_spr)) * image_yscale) - y;
    } else if ((_elapsed div ANIM_ENEMY_HIT_FLASH_FRAMES) mod 2 == 0) {
        _blend = c_red;   // piscada vermelha alternada
    }
}

draw_sprite_ext(_spr, _img, x + _ox, y + _oy, image_xscale, image_yscale, image_angle, _blend, image_alpha);

// ── MINI BARRA DE VIDA HORIZONTAL ACIMA DO INIMIGO ────────────────
// Fica 10 px acima do topo do sprite (já com a escala do inimigo aplicada),
// centralizada nele. O HP é o do controller; a barra do jogador continua no HUD.
if (instance_exists(obj_rh_battle_controller)) {
    var _ctrl = obj_rh_battle_controller;
    if (_ctrl.enemy_max_hp > 0) {
        var _pct  = clamp(_ctrl.enemy_hp / _ctrl.enemy_max_hp, 0, 1);
        var _bw   = 64;
        var _bh   = 6;
        var _cx   = x + (sprite_get_width(sprite_index) / 2 - sprite_get_xoffset(sprite_index)) * image_xscale;
        var _topo = y - sprite_get_yoffset(sprite_index) * image_yscale;
        var _bx   = round(_cx - _bw / 2);
        var _by   = round(_topo - 12);

        draw_set_color(c_black);
        draw_rectangle(_bx - 1, _by - 1, _bx + _bw + 1, _by + _bh + 1, false);
        draw_set_color(make_color_rgb(45, 45, 45));
        draw_rectangle(_bx, _by, _bx + _bw, _by + _bh, false);

        if (_pct > 0) {
            if (_pct > 0.5)       draw_set_color(make_color_rgb(255, 220, 60));
            else if (_pct > 0.25) draw_set_color(make_color_rgb(255, 140, 0));
            else                  draw_set_color(make_color_rgb(255, 40, 40));
            var _larg = max(1, round((_bw - 2) * _pct));
            draw_rectangle(_bx + 1, _by + 1, _bx + 1 + _larg, _by + _bh - 1, false);
        }
        draw_set_color(c_white);
    }
}
