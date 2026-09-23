/// scr_item_coleta
/// Controle de quais itens do cenário já foram pegos.
///
/// Por que isso existe: instâncias de sala são recriadas toda vez que o
/// jogador entra nela. Sem esse registro global, a Erva Medicinal
/// reaparece no chão toda vez que você volta pro mapa — e dá pra farmar
/// item infinito. Guardamos só o ID (string), não a instância.

/// Garante que o array global existe antes de qualquer uso.
/// Ideal é inicializar em obj_settings/Create_0, mas essa guarda evita
/// crash se a sala for aberta direto pelo editor durante os testes.
function scr_itens_coletados_init() {
    if (!variable_global_exists("itens_coletados")) {
        global.itens_coletados = [];
    }
}

/// Já pegamos esse item antes?
function item_ja_coletado(_uid) {
    scr_itens_coletados_init();
    for (var i = 0; i < array_length(global.itens_coletados); i++) {
        if (global.itens_coletados[i] == _uid) return true;
    }
    return false;
}

/// Marca o item como pego. Ignora duplicata.
function marcar_item_coletado(_uid) {
    scr_itens_coletados_init();
    if (_uid == "") return;
    if (item_ja_coletado(_uid)) return;
    array_push(global.itens_coletados, _uid);
}

/// Útil pra debug / começar jogo novo: limpa o registro.
function resetar_itens_coletados() {
    global.itens_coletados = [];
}