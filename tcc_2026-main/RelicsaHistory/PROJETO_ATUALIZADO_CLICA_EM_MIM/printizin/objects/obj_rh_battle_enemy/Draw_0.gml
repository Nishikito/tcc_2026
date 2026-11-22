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
