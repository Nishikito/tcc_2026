var gui_w  = display_get_gui_width();
var gui_h  = display_get_gui_height();
var scale  = gui_w / 320;

// ── OVERLAY ───────────────────────────────────────────
draw_set_alpha(0.75);
draw_set_color(c_black);
draw_rectangle(0, 0, gui_w, gui_h, false);
draw_set_alpha(1);

// ── PAINEL ────────────────────────────────────────────
var pw = 300 * scale;
var ph = 200 * scale;
var px = menu_x - pw / 2;
var py = menu_y - ph / 2;
var b  = 3 * scale;

draw_set_color(c_white);
draw_rectangle(px - b, py - b, px + pw + b, py + ph + b, false);
draw_set_color(c_black);
draw_rectangle(px, py, px + pw, py + ph, false);

// ── ABAS ──────────────────────────────────────────────
draw_set_font(fnt_main);
draw_set_halign(fa_center);
var tab_w = (pw / array_length(tabs));

for (var t = 0; t < array_length(tabs); t++) {
    var tx = px + tab_w * t + tab_w / 2;
    var ty = py + 10 * scale;

    if (t == current_tab) {
        // Aba ativa: texto branco + sublinhado
        draw_set_color(c_white);
        draw_text_transformed(tx, ty, tabs[t], scale, scale, 0);
        draw_rectangle(px + tab_w * t + 4*scale, py + 22*scale,
                       px + tab_w * (t+1) - 4*scale, py + 24*scale, false);
    } else {
        draw_set_color(make_color_rgb(100, 100, 100));
        draw_text_transformed(tx, ty, tabs[t], scale, scale, 0);
    }
}

// Linha separadora de abas
draw_set_color(make_color_rgb(80, 80, 80));
draw_rectangle(px + 10*scale, py + 26*scale, px + pw - 10*scale, py + 27*scale, false);

// ── CONTEÚDO: ABA AUDIO ───────────────────────────────
if (current_tab == 0) {
    var volumes = [global.vol_bgm, global.vol_sfx];

    for (var i = 0; i < array_length(audio_items); i++) {
        var iy = py + 44*scale + i * 44*scale;

        if (i == audio_sel) {
            draw_set_color(c_white);
            draw_sprite_ext(spr_heart_cursor, 0, px + 18*scale, iy + 4*scale, scale, scale, 0, c_white, 1);
        } else {
            draw_set_color(make_color_rgb(100, 100, 100));
        }

        // Label
        draw_set_halign(fa_left);
        draw_text_transformed(px + 36*scale, iy, audio_items[i], scale, scale, 0);

        // Número (espaço reservado à direita)
        var num_w = 24 * scale;
        var num_x = px + pw - 12*scale;

        draw_set_halign(fa_right);
        draw_set_color(i == audio_sel ? c_white : make_color_rgb(100, 100, 100));
        draw_text_transformed(num_x, iy, string(round(volumes[i] * 10)), scale, scale, 0);

        // Barra — termina antes do número
        // Barra — começa depois da label com mais folga
		var bar_x1 = px + 150*scale;  // era 112, aumentado para dar espaço à label
		var bar_x2 = num_x - num_w;
		var bar_y1 = iy + 6*scale;
			var bar_y2 = iy + 6*scale + 8*scale;

        draw_set_color(make_color_rgb(50, 50, 50));
        draw_rectangle(bar_x1, bar_y1, bar_x2, bar_y2, false);

        draw_set_color(i == audio_sel ? c_white : make_color_rgb(100, 100, 100));
        draw_rectangle(bar_x1, bar_y1, bar_x1 + (bar_x2 - bar_x1) * volumes[i], bar_y2, false);
    }

    draw_set_color(make_color_rgb(70, 70, 70));
    draw_set_halign(fa_center);
    draw_text_transformed(menu_x, py + ph - 18*scale,
        "A/D ajusta   Q/E troca aba   ESC volta", scale * 0.7, scale * 0.7, 0);
}

// ── CONTEÚDO: ABA CONTROLS ────────────────────────────
if (current_tab == 1) {

    for (var i = 0; i < array_length(key_items); i++) {
        var iy = py + 36*scale + i * 30*scale;

        if (i == key_sel) {
            draw_set_color(c_white);
            draw_sprite_ext(spr_heart_cursor, 0, px + 18*scale, iy + 4*scale, scale, scale, 0, c_white, 1);
        } else {
            draw_set_color(make_color_rgb(100, 100, 100));
        }

        draw_set_halign(fa_left);
        draw_text_transformed(px + 36*scale, iy, key_items[i], scale, scale, 0);

        // Nome da tecla atual
        var current_key = variable_global_get(key_globals[i]);

        // Se está remapeando esta tecla, pisca "..."
        var key_label = "";
        if (waiting_for_key && i == key_sel) {
            key_label = (current_time mod 600 < 300) ? "..." : "   ";
            draw_set_color(c_yellow);
        } else {
            key_label = key_to_string(current_key);
            // Fallback para teclas especiais que não retornam string
            if (key_label == "") key_label = "key:" + string(current_key);
        }

        draw_set_halign(fa_right);
        draw_text_transformed(px + pw - 16*scale, iy, key_label, scale, scale, 0);
    }

    // Instrução de remapeamento
    if (waiting_for_key) {
        draw_set_color(c_yellow);
        draw_set_halign(fa_center);
        draw_text_transformed(menu_x, py + ph - 30*scale, "Pressione a nova tecla", scale*0.8, scale*0.8, 0);
        draw_text_transformed(menu_x, py + ph - 16*scale, "ESC cancela", scale*0.7, scale*0.7, 0);
    } else {
        draw_set_color(make_color_rgb(70, 70, 70));
        draw_set_halign(fa_center);
        draw_text_transformed(menu_x, py + ph - 18*scale, "ENTER remapeia   Q/E troca aba   ESC volta", scale*0.7, scale*0.7, 0);
    }
}

// ── RESET ─────────────────────────────────────────────
draw_set_halign(fa_left);
draw_set_color(c_white);
draw_set_alpha(1);