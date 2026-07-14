var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();
var scale = gui_w / 320;

// ┌─────────────────────────────────────────────────────────┐
// │  BLOCO A — OVERLAY                                      │
// └─────────────────────────────────────────────────────────┘
draw_set_alpha(0.80);
draw_set_color(c_black);
draw_rectangle(0, 0, gui_w, gui_h, false);
draw_set_alpha(1);

// ── DIMENSÕES DO PAINEL ───────────────────────────────────
var pw  = 300 * scale;
var ph  = 210 * scale;
var mpx = menu_x - pw / 2;
var mpy = menu_y - ph / 2;
var b   = 3 * scale;

// ┌─────────────────────────────────────────────────────────┐
// │  BLOCO B — FUNDO DO PAINEL                             │
// │  Troque por draw_sprite_stretched quando tiver o asset │
// └─────────────────────────────────────────────────────────┘
draw_set_color(c_white);
draw_rectangle(mpx - b, mpy - b, mpx + pw + b, mpy + ph + b, false);
draw_set_color(c_black);
draw_rectangle(mpx, mpy, mpx + pw, mpy + ph, false);

// OPÇÃO 2 — com sprite (comente as 4 linhas acima e descomente):
// draw_sprite_stretched(spr_inventario_bg, 0, mpx - b, mpy - b, pw + b*2, ph + b*2);

// ┌─────────────────────────────────────────────────────────┐
// │  BLOCO C — ABAS                                        │
// └─────────────────────────────────────────────────────────┘
draw_set_font(global.font_main);
draw_set_halign(fa_center);
var tab_w = pw / array_length(tabs);

for (var t = 0; t < array_length(tabs); t++) {
    var tx = mpx + tab_w * t + tab_w / 2;
    var ty = mpy + 8 * scale;

    if (t == current_tab) {
        draw_set_color(c_white);
        draw_text_transformed(tx, ty, tabs[t], scale * 0.75, scale * 0.75, 0);
        draw_rectangle(
            mpx + tab_w * t + 4*scale,
            mpy + 20*scale,
            mpx + tab_w * (t+1) - 4*scale,
            mpy + 22*scale, false
        );
    } else {
        draw_set_color(make_color_rgb(100, 100, 100));
        draw_text_transformed(tx, ty, tabs[t], scale * 0.75, scale * 0.75, 0);
    }
}

// Linha separadora abaixo das abas
draw_set_color(make_color_rgb(80, 80, 80));
draw_rectangle(mpx + 6*scale, mpy + 24*scale, mpx + pw - 6*scale, mpy + 25*scale, false);

// ┌─────────────────────────────────────────────────────────┐
// │  BLOCO D.0 — ABA STATUS                                │
// └─────────────────────────────────────────────────────────┘
if (current_tab == 0) {
    var cx = mpx + pw / 2;
    var cy = mpy + 34 * scale;

    draw_set_halign(fa_center);
    draw_set_font(global.font_main);

    // Nome do personagem
    draw_set_color(c_white);
    draw_text_transformed(cx, cy, global.player_name, scale, scale, 0);

    // Sprite do personagem (descomente quando tiver o asset):
    // draw_sprite(spr_player_portrait, 0, mpx + 20*scale, cy + 20*scale);

    // HP
    draw_set_halign(fa_left);
    draw_set_color(make_color_rgb(255, 100, 100));
    draw_text_transformed(mpx + 14*scale, cy + 22*scale,
        "HP: " + string(global.hp) + " / " + string(global.max_hp),
        scale, scale, 0);

    // Barra de HP
    var bar_x1 = mpx + 14*scale;
    var bar_x2 = mpx + pw - 14*scale;
    var bar_y  = cy + 36*scale;
    draw_set_color(make_color_rgb(60, 20, 20));
    draw_rectangle(bar_x1, bar_y, bar_x2, bar_y + 6*scale, false);
    draw_set_color(make_color_rgb(255, 80, 80));
    draw_rectangle(bar_x1, bar_y,
        bar_x1 + (bar_x2 - bar_x1) * (global.hp / global.max_hp),
        bar_y + 6*scale, false);

    // Conhecimento Histórico
    draw_set_color(make_color_rgb(100, 200, 255));
    draw_text_transformed(mpx + 14*scale, cy + 52*scale,
        "Conhecimento: " + string(global.history_knowledge) + "%",
        scale, scale, 0);

    // Barra de Conhecimento
    var kb_y = cy + 66*scale;
    draw_set_color(make_color_rgb(20, 40, 60));
    draw_rectangle(bar_x1, kb_y, bar_x2, kb_y + 6*scale, false);
    draw_set_color(make_color_rgb(80, 180, 255));
    draw_rectangle(bar_x1, kb_y,
        bar_x1 + (bar_x2 - bar_x1) * (global.history_knowledge / 100),
        kb_y + 6*scale, false);

    // Relíquias coletadas
    draw_set_color(make_color_rgb(230, 180, 80));
    draw_text_transformed(mpx + 14*scale, cy + 82*scale,
        "Reliquias: " + string(global.relics_count),
        scale, scale, 0);
}

