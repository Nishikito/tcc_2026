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

    if (array_length(follow_trail) > PARTY_FOLLOW_DELAY) {
        var _p  = follow_trail[0];
        array_delete(follow_trail, 0, 1);
        var _dx = _p[0] - x, _dy = _p[1] - y;
        if (abs(_dx) > abs(_dy)) follow_dir = (_dx > 0) ? RIGHT : LEFT;
        else if (_dy != 0)       follow_dir = (_dy > 0) ? DOWN  : UP;
        x = _p[0];
        y = _p[1];
        sprite_index = sprite[follow_dir];
        image_speed  = 1;
    } else {
        image_speed = 0;
        image_index = 0;
    }
    depth = -bbox_bottom;
}
