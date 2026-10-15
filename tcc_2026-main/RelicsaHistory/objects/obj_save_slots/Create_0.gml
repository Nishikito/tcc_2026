// ══════════════════════════════════════════════════════════════════
// MENU DE ARQUIVOS (3 slots) — usado no título e nos pontos de save
// ──────────────────────────────────────────────────────────────────
// Só INTERFACE: quem lê/grava arquivos é o scr_save_system.
// Quem cria este objeto define o modo logo depois de criar:
//     var m = instance_create_layer(0, 0, "Instances", obj_save_slots);
//     m.mode = "title";   // tela de arquivos do título: NOVO JOGO / CONTINUAR
//     m.mode = "save";    // ponto de save no jogo: SALVAR / SOBRESCREVER
// ══════════════════════════════════════════════════════════════════
depth = -10000;          // por cima de tudo

mode       = "title";
init_done  = false;      // a inicialização (pausar, ler arquivos) roda no 1º Step, quando o modo já foi definido
input_lock = 3;          // ignora teclas nos primeiros frames (o Enter que abriu o menu não pode escolher nada)
cursor_timer = 0;

menu_state = SAVE_UI.SLOTS;
sel        = 0;          // 0..2 = slots | 3 = linha de botões (Copiar / Apagar / Voltar)
btn_sel    = 0;          // 0 = Copiar | 1 = Apagar | 2 = Voltar
act_sel    = 0;          // opção do slot escolhido (0 = ação principal | 1 = Voltar)
copy_src   = -1;         // slot de origem de uma cópia

confirm_text   = "";
confirm_sel    = 1;      // 0 = Sim | 1 = Não (começa em Não: o mais seguro)
confirm_action = "";     // "save" | "copy" | "erase"
confirm_slot   = -1;     // slot afetado pela ação
confirm_return = SAVE_UI.SLOTS;   // estado para onde voltar se o jogador disser Não

msg_text  = "";
msg_timer = 0;
msg_close = false;       // true = fecha o menu depois do aviso (ex.: "Jogo salvo!")

slot_info = [];          // resumo de cada slot (lido do arquivo) — atualizado em refresh_slots


// Relê os arquivos para atualizar o que a tela mostra
refresh_slots = function() {
    slot_info = [];
    for (var i = 0; i < SAVE_SLOT_COUNT; i++) {
        array_push(slot_info, save_slot_info(i));
    }
}

// Textos das duas opções que aparecem dentro do slot escolhido
get_action_labels = function(_slot) {
    var _exists = slot_info[_slot].exists;
    if (mode == "title") {
        if (_exists) return ["Continuar", "Voltar"];
        return ["Novo jogo", "Voltar"];
    }
    if (_exists) return ["Sobrescrever", "Voltar"];
    return ["Salvar", "Voltar"];
}

// Move o cursor para o próximo slot que TEM arquivo
move_to_existing = function(_dir) {
    var _n = sel;
    for (var i = 0; i < SAVE_SLOT_COUNT; i++) {
        _n = (_n + _dir + SAVE_SLOT_COUNT) mod SAVE_SLOT_COUNT;
        if (slot_info[_n].exists) { sel = _n; return; }
    }
}

// Move o cursor pulando um slot (o de origem de uma cópia)
move_skipping = function(_dir, _skip) {
    var _n = sel;
    for (var i = 0; i < SAVE_SLOT_COUNT; i++) {
        _n = (_n + _dir + SAVE_SLOT_COUNT) mod SAVE_SLOT_COUNT;
        if (_n != _skip) { sel = _n; return; }
    }
}

// Quantos slots têm arquivo
count_existing = function() {
    var _c = 0;
    for (var i = 0; i < SAVE_SLOT_COUNT; i++) {
        if (slot_info[i].exists) _c++;
    }
    return _c;
}

// Mostra um aviso (_close = true fecha o menu quando acabar)
say = function(_text, _close) {
    msg_text   = _text;
    msg_timer  = 120;
    msg_close  = _close;
    menu_state = SAVE_UI.MESSAGE;
}

// Pergunta Sim / Não
ask = function(_text, _action, _slot, _return_state) {
    confirm_text   = _text;
    confirm_action = _action;
    confirm_slot   = _slot;
    confirm_return = _return_state;
    confirm_sel    = 1;
    sel            = _slot;
    menu_state     = SAVE_UI.CONFIRM;
}

close_menu = function() {
    if (mode == "save") scr_unpause_game();
    instance_destroy();
}

// ── As ações de verdade (chamam o scr_save_system) ────────────────
do_save = function(_slot) {
    if (save_game(_slot)) {
        refresh_slots();
        if (SAVE_HEAL_ON_SAVE) say("Jogo salvo! Seu HP foi restaurado.", true);
        else say("Jogo salvo!", true);
    } else {
        say("Não foi possível salvar.", false);
    }
}

do_copy = function(_dst) {
    if (save_copy_slot(copy_src, _dst)) {
        refresh_slots();
        sel = _dst;
        say("Arquivo " + string(copy_src + 1) + " copiado para o " + string(_dst + 1) + ".", false);
    } else {
        say("Não foi possível copiar.", false);
    }
}

do_erase = function(_slot) {
    if (save_delete_slot(_slot)) {
        refresh_slots();
        say("Arquivo " + string(_slot + 1) + " apagado.", false);
    } else {
        say("Não foi possível apagar.", false);
    }
}

// Escolheu a opção principal de um slot
do_slot_action = function(_slot) {
    var _exists = slot_info[_slot].exists;

    if (mode == "title") {
        if (_exists) {
            if (game_load(_slot)) instance_destroy();
            else say("Arquivo corrompido ou local inexistente.", false);
        } else {
            game_start_new(_slot);
            instance_destroy();
        }
    } else {
        if (_exists) ask("Sobrescrever o arquivo " + string(_slot + 1) + "?", "save", _slot, SAVE_UI.ACTION);
        else do_save(_slot);
    }
}
