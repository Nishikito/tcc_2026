// ══════════════════════════════════════════════════════════════════
// PARTY — seguidores que andam atrás do Talai (ex.: o Charles / ObjJanitor)
// ──────────────────────────────────────────────────────────────────
// Funções usadas pelas cutscenes (scr_cutscene_actions), por scr_cena_janitor e pelo
// ObjJanitor. A party é uma lista GLOBAL de OBJETOS (não de instâncias), então sobrevive à
// troca de sala. Quem segue precisa ter, no Create, as variáveis criadas por party_npc_init().
// ══════════════════════════════════════════════════════════════════

#macro PARTY_FOLLOW_DELAY  14   // quantos passos do player o seguidor fica atrás. MAIOR = mais longe

function party_list() {
    if (!variable_global_exists("party_members")) global.party_members = [];
    return global.party_members;
}

/// O objeto (índice de objeto) está na party?
function party_has(_obj) {
    var _l = party_list();
    for (var i = 0; i < array_length(_l); i++) {
        if (_l[i] == _obj) return true;
    }
    return false;
}

/// Tira o objeto da party e faz as instâncias dele pararem de seguir.
function party_remove(_obj) {
    var _l = party_list();
    for (var i = array_length(_l) - 1; i >= 0; i--) {
        if (_l[i] == _obj) array_delete(_l, i, 1);
    }
    with (_obj) {
        is_following = false;
    }
}

/// Chamada no Create do seguidor. Devolve false se a instância foi destruída (já existe outra).
function party_npc_init() {
    // só pode haver uma instância de cada membro
    if (instance_number(object_index) > 1) {
        instance_destroy();
        return false;
    }
    is_following    = false;
    follow_trail    = [];
    follow_last_px  = 0;
    follow_last_py  = 0;
    follow_dir      = DOWN;
    // se já está na party (voltou de outra sala), continua seguindo
    if (party_has(object_index) && instance_exists(ObjPlayer)) {
        party_begin_follow(id);
    }
    return true;
}

/// Começa a seguir o player (entra na party).
function party_begin_follow(_inst) {
    if (!instance_exists(_inst) || !instance_exists(ObjPlayer)) return false;
    if (!party_has(_inst.object_index)) array_push(party_list(), _inst.object_index);
    with (_inst) {
        is_following   = true;
        follow_trail   = [];
        follow_last_px = ObjPlayer.x;
        follow_last_py = ObjPlayer.y;
    }
    return true;
}

/// Mesma regra de direção usada pelo Talai (ObjPlayer/Step_0):
///   - vertical sozinho  -> UP/DOWN
///   - horizontal sozinho -> LEFT/RIGHT
///   - na diagonal, o HORIZONTAL manda e o vertical só corrige quando ele parou.
/// Antes o seguidor comparava abs(dx) > abs(dy); na diagonal os dois são quase
/// iguais e o sprite alternava a cada frame (flicker).
function follower_face_update(_dx, _dy) {
    if (_dy == 0) {
        if (_dx > 0) follow_dir = RIGHT;
        if (_dx < 0) follow_dir = LEFT;
    }
    if (_dx > 0 && follow_dir == LEFT)  follow_dir = RIGHT;
    if (_dx < 0 && follow_dir == RIGHT) follow_dir = LEFT;
    if (_dx == 0) {
        if (_dy > 0) follow_dir = DOWN;
        if (_dy < 0) follow_dir = UP;
    }
    if (_dy > 0 && follow_dir == UP)   follow_dir = DOWN;
    if (_dy < 0 && follow_dir == DOWN) follow_dir = UP;
}

