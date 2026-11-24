/// @description Toca uma cutscene pelo ID.
/// O prefixo (antes do 1º "_") escolhe o script: "janitor_recruit" -> scr_cena_janitor
function cutscene_play(_id) {
    if (instance_exists(obj_cutscene)) return;

    var _prefix = string_split(_id, "_")[0];
    var _script = asset_get_index("scr_cena_" + _prefix);

    if (!script_exists(_script)) {
        show_debug_message("CUTSCENE NAO ENCONTRADA: " + _id + " | Script procurado: scr_cena_" + _prefix);
        return;
    }

    // o script devolve o array da cena (ou [] pra cancelar)
    var _scene = script_execute(_script, _id);
    if (!is_array(_scene) || array_length(_scene) == 0) return;

    var _c = instance_create_depth(0, 0, 0, obj_cutscene);
    _c.scene_info = _scene;
}