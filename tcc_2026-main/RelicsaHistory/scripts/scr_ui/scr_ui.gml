// ══════════════════════════════════════════════════════════════════
// UI COMPARTILHADA — peças de interface usadas por vários objetos
// ──────────────────────────────────────────────────────────────────
// Usa os macros UI_* de scr_damage_calculator (sprite da moldura, tamanho das pontas).
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

/// ui_draw_frame(frame, x, y, largura, altura, cor)
/// Moldura de sprite esticada em largura e altura (9-slice manual): 4 cantos fixos,
/// bordas e miolo esticados. frame 0 = compacto | 1 = alto. cor tinge a borda (c_white = original).
function ui_draw_frame(_frame, _x, _y, _w, _h, _color) {
    var _spr = UI_SLOT_PANEL_SPRITE;
    var _sw  = sprite_get_width(_spr);

    // A arte de cada frame ocupa só parte do sprite de 32 linhas:
    // frame 0 = linhas 15..31 (17 linhas) | frame 1 = linhas 0..31 (32 linhas)
    var _art_top = [15, 0];
    var _art_h   = [17, 32];
    var _at = _art_top[_frame];
    var _ah = _art_h[_frame];
    var _cx = UI_PANEL_CAP_PIXELS;
    var _cy = UI_PANEL_CAP_VERTICAL;

    var _src_x = [0, _cx, _sw - _cx];
    var _src_w = [_cx, _sw - _cx * 2, _cx];
    var _dst_x = [_x, _x + _cx, _x + _w - _cx];
    var _dst_w = [_cx, _w - _cx * 2, _cx];

    var _src_y = [_at, _at + _cy, _at + _ah - _cy];
    var _src_h = [_cy, _ah - _cy * 2, _cy];
    var _dst_y = [_y, _y + _cy, _y + _h - _cy];
    var _dst_h = [_cy, _h - _cy * 2, _cy];

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

/// ui_draw_cursor(x, y, timer)
/// Coração do cursor com o balanço do menu de pause (timer = contador que o dono do cursor avança).
function ui_draw_cursor(_x, _y, _timer) {
    var _bob = round(sin(_timer) * UI_CURSOR_BOB_PIXELS);
    draw_sprite(UI_SLOT_CURSOR_SPRITE, 0, _x, _y + _bob);
}