/// Chamada TODO frame no Step Final (Step_2) do seguidor, depois do player andar.
function party_follower_step() {
    if (!instance_exists(ObjPlayer)) return;
    if (global.dialog_active || global.cutscene_active) return;

    var _px = ObjPlayer.x, _py = ObjPlayer.y;

    // só grava o rastro quando o player se mexeu
    if (_px != follow_last_px || _py != follow_last_py) {
        array_push(follow_trail, [_px, _py]);
        follow_last_px = _px;
        follow_last_py = _py;
    }

    var _moved = false;
    if (array_length(follow_trail) > PARTY_FOLLOW_DELAY) {
        var _p  = follow_trail[0];
        array_delete(follow_trail, 0, 1);
        var _dx = _p[0] - x, _dy = _p[1] - y;

        // Usa o MESMO input do Talai (xspd/yspd) para escolher o sprite. Se o
        // player já parou, aproveita o último passo do rastro para terminar a animação.
        var _ix = ObjPlayer.xspd, _iy = ObjPlayer.yspd;
        if (_ix == 0 && _iy == 0) { _ix = _dx; _iy = _dy; }
        follower_face_update(_ix, _iy);

        x = _p[0];
        y = _p[1];
        sprite_index = sprite[follow_dir];
        _moved = (_dx != 0 || _dy != 0);
    }
    if (_moved) {
        image_speed = 1;
    } else {
        image_speed = 0;
        image_index = 0;
    }
    depth = -bbox_bottom;
}

// ══════════════════════════════════════════════════════════════════
// COMPANION RASIEL / RODAPÉ
// ──────────────────────────────────────────────────────────────────
// Criação centralizada: chamada pelo Room Start do ObjPlayer E pelo retorno de
// batalha no obj_settings. O player recriado após uma luta NÃO dispara Room Start,
// então, sem esta função, o Rodapé sumia até o jogador trocar de sala.
// Usa um obj_speakblock existente como "corpo": o IDE reescreve o .yyp e descarta
// objetos novos, então nenhum resource novo é criado aqui.
function companion_ensure_spawn() {
    if (!variable_global_exists("companion_inst"))    global.companion_inst    = noone;
    if (!variable_global_exists("rodape_intro_done")) global.rodape_intro_done = false;

    var _companion_room = (room == rm_inicio || room_is_story_world(room));
    if (!_companion_room) {
        if (instance_exists(global.companion_inst)) instance_destroy(global.companion_inst);
        global.companion_inst = noone;
        return false;
    }

    // Já existe (ex.: voltou de batalha com o speakblock preservado): não duplica.
    if (instance_exists(global.companion_inst)) return true;
    if (!instance_exists(ObjPlayer)) return false;

    var _px = ObjPlayer.x, _py = ObjPlayer.y;
    var _c = instance_create_depth(_px - 24, _py, -ObjPlayer.bbox_bottom, obj_speakblock);
    with (_c) {
        // Visual do Rodapé/Rasiel (o speakblock é invisível por padrão).
        sprite_index = spr_companionB;
        mask_index   = spr_companionB;
        visible      = true;
        image_speed  = 0;
        image_index  = 0;
        depth        = -bbox_bottom;
        // O Step do speakblock já abre esta fala com ENTER.
        text_id = "rasiel_conversa";

        // Variáveis exigidas pelo scr_party (mesmo rastro do Charles).
        // is_following começa false: a conversa de apresentação vem primeiro.
        is_following    = false;
        follow_trail    = [];
        follow_last_px  = _px;
        follow_last_py  = _py;
        follow_dir      = DOWN;
        sprite[DOWN]    = spr_companionB;
        sprite[UP]      = spr_companionC;
        sprite[RIGHT]   = spr_companionD;
        sprite[LEFT]    = spr_companionE;
    }
    global.companion_inst = _c;

    // Apresentação exclusiva de rm_inicio e UMA ÚNICA VEZ (flag salva no jogo).
    if (!global.rodape_intro_done && room == rm_inicio) {
        global.rodape_intro_done = true;
        // Depois da última página, obj_textbox dispara "rodape_join_party".
        global.after_dialog_action = "rodape_join_party";
        create_textbox("rodape_intro");
        global.dialog_active = true;
    } else {
        // Já apresentado — ou sala posterior: segue junto sem repetir a conversa.
        party_begin_follow(_c);
    }
    return true;
}
