// ---------- helpers ----------
function cutscene_set_dir(_inst, _dir) {
    with (_inst) {
        face = _dir;
        if (variable_instance_exists(id, "sprite")) sprite_index = sprite[_dir];
    }
}

// ---------- player ----------
function cutscene_player_lock() {
    global.dialog_active = true;
    if (instance_exists(ObjPlayer)) { ObjPlayer.image_speed = 0; ObjPlayer.image_index = 0; }
    return true;
}

function cutscene_player_unlock() {
    global.dialog_active = false;
    if (instance_exists(ObjPlayer)) ObjPlayer.image_speed = 1;
    return true;
}

function cutscene_fade_to_room(_room, _x, _y, _next_scene) {
    if (!action_started) {
        action_started = true;
        global.dialog_active = false;
        global.fade_active = true;
        global.pending_scene = _next_scene;
        var _f = instance_create_depth(0, 0, -99999, obj_fade);
        _f.target_x = _x;
        _f.target_y = _y;
        _f.target_room = _room;
    }
    return false;
}

// Trava a câmera centralizada onde o player está (o ponto de pouso)
function cutscene_camera_freeze() {
    var _cam = view_camera[0];
    camera_set_view_target(_cam, noone);
    var _w = camera_get_view_width(_cam), _h = camera_get_view_height(_cam);
    camera_set_view_pos(_cam,
        clamp(ObjPlayer.x - _w / 2, 0, max(0, room_width  - _w)),
        clamp(ObjPlayer.y - _h / 2, 0, max(0, room_height - _h)));
    return true;
}

// Câmera volta a seguir o player
function cutscene_camera_follow_player() {
    camera_set_view_target(view_camera[0], ObjPlayer);
    return true;
}

// O player cai de cima da tela até a posição em que está agora (_grav = aceleração)
function cutscene_player_fall(_grav) {
    if (!action_started) {
        action_started = true;
        target_y = ObjPlayer.y;                                  // onde vai pousar
        ObjPlayer.y = camera_get_view_y(view_camera[0]) - 30;    // começa acima da tela
        timer = 0;                                               // velocidade de queda
        cutscene_set_dir(ObjPlayer, DOWN);
        ObjPlayer.image_speed = 0;
        ObjPlayer.image_index = 0;
    }
    timer += _grav;
    ObjPlayer.y = min(ObjPlayer.y + timer, target_y);
    return (ObjPlayer.y >= target_y);
}

// ---------- tempo e diálogo ----------
function cutscene_wait(_frames) {
    if (!action_started) { action_started = true; timer = _frames; }
    timer--;
    if (timer <= 0) { action_started = false; return true; }
    return false;
}

function cutscene_dialogue(_text_id) {
    if (!action_started) {
        action_started = true;
        create_textbox(_text_id);
    }
    if (!instance_exists(obj_textbox)) { action_started = false; return true; }
    return false;
}

// ---------- movimento em "L" (agora vira o sprite pela direção) ----------
function cutscene_move_axis(_inst, _tx, _ty, _spd, _order) {
    if (!instance_exists(_inst)) return true;

    var _x = _inst.x, _y = _inst.y;
    var _go_x = false, _go_y = false;

    if (_order == "X_FIRST") {
        if (_x != _tx) _go_x = true; else if (_y != _ty) _go_y = true;
    } else {
        if (_y != _ty) _go_y = true; else if (_x != _tx) _go_x = true;
    }

    if (_go_x) {
        var _s = sign(_tx - _x);
        _inst.x += _s * min(_spd, abs(_tx - _x));
        cutscene_set_dir(_inst, (_s > 0) ? RIGHT : LEFT);
    } else if (_go_y) {
        var _s = sign(_ty - _y);
        _inst.y += _s * min(_spd, abs(_ty - _y));
        cutscene_set_dir(_inst, (_s > 0) ? DOWN : UP);
    }

    if (_go_x || _go_y) {
        // andando: o player anima na velocidade proporcional ao movimento (mínimo 0.5), os NPCs na normal
        _inst.image_speed = (_inst.object_index == ObjPlayer) ? max(0.5, _spd / _inst.default_spd) : 1;

        // se for o player, grava o rastro pra party seguir
        if (_inst.object_index == ObjPlayer) array_push(ObjPlayer.pos_history, { x: ObjPlayer.x, y: ObjPlayer.y });
        return false;
    }

    // chegou: para a animação no frame parado
    _inst.image_speed = 0;
    _inst.image_index = 0;
    return true;
}

