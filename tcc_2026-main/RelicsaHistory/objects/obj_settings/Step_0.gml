
if (room == RoomTeachersAbandoned && global.carol_defeated && !carol_transition_done) {
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

// ── TEMPO DE JOGO ─────────────────────────────────────────────────
// Só a PRIMEIRA instância conta: obj_settings pode ter cópias (persistente + colocado em salas)
// e cada uma somaria o tempo, fazendo o relógio andar em dobro.
if (id == instance_find(obj_settings, 0)) {
    if (!global.paused && room != rm_title && room != rm_title_intro && room != RoomCredits) {
        global.play_time += min(delta_time, 100000) / 1000000;   // o min evita saltos se a janela travar
    }
}
