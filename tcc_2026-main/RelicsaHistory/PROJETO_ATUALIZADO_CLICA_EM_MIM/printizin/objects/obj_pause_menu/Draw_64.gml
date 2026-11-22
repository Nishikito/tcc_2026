var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();

// ── ESCALA PROPORCIONAL ────────────────────────────────
// 320 é a largura base de referência (estilo Undertale).
// Se tua room tiver outra largura base, ajusta esse número.
var scale = gui_w / 320;

// ── OVERLAY ────────────────────────────────────────────
draw_set_alpha(0.75);
draw_set_color(c_black);
draw_rectangle(0, 0, gui_w, gui_h, false);
draw_set_alpha(1);

// ── DIMENSÕES DO PAINEL (tudo escalado) ───────────────
var panel_w  = 280 * scale;
var panel_h  = 160 * scale;
var panel_x  = menu_x - panel_w / 2;
var panel_y  = menu_y - panel_h / 2;
var border   = 3 * scale;
var opt_gap  = option_height * scale;

// Fundo preto + moldura em sprite (a mesma da batalha; ui_draw_frame, em scr_ui)
draw_set_color(c_black);
draw_rectangle(panel_x - border, panel_y - border, panel_x + panel_w + border, panel_y + panel_h + border, false);
ui_draw_frame(1, panel_x - border, panel_y - border, panel_w + border * 2, panel_h + border * 2, c_white, scale);

// ── TÍTULO ─────────────────────────────────────────────
draw_set_font(fnt_main);
draw_set_halign(fa_center);
draw_set_color(c_white);

// draw_text_transformed escala o texto junto com o resto
draw_text_transformed(
    menu_x,
    panel_y + 14 * scale,
    "- PAUSED -",
    scale, scale, 0  // xscale, yscale, ângulo
);

// Linha separadora
draw_set_color(c_white);
draw_rectangle(
    panel_x + 10 * scale,
    panel_y + 34 * scale,
    panel_x + panel_w - 10 * scale,
    panel_y + 36 * scale,
    false
);

// ── OPÇÕES ─────────────────────────────────────────────
for (var i = 0; i < array_length(menu_options); i++) {

    var opt_y = panel_y + 50 * scale + (i * opt_gap);

    if (i == selected) {
        draw_set_color(c_white);

        // Coração do cursor (ui_draw_cursor, em scr_ui: mesmo sprite e balanço da batalha)
        ui_draw_cursor(panel_x + 18 * scale, opt_y, ui_cursor_time(), scale);

    } else {
        draw_set_color(make_color_rgb(100, 100, 100));
    }

    draw_set_halign(fa_left);
    draw_text_transformed(
        panel_x + 38 * scale,
        opt_y,
        menu_options[i],
        scale, scale, 0
    );
}

// ── RESET ──────────────────────────────────────────────
draw_set_halign(fa_left);
draw_set_color(c_white);
draw_set_alpha(1);