function cutscene_move_to_player_front(_npc, _dist, _spd, _order) {
    if (!instance_exists(_npc) || !instance_exists(ObjPlayer)) return true;
    if (!action_started) {
        action_started = true;
        target_x = ObjPlayer.x; target_y = ObjPlayer.y;
        switch (ObjPlayer.face) {
            case RIGHT: target_x += _dist; break;
            case LEFT:  target_x -= _dist; break;
            case UP:    target_y -= _dist; break;
            case DOWN:  target_y += _dist; break;
        }
    }
    var _done = cutscene_move_axis(_npc, target_x, target_y, _spd, _order);
    if (_done) cutscene_face_player(_npc);
    return _done;
}

// Treme a câmera por _frames frames (_strength = força em pixels). Depois volta tudo como estava.
function cutscene_screen_shake(_frames, _strength) {
    var _cam = view_camera[0];
    if (!action_started) {
        action_started = true;
        timer = _frames;
        target_x = camera_get_view_x(_cam);          // posição base da câmera
        target_y = camera_get_view_y(_cam);
        shake_target = camera_get_view_target(_cam); // guarda quem a câmera seguia
        camera_set_view_target(_cam, noone);         // solta a câmera pra poder tremer
    }
    timer--;
    if (timer > 0) {
        camera_set_view_pos(_cam,
            target_x + irandom_range(-_strength, _strength),
            target_y + irandom_range(-_strength, _strength));
        return false;
    }
    camera_set_view_pos(_cam, target_x, target_y);
    camera_set_view_target(_cam, shake_target);      // volta a seguir como antes
    return true;
}

// Troca de room NA HORA (sem fade) e deixa uma cutscene pra rodar na room nova
function cutscene_goto_room(_room, _x, _y, _next_scene) {
    global.pending_scene = _next_scene;
    ObjPlayer.x = _x;
    ObjPlayer.y = _y;
    room_goto(_room);
    return true;
}

// O player cai pra fora da tela (a câmera NÃO acompanha) e a ação termina quando ele sai de vista
function cutscene_player_fall_out(_grav) {
    var _cam = view_camera[0];
    if (!action_started) {
        action_started = true;
        timer = 0;                                   // velocidade de queda
        cutscene_set_dir(ObjPlayer, DOWN);
    }
    timer += _grav;
    ObjPlayer.y += timer;
    return (ObjPlayer.y > camera_get_view_y(_cam) + camera_get_view_height(_cam) + 40);
}

function cutscene_move_to_player_back(_npc, _dist, _spd, _order) {
    if (!instance_exists(_npc) || !instance_exists(ObjPlayer)) return true;
    if (!action_started) {
        action_started = true;
        target_x = ObjPlayer.x; target_y = ObjPlayer.y;
        switch (ObjPlayer.face) {
            case RIGHT: target_x -= _dist; break;
            case LEFT:  target_x += _dist; break;
            case UP:    target_y += _dist; break;
            case DOWN:  target_y -= _dist; break;
        }
    }
    return cutscene_move_axis(_npc, target_x, target_y, _spd, _order);
}

// ---------- sprite / direção ----------
function cutscene_change_sprite(_inst, _sprite) {
    if (instance_exists(_inst)) _inst.sprite_index = _sprite;
    return true;
}

function cutscene_face_dir(_inst, _dir) {   // _dir = RIGHT / LEFT / UP / DOWN
    if (instance_exists(_inst)) cutscene_set_dir(_inst, _dir);
    return true;
}

function cutscene_face_player(_npc) {
    if (!instance_exists(_npc) || !instance_exists(ObjPlayer)) return true;
    var _dx = ObjPlayer.x - _npc.x, _dy = ObjPlayer.y - _npc.y;
    var _d = (abs(_dx) > abs(_dy)) ? ((_dx > 0) ? RIGHT : LEFT) : ((_dy > 0) ? DOWN : UP);
    cutscene_set_dir(_npc, _d);
    return true;
}

// ---------- instâncias e flags ----------
function cutscene_create_instance(_x, _y, _obj) {
    instance_create_depth(_x, _y, 0, _obj);
    return true;
}

function cutscene_destroy_instance(_obj) {
    if (instance_exists(_obj)) instance_destroy(_obj);
    return true;
}

function cutscene_set_flag(_name, _value) {
    variable_global_set(_name, _value);
    return true;
}

// ---------- party ----------
function cutscene_start_following(_obj) {
    if (instance_exists(_obj) && instance_exists(ObjPlayer)) party_begin_follow(_obj);
    return true;
}

