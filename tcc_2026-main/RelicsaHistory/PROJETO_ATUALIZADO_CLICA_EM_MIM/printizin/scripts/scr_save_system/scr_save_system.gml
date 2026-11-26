// Este script só LÊ e ESCREVE arquivos e aplica os dados nas variáveis globais.
// A interface (slots, copiar, apagar, "Jogo salvo!") fica em obj_save_slots.
//
// O que um save guarda:
//   HP, inventário (4 categorias), itens do cenário já coletados, média de conhecimento,
//   inimigos derrotados, sala + posição + direção do Talai, tempo de jogo,
//   nome do local e data/hora do save.
// ══════════════════════════════════════════════════════════════════

#macro SAVE_SLOT_COUNT   3                  // quantidade de slots
#macro SAVE_FILE_PREFIX  "relicsa_save_"    // nome do arquivo: relicsa_save_1.json, _2, _3
#macro SAVE_FILE_EXT     ".json"
#macro SAVE_VERSION      1                  // aumente se mudar o formato do save
#macro SAVE_HEAL_ON_SAVE true               // true = salvar CURA o Talai totalmente


// ── Variáveis globais EXTRAS que também entram no save ────────────
// Flags de progresso da história (ex.: "carol_disappeared"). Escreva o NOME da variável
// global, entre aspas. Só nomes listados aqui são gravados e restaurados.
function save_extra_globals() {
    // rodape_intro_done: sem isto a apresentação do companion repetia ao carregar.
    // savepoint_intro_done: mesma coisa para a fala da estrela amarela.
    return ["carol_disappeared", "rodape_intro_done", "savepoint_intro_done",
            "overworld_music_finished"];
}


// Inimigo derrotado? Usado para não repetir o encontro (ex.: guaraná do rm_inicio)
// mesmo em saves antigos que ainda não tinham o campo scenes_done.
function save_enemy_defeated(_id) {
    if (!variable_global_exists("defeated_enemies")) global.defeated_enemies = [];
    for (var i = 0; i < array_length(global.defeated_enemies); i++) {
        if (global.defeated_enemies[i] == _id) return true;
    }
    return false;
}


// ── Nomes de arquivo e existência ─────────────────────────────────
// _slot vai de 0 a SAVE_SLOT_COUNT - 1 (a tela mostra de 1 a 3)
function save_slot_filename(_slot) {
    return SAVE_FILE_PREFIX + string(_slot + 1) + SAVE_FILE_EXT;
}

function save_slot_exists(_slot) {
    return file_exists(save_slot_filename(_slot));
}


// ── Nome do local mostrado no slot ────────────────────────────────
// Ajuste os textos livremente. Salas que não estão aqui mostram o nome do asset.
function save_get_location_name(_room) {
    switch (_room) {
        case RoomClass1_1:           return "Sala de Aula";
        case RoomRefeitorio:         return "Refeitório";
        case RoomBathroom_1:         return "Banheiro";
        case RoomBathroom1_1:        return "Banheiro";
        case RoomTeachers_1:         return "Sala dos Professores";
        case RoomSalasCorredor:      return "Corredor das Salas";
        case RoomPatio:              return "Pátio";
        case rm_teste:               return "Sala de Testes";
    }
    return room_get_name(_room);
}


// ── Tempo ─────────────────────────────────────────────────────────
// segundos -> "H:MM:SS"
function save_format_time(_seconds) {
    var _t = floor(_seconds);
    var _h = _t div 3600;
    var _m = (_t mod 3600) div 60;
    var _s = _t mod 60;
    var _ms = string(_m);
    if (_m < 10) _ms = "0" + _ms;
    var _ss = string(_s);
    if (_s < 10) _ss = "0" + _ss;
    return string(_h) + ":" + _ms + ":" + _ss;
}


// ── Itens do inventário <-> dados ─────────────────────────────────
// O sprite do item é um número (índice do asset) que pode mudar entre versões do jogo,
// então no arquivo ele é gravado pelo NOME do sprite.
function save_items_to_data(_array) {
    var _out = [];
    for (var i = 0; i < array_length(_array); i++) {
        var _it = _array[i];
        var _spr_name = "";
        if (is_real(_it.sprite) && sprite_exists(_it.sprite)) {
            _spr_name = sprite_get_name(_it.sprite);
        }
        array_push(_out, {
            id:          _it.id,
            name:        _it.name,
            description: _it.description,
            sprite:      _spr_name,
            qty:         _it.qty,
            effect:      _it.effect
        });
    }
    return _out;
}

