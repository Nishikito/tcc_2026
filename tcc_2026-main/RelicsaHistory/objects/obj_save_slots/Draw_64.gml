// ══════════════════════════════════════════════════════════════════
// DESENHO DO MENU DE ARQUIVOS
// ──────────────────────────────────────────────────────────────────
// Tudo é desenhado num espaço virtual de 320x240 e a matriz de mundo escala
// para a tela (a GUI muda de tamanho de sala para sala). Só LÊ as variáveis do Create/Step.
// ══════════════════════════════════════════════════════════════════
var _gw = display_get_gui_width();
var _gh = display_get_gui_height();

// Fundo escuro cobrindo a tela inteira (no título é total; no jogo deixa ver o mapa por trás)
var _bg_alpha = 1;
if (mode == "save") _bg_alpha = 0.88;
draw_set_alpha(_bg_alpha);
draw_set_color(c_black);
draw_rectangle(0, 0, _gw, _gh, false);
draw_set_alpha(1);

// Escala 320x240 -> GUI, mantendo a proporção e centralizando
var _s  = min(_gw / 320, _gh / 240);
var _ox = (_gw - 320 * _s) / 2;
var _oy = (_gh - 240 * _s) / 2;
matrix_set(matrix_world, matrix_build(_ox, _oy, 0, 0, 0, 0, _s, _s, 1));

draw_set_font(global.font_main);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var _ts      = 0.85;                           // escala do texto
var _white   = c_white;
var _dim     = make_color_rgb(110, 110, 110);
var _source  = UI_COLOR_SELECTED;              // azul: marca o arquivo de ORIGEM de uma cópia

// ── Título ────────────────────────────────────────────────────────
var _title = "Selecione um arquivo.";
if (mode == "save") _title = "Salvar o jogo";
draw_set_color(_white);
draw_text_transformed(12, 6, _title, _ts, _ts, 0);

// ── Slots ─────────────────────────────────────────────────────────
for (var i = 0; i < SAVE_SLOT_COUNT; i++) {
    var _y    = 22 + i * 46;
    var _info = slot_info[i];

    // Slot em foco = branco | origem da cópia = azul | os outros = apagados
    var _col = _dim;
    if (sel == i && menu_state != SAVE_UI.MESSAGE) _col = _white;
    if (menu_state == SAVE_UI.COPY_DST && i == copy_src) _col = _source;

    ui_draw_frame(1, 12, _y, 296, 42, _col);
    draw_set_color(_col);

    // Linha 1: número, local e tempo
    draw_text_transformed(22, _y + 7, string(i + 1), _ts, _ts, 0);

    var _line1 = "[VAZIO]";
    var _time  = "--:--";
    if (_info.exists && _info.valid) {
        _line1 = _info.location;
        _time  = save_format_time(_info.play_time);
    } else if (_info.exists) {
        _line1 = "[CORROMPIDO]";
    }
    draw_text_transformed(38, _y + 7, _line1, _ts, _ts, 0);
    draw_set_halign(fa_right);
    draw_text_transformed(298, _y + 7, _time, _ts, _ts, 0);
    draw_set_halign(fa_left);

    // Linha 2: opções (slot escolhido) ou resumo
    if (sel == i && menu_state == SAVE_UI.ACTION) {
        var _labels = get_action_labels(i);
        for (var k = 0; k < 2; k++) {
            var _ox2 = 46 + k * 112;
            draw_text_transformed(_ox2, _y + 24, _labels[k], _ts, _ts, 0);
            if (act_sel == k) ui_draw_cursor(_ox2 - 14, _y + 25, cursor_timer);
        }
    } else if (_info.exists && _info.valid) {
        draw_text_transformed(38, _y + 24, "HP " + string(_info.hp) + "/" + string(_info.max_hp), _ts, _ts, 0);
    } else if (!_info.exists) {
        draw_text_transformed(38, _y + 24, "-----------", _ts, _ts, 0);
    }
}

// ── Botões: Copiar / Apagar / Voltar ──────────────────────────────
var _btn_names = ["Copiar", "Apagar", "Voltar"];
for (var b = 0; b < 3; b++) {
    var _bx = 40 + b * 100;
    var _bcol = _dim;
    var _on = (menu_state == SAVE_UI.SLOTS && sel == 3 && btn_sel == b);
    if (_on) _bcol = _white;
    draw_set_color(_bcol);
    draw_text_transformed(_bx, 164, _btn_names[b], _ts, _ts, 0);
    if (_on) ui_draw_cursor(_bx - 14, 165, cursor_timer);
}

// ── Caixa de baixo: dica, pergunta ou aviso ───────────────────────
ui_draw_frame(1, 12, 188, 296, 44, _white);
draw_set_color(_white);

switch (menu_state) {
    case SAVE_UI.SLOTS:
        draw_set_color(_dim);
        draw_text_transformed(22, 204, "Setas: mover    Enter: escolher    Esc: voltar", 0.7, 0.7, 0);
        break;

    case SAVE_UI.ACTION:
        draw_set_color(_dim);
        draw_text_transformed(22, 204, "Esquerda/Direita: opção    Enter: confirmar    Esc: voltar", 0.7, 0.7, 0);
        break;

    case SAVE_UI.COPY_SRC:
        draw_text_transformed(22, 200, "Copiar qual arquivo?", _ts, _ts, 0);
        break;

    case SAVE_UI.COPY_DST:
        draw_text_transformed(22, 200, "Copiar o arquivo " + string(copy_src + 1) + " para qual?", _ts, _ts, 0);
        draw_set_color(_dim);
        draw_text_transformed(22, 216, "Um arquivo ocupado pede confirmação.", 0.7, 0.7, 0);
        break;

    case SAVE_UI.ERASE_SEL:
        draw_text_transformed(22, 200, "Apagar qual arquivo?", _ts, _ts, 0);
        break;

    case SAVE_UI.CONFIRM:
        draw_text_transformed(22, 197, confirm_text, _ts, _ts, 0);
        var _yn = ["Sim", "Não"];
        for (var c = 0; c < 2; c++) {
            var _cx2 = 120 + c * 80;
            if (confirm_sel == c) draw_set_color(_white);
            else draw_set_color(_dim);
            draw_text_transformed(_cx2, 214, _yn[c], _ts, _ts, 0);
            if (confirm_sel == c) ui_draw_cursor(_cx2 - 14, 215, cursor_timer);
        }
        break;

    case SAVE_UI.MESSAGE:
        draw_set_color(UI_COLOR_HP_LABEL);
        draw_set_halign(fa_center);
        draw_text_transformed(160, 204, msg_text, _ts, _ts, 0);
        draw_set_halign(fa_left);
        break;
}

// Volta ao normal (outros objetos desenham depois de nós)
matrix_set(matrix_world, matrix_build_identity());
draw_set_color(c_white);
draw_set_alpha(1);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
