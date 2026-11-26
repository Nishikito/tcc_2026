if (!instance_exists(obj_rh_battle_controller)) exit;
var _ctrl = obj_rh_battle_controller;

// Os iframes contam mesmo se a caixa fechar no meio deles.
if (iframe_timer > 0) iframe_timer--;

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
    kb_x = 0; kb_y = 0; kb_time = 0; kb_flash = 0;
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

    // EMPURRÃO: somado à entrada do jogador, com atrito; sempre clampado na caixa.
    var _mvx = _xspd + kb_x;
    var _mvy = _yspd + kb_y;
    x = clamp(x + _mvx, _ix1 + _hw, _ix2 - _hw);
    y = clamp(y + _mvy, _iy1 + _hh, _iy2 - _hh);
    kb_x *= 0.82;
    kb_y *= 0.82;
    if (kb_time > 0) kb_time--;
    if (kb_time <= 0) { kb_x = 0; kb_y = 0; }
    if (kb_flash > 0) kb_flash--;

    // Dano dos ataques — UMA colisão = UM dano.
    // instance_place_list devolve TODOS os ataques tocando o coração; só o primeiro ATIVO conta.
    // Durante os iframes o coração atravessa os ataques: eles não machucam nem são consumidos.
    if (iframe_timer <= 0) {
        var _hits = ds_list_create();
        var _n    = instance_place_list(x, y, obj_rh_battle_bullet, _hits, false);
        for (var _i = 0; _i < _n; _i++) {
            var _b = _hits[| _i];
            if (!_b.active) continue;

            var _dmg = max(1, round(calculate_enemy_damage() * _b.dmg_mult));
            apply_damage_to_player(_dmg);
            iframe_timer = iframe_max;   // 1 segundo sem novos acertos
            _ctrl.talai_hit_timer = ANIM_TALAI_HIT_DURATION;
            rh_debug("ACERTO por " + object_get_name(_b.object_index)
                     + " | dano " + string(_dmg) + " | iframes " + string(iframe_max));

            // Empurrão para trás: a direção da investida afasta o coração do juiz.
            if (_b.kb_power > 0) {
                kb_x     = lengthdir_x(_b.kb_power, _b.kb_dir);
                kb_y     = lengthdir_y(_b.kb_power, _b.kb_dir);
                kb_time  = 12;
                kb_flash = 10;
            }

            with (_b) {
                active  = false;
                was_hit = true;   // zonas e raios respeitam isto (single-hit)
                if (destroy_on_hit) {
                    rh_debug_destroy("acerto no coração");
                    instance_destroy();
                }
            }
            break;   // só um acerto por frame
        }
        ds_list_destroy(_hits);
    }

    // O antigo laser foi substituído por 5 balas de canhão: elas usam a colisão normal acima.
}
