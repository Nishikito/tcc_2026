if (!instance_exists(obj_rh_battle_controller)) exit;
var _ctrl = obj_rh_battle_controller;

// Sem caixa na sala: coração escondido
if (!instance_exists(obj_rh_battle_box)) { visible = false; exit; }
var _box = obj_rh_battle_box;

// Centro da caixa (onde o coração nasce a cada turno)
var _cx = _box.x + sprite_get_width(_box.sprite_index)  / 2;
var _cy = _box.y + sprite_get_height(_box.sprite_index) / 2;

// O coração só aparece junto com a caixa, com fade-in na segunda metade da abertura
visible     = (_box.anim > 0);
image_alpha = clamp((_box.anim - 0.5) * 2, 0, 1);

// Caixa fechada: coração volta ao centro, pronto para o próximo turno
if (_box.anim <= 0) {
    x = _cx;
    y = _cy;
}

// Só se move e leva dano no turno do inimigo, com a caixa TOTALMENTE aberta
if (_ctrl.state == BATTLE_STATE.ENEMY_TURN && _box.is_open) {

    var _xspd = (keyboard_check(global.key_right) - keyboard_check(global.key_left)) * move_spd;
    var _yspd = (keyboard_check(global.key_down)  - keyboard_check(global.key_up))   * move_spd;

    // Fallback setas físicas
    if (_xspd == 0 && _yspd == 0) {
        _xspd = (keyboard_check(vk_right) - keyboard_check(vk_left)) * move_spd;
        _yspd = (keyboard_check(vk_down)  - keyboard_check(vk_up))   * move_spd;
    }

    // Parte de DENTRO da caixa (sem a linha da borda)
    var _ix1 = _box.x + BOX_BORDER_PIXELS;
    var _ix2 = _box.x + sprite_get_width(_box.sprite_index)  - BOX_BORDER_PIXELS;
    var _iy1 = _box.y + BOX_BORDER_PIXELS;
    var _iy2 = _box.y + sprite_get_height(_box.sprite_index) - BOX_BORDER_PIXELS;

    // Metade do tamanho REAL do coração (com a escala)
    var _hw = sprite_get_width(sprite_index)  * abs(image_xscale) / 2;
    var _hh = sprite_get_height(sprite_index) * abs(image_yscale) / 2;

    x = clamp(x + _xspd, _ix1 + _hw, _ix2 - _hw);
    y = clamp(y + _yspd, _iy1 + _hh, _iy2 - _hh);

    // Dano dos ataques — UMA colisão = UM dano.
    // instance_place_list devolve TODOS os ataques tocando o coração; só o primeiro ATIVO conta
    // (um por frame). O ataque acertado é desativado NA HORA (active = false): mesmo que continue
    // visível (martelo, bota...) não pode causar dano de novo. Se destroy_on_hit, ele também some.
    // dmg_mult deixa golpes grandes machucarem mais (1 = dano normal da bala).
    var _hits = ds_list_create();
    var _n    = instance_place_list(x, y, obj_rh_battle_bullet, _hits, false);
    for (var _i = 0; _i < _n; _i++) {
        var _b = _hits[| _i];
        if (!_b.active) continue;

        var _dmg = max(1, round(calculate_enemy_damage() * _b.dmg_mult));   // sorteado UMA vez por ataque
        apply_damage_to_player(_dmg);
        _ctrl.talai_hit_timer = ANIM_TALAI_HIT_DURATION;   // Talai mostra o sprite de dano

        with (_b) {
            active = false;
            if (destroy_on_hit) instance_destroy();
        }
        break;   // só um acerto por frame
    }
    ds_list_destroy(_hits);
}
