// ── ANTI-LOOP DE WARPS ─────────────────────────────────────────────
// Vários warps têm a máscara esticada (scaleX/scaleY) e alguns destinos caem
// exatamente em cima de outro warp. Sem isto, ao voltar de rm_conecta_caminho_
// praia o jogador nasce sobre o warp que o devolve e fica preso no loop.
// Depois de qualquer transição os warps ficam travados até o player sair de
// TODAS as máscaras — aí ele pode usar o warp normalmente de novo.
if (!variable_global_exists("warp_suppressed")) global.warp_suppressed = false;
if (global.warp_suppressed && instance_exists(ObjPlayer)) {
    var _on_warp = false;
    with (obj_warp)      if (place_meeting(x, y, ObjPlayer)) _on_warp = true;
    with (obj_warp1)     if (place_meeting(x, y, ObjPlayer)) _on_warp = true;
    with (obj_warpClick) if (place_meeting(x, y, ObjPlayer)) _on_warp = true;
    if (!_on_warp) global.warp_suppressed = false;
}

// ── RETORNO DA BATALHA: recria o player se a sala não tiver um ──────
// O obj_battle_transition destrói o ObjPlayer antes de entrar em rm_rh_battle.
// Em rm_inicio (e outras salas) não há ObjPlayer no editor: sem isto o jogo
// volta sem jogador, a câmera fica presa no canto e o input não responde.
if (id == instance_find(obj_settings, 0)
    && global.battle_return_pending
    && room == global.battle_return_room
    && room != rm_rh_battle) {
    global.battle_return_pending = false;
    global.fade_active     = false;
    global.dialog_active   = false;
    global.cutscene_active = false;

    if (!instance_exists(ObjPlayer)) {
        // Buscar a layer pelo nome com funções de conversão quebra nesta versão
        // do GameMaker. O projeto já usa layer_exists() + string (ver scr_save_system).
        var _layer_name = layer_exists("Player") ? "Player" : "Instances";
        var _p = instance_create_layer(global.battle_return_x, global.battle_return_y, _layer_name, ObjPlayer);
        _p.face = global.battle_return_face;
        _p.sprite_index = _p.sprite[_p.face];
        camera_set_view_target(view_camera[0], _p);
    } else {
        camera_set_view_target(view_camera[0], ObjPlayer);
    }

    // O player recriado não dispara Room Start: garantir o Rodapé aqui também,
    // senão o companion some até a próxima troca de sala.
    companion_ensure_spawn();

    // Centraliza na hora (sem esperar o lerp do Step do player) para a câmera
    // nunca aparecer presa no canto da sala.
    var _cam = view_camera[0];
    var _w = camera_get_view_width(_cam), _h = camera_get_view_height(_cam);
    camera_set_view_pos(_cam,
        clamp(global.battle_return_x - _w / 2, 0, max(0, room_width  - _w)),
        clamp(global.battle_return_y - _h / 2, 0, max(0, room_height - _h)));
}

// ── FALLBACK DO ENCONTRO COM O GUARANÁ ─────────────────────────────
// O IDE pode reescrever rm_inicio.yy e derrubar os creation codes dos dois
// instances. Mesmo assim o gatilho continua apontando para a cena e o inimigo
// fica escondido até a cutscene revelá-lo. Durante a cena/batalha não mexe.
if (room == rm_inicio && !instance_exists(obj_cutscene) && !instance_exists(obj_battle_transition)) {
    // Inimigo já derrotado (inclusive em save antigo sem scenes_done): não rearmar
    // a cena "once" nem deixar o guaraná aparecer de novo ao voltar para a sala.
    if (save_enemy_defeated("Guarana")) {
        with (obj_cutscene_trigger) {
            if (scene_id == "mundo_guarana_encontro") instance_destroy();
        }
        with (obj_rh_en_guarana) visible = false;
    } else {
        var _t = instance_find(obj_cutscene_trigger, 0);
        if (_t != noone && _t.scene_id == "") {
            _t.scene_id = "mundo_guarana_encontro";
            _t.once = true;
        }
        with (obj_rh_en_guarana) visible = false;
    }
}

