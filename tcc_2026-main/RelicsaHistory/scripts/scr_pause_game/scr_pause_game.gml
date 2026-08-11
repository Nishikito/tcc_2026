/// Pausa o jogo de forma segura.
/// Desativa todas as instâncias exceto a que chama e o obj_settings.
/// Use sempre no lugar de instance_deactivate_all(true) + global.paused = true.
function scr_pause_game() {
    instance_deactivate_all(true);
    instance_activate_object(obj_settings);
    global.paused = true;
}

/// Retoma o jogo de forma segura.
/// Use sempre no lugar de instance_activate_all() + global.paused = false.
function scr_unpause_game() {
    instance_activate_all();
    global.paused = false;
}