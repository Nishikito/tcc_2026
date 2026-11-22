// Usadas por: obj_save_slots, obj_pause_menu, obj_settings_menu e obj_inventory.
// Dependem dos macros UI_* de scr_damage_calculator (sprite da moldura, tamanho das pontas, cursor).
// O parâmetro _scale existe porque pause, settings e inventário desenham numa GUI de tamanho
// variável (escala = largura da GUI / 320).
// ══════════════════════════════════════════════════════════════════

// Estados do menu de slots (obj_save_slots)
enum SAVE_UI {
    SLOTS,      // escolhendo um slot ou um botão (Copiar / Apagar / Voltar)
    ACTION,     // slot escolhido: Continuar / Novo jogo / Salvar ... ou Voltar
    COPY_SRC,   // copiar: qual arquivo copiar?
    COPY_DST,   // copiar: para qual slot?
    ERASE_SEL,  // apagar: qual arquivo?
    CONFIRM,    // pergunta Sim / Não
    MESSAGE     // aviso curto ("Jogo salvo!")
}

/// ui_draw_frame(frame, x, y, largura, altura, cor, [escala])
/// Moldura de sprite esticada em largura e altura (9-slice manual): 4 cantos fixos,
/// bordas e miolo esticados. frame 0 = compacto | 1 = alto. cor tinge a borda (c_white = original).
/// escala (opcional, padrão 1) multiplica o tamanho dos cantos e da borda.
/// x, y, largura e altura já devem vir em pixels da GUI (já multiplicados pela escala).
function ui_draw_frame(_frame, _x, _y, _w, _h, _color, _scale = 1) {
    var _spr = UI_SLOT_PANEL_SPRITE;
    var _sw  = sprite_get_width(_spr);

    // A arte de cada frame ocupa só parte do sprite de 32 linhas:
    // frame 0 = linhas 15..31 (17 linhas) | frame 1 = linhas 0..31 (32 linhas)
    var _art_top = [15, 0];
    var _art_h   = [17, 32];
    var _at = _art_top[_frame];
    var _ah = _art_h[_frame];

    // Pontas no sprite (origem) e na tela (destino, já escaladas)
    var _cx  = UI_PANEL_CAP_PIXELS;
    var _cy  = UI_PANEL_CAP_VERTICAL;
    var _cxs = _cx * _scale;
    var _cys = _cy * _scale;

    var _src_x = [0, _cx, _sw - _cx];
    var _src_w = [_cx, _sw - _cx * 2, _cx];
    var _dst_x = [_x, _x + _cxs, _x + _w - _cxs];
    var _dst_w = [_cxs, _w - _cxs * 2, _cxs];

    var _src_y = [_at, _at + _cy, _at + _ah - _cy];
    var _src_h = [_cy, _ah - _cy * 2, _cy];
    var _dst_y = [_y, _y + _cys, _y + _h - _cys];
    var _dst_h = [_cys, _h - _cys * 2, _cys];

    for (var _row = 0; _row < 3; _row++) {
        for (var _col = 0; _col < 3; _col++) {
            draw_sprite_part_ext(_spr, _frame,
                                 _src_x[_col], _src_y[_row], _src_w[_col], _src_h[_row],
                                 _dst_x[_col], _dst_y[_row],
                                 _dst_w[_col] / _src_w[_col], _dst_h[_row] / _src_h[_row],
                                 _color, 1);
        }
    }
}

/// ui_cursor_time()
/// Relógio do balanço do cursor, em radianos, baseado no tempo real. Quem não tem um contador
/// próprio (como o pause, o settings e o inventário) usa isto; a velocidade é a mesma de
/// UI_CURSOR_BOB_SPEED (que é "por frame a 60 fps").
function ui_cursor_time() {
    return current_time * UI_CURSOR_BOB_SPEED * 0.06;
}

/// ui_draw_cursor(x, y, timer, [escala])
/// Coração do cursor com o balanço do menu de pause (timer = contador do dono do cursor
/// ou ui_cursor_time()). escala (opcional) multiplica o tamanho do coração e do balanço.
function ui_draw_cursor(_x, _y, _timer, _scale = 1) {
    var _bob = round(sin(_timer) * UI_CURSOR_BOB_PIXELS * _scale);
    draw_sprite_ext(UI_SLOT_CURSOR_SPRITE, 0, _x, _y + _bob, _scale, _scale, 0, c_white, 1);
}