if (room == RoomTeachers_1 && global.carol_defeated && !carol_transition_done) {
    carol_transition_done = true;

    global.player_knocked_down = true;
    global.fade_active = true;
    if (!instance_exists(obj_fade_intro)) {
        instance_create_layer(0, 0, "Instances", obj_fade_intro);
    }
    if (instance_exists(ObjPlayer)) {
        ObjPlayer.x = 160;
        ObjPlayer.y = 120;
    }
}

if (global.carol_defeated && !global.fade_active && !instance_exists(obj_fade_intro)) {
    global.carol_defeated = false;
    carol_transition_done = false;
}

// ── MÚSICA POR SALA (ambiente / overworld) ─────────────────────────
// rm_inicio → rm_corredor_pra_praia → rm_conecta_caminho_praia →
// rm_caminho_para_oca: sfxAmbientMine1 (trecho da mina).
// rm_aldeia_indigena: sfxVilaIndigena (área dos indígenas).
// As salas do overworld continuam com SndCastleFunk, depois da abertura de
// RoomClass1_1, e param ao chegar em RoomTeachers_1 (cutscene do livro).
// A música é global (sobrevive à troca de sala): só troca quando a trilha
// desejada muda ou quando a transição de batalha a cortou.
if (!variable_global_exists("overworld_music_on"))       global.overworld_music_on       = false;
if (!variable_global_exists("overworld_music_finished")) global.overworld_music_finished = false;
if (!variable_global_exists("ambient_music_on"))         global.ambient_music_on         = false;
if (!variable_global_exists("current_music_track"))      global.current_music_track      = noone;
if (!variable_global_exists("intro_played"))             global.intro_played             = false;

// A cena da sala dos professores encerra a música do overworld para sempre
// (até um NOVO JOGO). Só marca quando a cutscene realmente começa.
if (room == RoomTeachers_1 && global.cutscene_active) {
    global.overworld_music_finished = true;
}

var _intro_done = global.intro_played && !instance_exists(obj_fade_intro);
if (room == RoomClass1_1) _intro_done = _intro_done && !global.dialog_active;

var _overworld_wanted = room_is_overworld(room)
                     && room != RoomTeachers_1
                     && !global.overworld_music_finished
                     && _intro_done
                     && room != rm_title && room != rm_title_intro && room != RoomCredits;

var _ambient_track = get_room_ambient_music(room);
var _wanted_track  = (_ambient_track != noone) ? _ambient_track
                   : (_overworld_wanted ? SndCastleFunk : noone);

// Só a PRIMEIRA instância controla a música global: obj_settings é persistente
// e também está colocado em algumas rooms (title/teste/batalha).
if (id == instance_find(obj_settings, 0)) {
    if (_wanted_track != noone) {
        if (global.current_music_track != _wanted_track || !audio_is_playing(_wanted_track)) {
            stop_all_ambient_music();   // evita dois loops / resto da sala anterior
            if (variable_global_exists("vol_bgm")) audio_sound_gain(_wanted_track, global.vol_bgm, 0);
            audio_play_sound(_wanted_track, 10, true);
            global.current_music_track = _wanted_track;
        }
        global.overworld_music_on = (_wanted_track == SndCastleFunk);
        global.ambient_music_on   = (_wanted_track != SndCastleFunk);
    } else {
        if (global.current_music_track != noone || audio_is_playing(SndCastleFunk)
            || audio_is_playing(sfxAmbientMine1) || audio_is_playing(sfxVilaIndigena)) {
            stop_all_ambient_music();
            global.current_music_track = noone;
        }
        global.overworld_music_on = false;
        global.ambient_music_on   = false;
    }
}

// ── TEMPO DE JOGO ─────────────────────────────────────────────────
// Só a PRIMEIRA instância conta: obj_settings pode ter cópias (persistente + colocado em salas)
// e cada uma somaria o tempo, fazendo o relógio andar em dobro.
if (id == instance_find(obj_settings, 0)) {
    if (!global.paused && room != rm_title && room != rm_title_intro && room != RoomCredits) {
        global.play_time += min(delta_time, 100000) / 1000000;   // o min evita saltos se a janela travar
    }
}