function save_items_from_data(_data) {
    var _out = [];
    for (var i = 0; i < array_length(_data); i++) {
        var _d = _data[i];
        var _spr = noone;
        if (_d.sprite != "") {
            var _idx = asset_get_index(_d.sprite);
            if (_idx >= 0) _spr = _idx;
        }
        array_push(_out, {
            id:          _d.id,
            name:        _d.name,
            description: _d.description,
            sprite:      _spr,
            qty:         _d.qty,
            effect:      _d.effect
        });
    }
    return _out;
}


// ── Montar os dados do save a partir do jogo ──────────────────────
// _snap = { x, y, face } do Talai, tirado ANTES de pausar o jogo (veja a nota em save_game).
function save_collect_data(_snap) {
    if (!variable_global_exists("defeated_enemies")) global.defeated_enemies = [];
    if (!variable_global_exists("scenes_done"))     global.scenes_done     = {};

    var _px   = _snap.x;
    var _py   = _snap.y;
    var _face = _snap.face;

    var _data = {
        version:   SAVE_VERSION,
        saved_at:  date_datetime_string(date_current_datetime()),
        room_name: room_get_name(room),
        location:  save_get_location_name(room),
        x:         _px,
        y:         _py,
        face:      _face,
        hp:        global.hp,
        max_hp:    global.max_hp,       // só informativo: o máximo vem do jogo ao carregar
        play_time: global.play_time,
        inventory: {
            relics:      save_items_to_data(global.inventory_relics),
            mission:     save_items_to_data(global.inventory_mission),
            docs:        save_items_to_data(global.inventory_docs),
            consumables: save_items_to_data(global.inventory_consumables)
        },
        itens_coletados:   global.itens_coletados,
        knowledge_scores:  global.knowledge_scores,
        knowledge_average: global.knowledge_average,
        knowledge_total:   global.knowledge_total,
        history_knowledge: global.history_knowledge,
        relics_count:      global.relics_count,
        defeated_enemies:  global.defeated_enemies,
        scenes_done:       global.scenes_done,   // cenas "once" já tocadas (guaraná, etc.)
        extra:             {}
    };

    var _extras = save_extra_globals();
    for (var i = 0; i < array_length(_extras); i++) {
        if (variable_global_exists(_extras[i])) {
            variable_struct_set(_data.extra, _extras[i], variable_global_get(_extras[i]));
        }
    }
    return _data;
}


// ── Escrever / ler arquivo ────────────────────────────────────────
// Escreve num arquivo temporário e só depois troca pelo definitivo: se o jogo fechar
// no meio da gravação, o save antigo continua inteiro.
function save_write_data(_slot, _data) {
    var _final = save_slot_filename(_slot);
    var _tmp   = _final + ".tmp";

    var _f = file_text_open_write(_tmp);
    if (_f == -1) return false;
    file_text_write_string(_f, json_stringify(_data));
    file_text_close(_f);

    if (file_exists(_final)) file_delete(_final);
    file_rename(_tmp, _final);
    return file_exists(_final);
}

// Um save é válido se tem a versão e os campos principais
function save_data_is_valid(_data) {
    if (!is_struct(_data)) return false;
    var _needed = ["version", "room_name", "x", "y", "hp", "play_time", "inventory", "location"];
    for (var i = 0; i < array_length(_needed); i++) {
        if (!variable_struct_exists(_data, _needed[i])) return false;
    }
    return true;
}

// Devolve o struct do save, ou undefined (não existe ou está corrompido)
function save_read_data(_slot) {
    var _name = save_slot_filename(_slot);
    if (!file_exists(_name)) return undefined;

    var _f = file_text_open_read(_name);
    if (_f == -1) return undefined;
    var _json = "";
    while (!file_text_eof(_f)) {
        _json += file_text_read_string(_f);
        file_text_readln(_f);
    }
    file_text_close(_f);

    var _data = undefined;
    try {
        _data = json_parse(_json);
    } catch (_e) {
        return undefined;
    }
    if (!save_data_is_valid(_data)) return undefined;
    return _data;
}

