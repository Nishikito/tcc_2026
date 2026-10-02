// Desenha o inimigo. Substitui o draw_self automático para poder aplicar a
// reação de dano (tremida + piscada vermelha, ou o sprite do SLOT de dano).
// Tudo controlado por hit_timer / hit_duration (ligados pelo controller).
var _spr   = sprite_index;
var _img   = image_index;
var _ox    = 0;
var _blend = c_white;

if (hit_timer > 0) {
    var _elapsed = hit_duration - hit_timer;   // frames desde o início da reação
    var _fade    = hit_timer / hit_duration;   // 1 → 0: a tremida enfraquece

    _ox = dsin(_elapsed * 90) * ANIM_ENEMY_HIT_SHAKE_PIXELS * _fade;

    if (ANIM_SLOT_ENEMY_HIT_SPRITE != noone) {
        // SLOT preenchido: usa o sprite de dano (sem loop: trava no último frame)
        _spr = ANIM_SLOT_ENEMY_HIT_SPRITE;
        _img = min(floor(_elapsed * ANIM_ENEMY_HIT_SPRITE_SPEED), sprite_get_number(_spr) - 1);
    } else if ((_elapsed div ANIM_ENEMY_HIT_FLASH_FRAMES) mod 2 == 0) {
        _blend = c_red;   // piscada vermelha alternada
    }
}

draw_sprite_ext(_spr, _img, x + _ox, y, image_xscale, image_yscale, image_angle, _blend, image_alpha);

