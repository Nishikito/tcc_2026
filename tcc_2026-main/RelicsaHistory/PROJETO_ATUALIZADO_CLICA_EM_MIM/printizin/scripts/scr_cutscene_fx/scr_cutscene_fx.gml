/// Ações extras de cutscene: andar do player, tremida da câmera e escuridão com foco de luz.
/// Rodam dentro do obj_cutscene (por isso usam action_started, timer, shake_on, dark_alpha...).

// Anda o player até (_tx, _ty) em "L" ("X_FIRST" = primeiro na horizontal; qualquer outro = primeiro na vertical)
// e anima as pernas. Parecida com cutscene_move_axis, mas não usa o rastro da party (pos_history),
// que o ObjPlayer atual não tem.
function cutscene_walk_player(_tx, _ty, _spd, _order) {
    if (!instance_exists(ObjPlayer)) return true;

    var _p = ObjPlayer;
    var _go_x = false, _go_y = false;

    if (_order == "X_FIRST") {
        if (_p.x != _tx) _go_x = true; else if (_p.y != _ty) _go_y = true;
    } else {
        if (_p.y != _ty) _go_y = true; else if (_p.x != _tx) _go_x = true;
    }

    if (_go_x) {
        var _sx = sign(_tx - _p.x);
        _p.x += _sx * min(_spd, abs(_tx - _p.x));
        cutscene_set_dir(_p, (_sx > 0) ? RIGHT : LEFT);
    } else if (_go_y) {
        var _sy = sign(_ty - _p.y);
        _p.y += _sy * min(_spd, abs(_ty - _p.y));
        cutscene_set_dir(_p, (_sy > 0) ? DOWN : UP);
    }

    var _moving = (_go_x || _go_y);
    var _mult = max(0.5, _spd / _p.default_spd);   // mesma proporção do andar normal

    // A animação é posta "na mão" a cada frame (o Step do ObjPlayer zera o image_index enquanto trava)
    with (_p) {
        image_speed = 0;
        if (_moving) {
            var _fps = sprite_get_speed(sprite_index);
            if (sprite_get_speed_type(sprite_index) == spritespeed_framespersecond) _fps /= game_get_speed(gamespeed_fps);
            if (!variable_instance_exists(id, "cs_walk_anim")) cs_walk_anim = 0;
            cs_walk_anim += _fps * _mult;
            image_index = cs_walk_anim mod sprite_get_number(sprite_index);
        } else {
            image_index = 0;
        }
    }
    return !_moving;
}

// ---------- tremida da câmera (NÃO trava a cena: continua tremendo durante diálogos e esperas) ----------
// _strength = força em pixels. Chame de novo com outro valor pra aumentar/diminuir.
function cutscene_shake_start(_strength) {
    shake_on  = true;
    shake_str = _strength;
    return true;
}

function cutscene_shake_stop() {
    shake_on  = false;
    shake_str = 0;
    return true;
}

// ---------- escuridão ----------
// Escurece a tela em _frames frames até _alpha_to (0 a 1). Fica só um "foco de luz" em volta do player,
// que fecha de _r_from até _r_to pixels de raio.
function cutscene_dark_in(_frames, _r_from, _r_to, _alpha_to) {
    if (!action_started) {
        action_started = true;
        timer  = 0;
        fx_a0  = dark_alpha;
        fx_r0  = _r_from;
    }
    timer++;
    var _t = clamp(timer / _frames, 0, 1);
    var _e = _t * _t * (3 - 2 * _t);   // começa e termina suave
    dark_alpha  = lerp(fx_a0, _alpha_to, _e);
    dark_radius = lerp(fx_r0, _r_to, _e);
    return (_t >= 1);
}

// Termina de apagar tudo: o foco de luz fecha e a tela fica 100% preta.
function cutscene_dark_to_black(_frames) {
    if (!action_started) {
        action_started = true;
        timer  = 0;
        fx_a0  = dark_alpha;
        fx_r0  = dark_radius;
    }
    timer++;
    var _t = clamp(timer / _frames, 0, 1);
    dark_alpha  = lerp(fx_a0, 1, _t);
    dark_radius = lerp(fx_r0, 0, _t);
    return (_t >= 1);
}

// Clareia a tela de volta (se a cena não for mudar de room)
function cutscene_dark_out(_frames) {
    if (!action_started) {
        action_started = true;
        timer  = 0;
        fx_a0  = dark_alpha;
    }
    timer++;
    var _t = clamp(timer / _frames, 0, 1);
    dark_alpha = lerp(fx_a0, 0, _t);
    return (_t >= 1);
}