// Resumo para a tela de slots (não mexe em nada do jogo)
function save_slot_info(_slot) {
    var _info = { exists: false, valid: false, location: "", play_time: 0, hp: 0, max_hp: 0 };
    if (!save_slot_exists(_slot)) return _info;
    _info.exists = true;

    var _d = save_read_data(_slot);
    if (_d == undefined) return _info;   // existe, mas está corrompido

    _info.valid     = true;
    _info.location  = _d.location;
    _info.play_time = _d.play_time;
    _info.hp        = _d.hp;
    _info.max_hp    = _d.max_hp;
    return _info;
}


// ── Operações de slot ─────────────────────────────────────────────
function save_delete_slot(_slot) {
    var _name = save_slot_filename(_slot);
    if (file_exists(_name)) file_delete(_name);
    return !file_exists(_name);
}

// Copia o arquivo inteiro, byte a byte, de um slot para outro (sobrescreve o destino)
function save_copy_slot(_src, _dst) {
    if (_src == _dst || !save_slot_exists(_src)) return false;
    var _buf = buffer_load(save_slot_filename(_src));
    if (_buf < 0) return false;
    buffer_save(_buf, save_slot_filename(_dst));
    buffer_delete(_buf);
    return save_slot_exists(_dst);
}

// SALVAR: cura o Talai (se SAVE_HEAL_ON_SAVE) ANTES de gravar, então o save já guarda a vida cheia.
// _snap = { x, y, face } do Talai. Ele precisa ser tirado ANTES de pausar o jogo: a pausa
// (instance_deactivate_all) DESATIVA o ObjPlayer, e um objeto desativado "não existe" para
// instance_exists e não pode ter suas variáveis lidas.
function save_game(_slot, _snap) {
    if (_snap == undefined) return false;
    if (SAVE_HEAL_ON_SAVE) global.hp = global.max_hp;

    var _ok = save_write_data(_slot, save_collect_data(_snap));
    if (_ok) {
        global.save_slot = _slot;
        // Último savepoint usado: para onde o Talai volta se perder uma batalha.
        global.last_savepoint_room = room;
        global.last_savepoint_x    = _snap.x;
        global.last_savepoint_y    = _snap.y;
        global.last_savepoint_face = _snap.face;
    }
    return _ok;
}


// ── Fluxo de jogo: novo jogo e carregar ───────────────────────────
// Zera TODO o progresso (usado pelo novo jogo)
function save_reset_progress() {
    global.hp                    = global.max_hp;
    global.itens_coletados       = [];
    global.inventory_relics      = [];
    global.inventory_mission     = [];
    global.inventory_docs        = [];
    global.inventory_consumables = [];
    global.relics_count          = 0;
    global.knowledge_scores      = [];
    global.knowledge_average     = 0.0;
    global.knowledge_total       = 0;
    global.history_knowledge     = 0;
    global.defeated_enemies      = [];
    global.play_time             = 0;
    global.scenes_done           = {};     // as cenas (cutscene_trigger "once") voltam a poder tocar
    global.carol_disappeared     = false;   // a Carol volta a existir no jogo novo
    global.carol_defeated        = false;

    // Sobras de uma batalha anterior não podem vazar para o jogo novo
    global.pre_battle_hp = 0;
    global.pre_battle_x  = 0;
    global.pre_battle_y  = 0;
    global.pre_battle_face = UP;
    global.battle_return_pending = false;
    global.battle_scene_id = "";
    global.last_savepoint_room = variable_global_exists("start_room") ? global.start_room : RoomClass1_1;
    global.last_savepoint_x    = variable_global_exists("start_x") ? global.start_x : 120;
    global.last_savepoint_y    = variable_global_exists("start_y") ? global.start_y : 136;
    global.last_savepoint_face = UP;
    global.savepoint_intro_done = false;   // a fala do save point volta a valer no jogo novo
    global.rodape_intro_done    = false;   // a apresentação do Rodapé também
    global.warp_suppressed      = false;
    global.overworld_music_on       = false;
    global.overworld_music_finished = false;   // novo jogo: a música do overworld volta
    audio_stop_sound(SndCastleFunk);
}