// ┌─────────────────────────────────────────────────────────┐
// │  BLOCO D.1-3 — RELÍQUIAS, MISSÃO E DOCUMENTOS         │
// └─────────────────────────────────────────────────────────┘
if (current_tab == 1 || current_tab == 2 || current_tab == 3) {
    var _arr = scr_inventory_get_array_by_tab(current_tab);
    var _sel = tab_sel[current_tab];
    var content_y = mpy + 30 * scale;

    if (array_length(_arr) == 0) {
        draw_set_color(make_color_rgb(100, 100, 100));
        draw_set_halign(fa_center);
        draw_text_transformed(mpx + pw/2, content_y + 40*scale,
            "Nenhum item ainda.", scale, scale, 0);
    } else {
        // ── LISTA (lado esquerdo) ──────────────────────────────
        var list_w = pw * 0.45;
        for (var i = 0; i < array_length(_arr); i++) {
            var iy = content_y + i * 18 * scale;

            if (i == _sel) {
                draw_set_color(make_color_rgb(255, 220, 100));
                draw_sprite_ext(spr_heart_cursor, 0,
                    mpx + 10*scale, iy + 4*scale,
                    scale, scale, 0, c_white, 1);
            } else {
                draw_set_color(make_color_rgb(160, 160, 160));
            }

            draw_set_halign(fa_left);
            draw_text_transformed(mpx + 22*scale, iy,
                _arr[i].name, scale * 0.9, scale * 0.9, 0);
        }

        // ── PAINEL DE DETALHES (lado direito) ─────────────────
        var detail_x = mpx + list_w + 10*scale;
        var item = _arr[_sel];

        // Divisória vertical
        draw_set_color(make_color_rgb(80, 80, 80));
        draw_rectangle(mpx + list_w, content_y,
            mpx + list_w + 1*scale, mpy + ph - 20*scale, false);

        // Sprite do item
        if (sprite_exists(item.sprite)) {
            draw_sprite_ext(item.sprite, 0,
                detail_x + 20*scale, content_y + 20*scale,
                scale * 2, scale * 2, 0, c_white, 1);
        }

        // Nome
        draw_set_color(c_white);
        draw_set_halign(fa_left);
        draw_text_transformed(detail_x + 4*scale, content_y + 4*scale,
            item.name, scale, scale, 0);

        // Descrição
        draw_set_color(make_color_rgb(180, 180, 180));
        draw_text_ext_transformed(
            detail_x + 4*scale, content_y + 50*scale,
            item.description,
            -1,
            (pw - list_w - 16) * scale,
            scale * 0.85, scale * 0.85, 0
        );
    }
}

// ┌─────────────────────────────────────────────────────────┐
// │  BLOCO D.4 — CONSUMÍVEIS                               │
// └─────────────────────────────────────────────────────────┘
if (current_tab == 4) {
    var _arr = global.inventory_consumables;
    var _sel = tab_sel[4];
    var content_y = mpy + 30 * scale;

    if (array_length(_arr) == 0) {
        draw_set_color(make_color_rgb(100, 100, 100));
        draw_set_halign(fa_center);
        draw_text_transformed(mpx + pw/2, content_y + 40*scale,
            "Sem consumiveis.", scale, scale, 0);
    } else {
        for (var i = 0; i < array_length(_arr); i++) {
            var iy = content_y + i * 20 * scale;
            var item = _arr[i];

            if (i == _sel) {
                draw_set_color(c_white);
                draw_sprite_ext(spr_heart_cursor, 0,
                    mpx + 10*scale, iy + 4*scale,
                    scale, scale, 0, c_white, 1);
            } else {
                draw_set_color(make_color_rgb(160, 160, 160));
            }

            draw_set_halign(fa_left);
            draw_text_transformed(mpx + 22*scale, iy,
                item.name, scale * 0.9, scale * 0.9, 0);

            // Quantidade à direita
            draw_set_halign(fa_right);
            draw_set_color(make_color_rgb(200, 220, 100));
            draw_text_transformed(mpx + pw - 16*scale, iy,
                "x" + string(item.qty), scale * 0.9, scale * 0.9, 0);
        }
    }
}

// ┌─────────────────────────────────────────────────────────┐
// │  BLOCO E — RODAPÉ                                      │
// └─────────────────────────────────────────────────────────┘
draw_set_color(make_color_rgb(70, 70, 70));
draw_set_halign(fa_center);
draw_text_transformed(
    mpx + pw / 2,
    mpy + ph - 14 * scale,
    "Q/E troca aba   W/S navega   ESC fecha",
    scale * 0.7, scale * 0.7, 0
);

// ── RESET (sempre ao final do Draw) ──────────────────────
draw_set_halign(fa_left);
draw_set_color(c_white);
draw_set_alpha(1);