// Pausa o seguir (mantém o lugar na party). Use antes de mover um seguidor numa cena.
function cutscene_stop_following(_obj) {
    if (instance_exists(_obj)) {
        _obj.is_following = false;
        _obj.image_speed = 0;
        _obj.image_index = 0;
    }
    return true;
}

// Sai da party de vez
function cutscene_leave_party(_obj) {
    if (instance_exists(_obj)) { _obj.is_following = false; party_remove(_obj.object_index); }
    return true;
}

// igual ao cutscene_fade_to_room, mas a tela fica preta um tempo e clareia bem devagar
function cutscene_fade_to_room_slow(_room, _x, _y, _next_scene) {
    if (!action_started) {
        action_started = true;
        global.dialog_active = false;
        global.fade_active = true;
        global.pending_scene = _next_scene;
        var _f = instance_create_depth(0, 0, -99999, obj_fade);
        _f.target_x = _x;
        _f.target_y = _y;
        _f.target_room = _room;
        _f.fade_in_spd = 0.05;   // ~3s pra clarear (padrão é 0.5)
        _f.fade_hold   = 90;     // 1,5s de tela preta antes de clarear
    }
    return false;
}

// deita o player no chão (sprite caído) / levanta de volta
// o 10 alinha o chão: em pé o pé fica 21px abaixo do y, deitado o sprite tem 31px a partir do y
function cutscene_lie_down(_inst) {
    if (instance_exists(_inst)) {
        _inst.sprite_index = SprPlayerDown;
        _inst.image_index = 0;
        _inst.image_speed = 0;
        _inst.y -= 10;
    }
    return true;
}
function cutscene_stand_up(_inst) {
    if (instance_exists(_inst)) {
        _inst.y += 10;
        cutscene_set_dir(_inst, DOWN);
    }
    return true;
}

// treme o personagem por _frames frames (força _s em pixels) e depois volta pro lugar
function cutscene_shake_inst(_inst, _frames, _s) {
    if (!instance_exists(_inst)) return true;
    if (!action_started) { action_started = true; timer = _frames; target_x = _inst.x; target_y = _inst.y; }
    timer--;
    if (timer > 0) {
        _inst.x = target_x + irandom_range(-_s, _s);
        return false;
    }
    _inst.x = target_x;
    _inst.y = target_y;
    action_started = false;
    return true;
}

// move a câmera suavemente até centralizar em (_x, _y)
function cutscene_camera_pan(_x, _y, _frames) {
    var _cam = view_camera[0];
    var _w = camera_get_view_width(_cam), _h = camera_get_view_height(_cam);
    if (!action_started) {
        action_started = true;
        camera_set_view_target(_cam, noone);
        target_x = camera_get_view_x(_cam);
        target_y = camera_get_view_y(_cam);
        timer = 0;
    }
    timer++;
    var _t = clamp(timer / _frames, 0, 1);
    var _e = _t * _t * (3 - 2 * _t);   // começa e termina suave
    var _dx = clamp(_x - _w / 2, 0, max(0, room_width  - _w));
    var _dy = clamp(_y - _h / 2, 0, max(0, room_height - _h));
    camera_set_view_pos(_cam, round(lerp(target_x, _dx, _e)), round(lerp(target_y, _dy, _e)));
    if (_t >= 1) { action_started = false; return true; }
    return false;
}

function cutscene_set_visible(_inst, _vis) {
    if (instance_exists(_inst)) _inst.visible = _vis;
    return true;
}

// explosão centralizada em (_x, _y), por cima de tudo
function cutscene_explode(_x, _y) {
    // objExplosion ainda não existe no projeto: sem ele a cena segue sem a explosão
    var _expl = asset_get_index("objExplosion");
    if (_expl != -1) instance_create_depth(_x, _y, -9999, _expl);
    return true;
}
// tira o Charles da party e do mapa (pra cena poder criá-lo do zero)
function cutscene_reset_charles() {
    party_remove(ObjJanitor);
    if (instance_exists(ObjJanitor)) instance_destroy(ObjJanitor);
    return true;
}

// cria o Charles em (_x, _y), parado (ele ainda não segue)
function cutscene_spawn_charles(_x, _y) {
    party_remove(ObjJanitor);
    if (instance_exists(ObjJanitor)) instance_destroy(ObjJanitor);
    instance_create_depth(_x, _y, 0, ObjJanitor);
    return true;
}
function cutscene_wait_fade() {
    return !instance_exists(obj_fade);
}