// NOVO JOGO no slot escolhido
function save_new_game(_slot) {
    global.intro_played = false;
    save_reset_progress();
    global.save_slot = _slot;

    audio_stop_sound(sfxTitle);

    // Nenhum jogador antigo pode sobrar (o ObjPlayer novo some sozinho se já existir outro)
    if (instance_exists(ObjPlayer)) {
        with (ObjPlayer) instance_destroy();
    }
    room_goto(global.start_room);
    var _p = instance_create_layer(global.start_x, global.start_y, "Player", ObjPlayer);
    _p.face = UP;
    _p.sprite_index = _p.sprite[UP];
    global.new_game = false;
}

// CONTINUAR: lê o slot, aplica nas globais e leva o Talai ao local salvo.
// Devolve false (sem mudar nada) se o arquivo não existe, está corrompido ou a sala sumiu.
function save_load_game(_slot) {
    global.save_error = "";   // o motivo da falha, mostrado pelo menu

    var _d = save_read_data(_slot);
    if (_d == undefined) {
        global.save_error = "arquivo ilegível";
        return false;
    }

    var _room = asset_get_index(_d.room_name);
    if (_room < 0 || !room_exists(_room)) {
        global.save_error = "sala inexistente: " + string(_d.room_name);
        return false;
    }

    // HP: o máximo vem do jogo (macro/obj_settings); só o HP atual vem do save
    global.hp = clamp(_d.hp, 0, global.max_hp);

    global.inventory_relics      = save_items_from_data(_d.inventory.relics);
    global.inventory_mission     = save_items_from_data(_d.inventory.mission);
    global.inventory_docs        = save_items_from_data(_d.inventory.docs);
    global.inventory_consumables = save_items_from_data(_d.inventory.consumables);

    global.itens_coletados   = _d.itens_coletados;
    global.knowledge_scores  = _d.knowledge_scores;
    global.knowledge_average = _d.knowledge_average;
    global.knowledge_total   = _d.knowledge_total;
    global.history_knowledge = _d.history_knowledge;
    global.relics_count      = _d.relics_count;
    global.defeated_enemies  = variable_struct_exists(_d, "defeated_enemies") ? _d.defeated_enemies : [];
    // Saves feitos antes deste campo recomeçam com as cenas "once" liberadas.
    if (variable_struct_exists(_d, "scenes_done") && is_struct(_d.scenes_done)) {
        global.scenes_done = _d.scenes_done;
    } else {
        global.scenes_done = {};
    }
    global.play_time         = _d.play_time;

    var _extras = save_extra_globals();
    for (var i = 0; i < array_length(_extras); i++) {
        if (variable_struct_exists(_d.extra, _extras[i])) {
            variable_global_set(_extras[i], variable_struct_get(_d.extra, _extras[i]));
        }
    }

    // Estado de "jogo rodando": sem sobras de batalha, pausa ou diálogo
    global.pre_battle_hp = 0;
    global.pre_battle_x  = 0;
    global.pre_battle_y  = 0;
    global.dialog_active = false;
    global.paused        = false;
    global.intro_played  = true;    // não repete a introdução
    global.warp_suppressed = true;  // se o save cair em cima de um warp, não dispara de cara
    // A música é global: para antes da troca de sala e deixa o obj_settings religá-la
    // se o slot salvo estiver no overworld (com a abertura já terminada).
    global.overworld_music_on = false;
    audio_stop_sound(SndCastleFunk);
    global.new_game      = false;
    global.save_slot     = _slot;

    // Carregar também conta como "último savepoint usado".
    global.last_savepoint_room = _room;
    global.last_savepoint_x    = _d.x;
    global.last_savepoint_y    = _d.y;
    global.last_savepoint_face = _d.face;

    audio_stop_sound(sfxTitle);
    if (instance_exists(ObjPlayer)) {
        with (ObjPlayer) instance_destroy();
    }
    room_goto(_room);
    var _p = instance_create_layer(_d.x, _d.y, "Player", ObjPlayer);
    _p.face = _d.face;
    _p.sprite_index = _p.sprite[_p.face];
    return true;
}