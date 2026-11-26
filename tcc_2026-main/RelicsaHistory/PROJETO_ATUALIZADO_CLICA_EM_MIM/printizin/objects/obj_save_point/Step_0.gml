bob_timer += 0.06;

near_player = false;
if (instance_exists(ObjPlayer)) {
    near_player = (point_distance(x, y, ObjPlayer.x, ObjPlayer.y) < 28);
}

// ── Primeira vez que o Talai VÊ o save point ────────────────────────
// Fala ÚNICA e EXCLUSIVA do savepoint de rm_inicio. Outros save points
// (inclusive o da sala de teste) nunca disparam esta explicação.
// Raio maior que o de interação (28) para disparar ao avistar, e nunca por
// cima de diálogo/cutscene/batalha/menu.
if (!variable_global_exists("savepoint_intro_done")) global.savepoint_intro_done = false;
if (room == rm_inicio
    && !global.savepoint_intro_done
    && instance_exists(ObjPlayer)
    && point_distance(x, y, ObjPlayer.x, ObjPlayer.y) < 120
    && !global.dialog_active && !global.paused
    && !global.cutscene_active && !global.math_battle_active && !global.fade_active
    && !instance_exists(obj_save_slots)
    && !instance_exists(obj_cutscene)
    && !instance_exists(obj_battle_transition)) {
    global.savepoint_intro_done = true;
    create_textbox("mundo_savepoint_visto");
    global.dialog_active = true;
}

// Não abre durante diálogo, pausa ou se o menu já estiver aberto
// current_time >= save_point_unlock_time: depois de fechar o menu, espera um instante (o mesmo Enter não reabre)
var _free = (!global.dialog_active && !global.paused && !instance_exists(obj_save_slots)
             && current_time >= global.save_point_unlock_time);

if (near_player && _free && keyboard_check_pressed(global.key_interact)) {
    var _menu = instance_create_layer(0, 0, "Instances", obj_save_slots);
    _menu.mode = "save";
}