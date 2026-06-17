var ui_off_x = 0, ui_off_y = 0;
if (damage_shake > 0) {
    ui_off_x = irandom_range(-damage_shake, damage_shake);
    ui_off_y = irandom_range(-damage_shake, damage_shake);
}

var base_x = camera_x + 160 + ui_off_x;
var base_y = camera_y + 16 + ui_off_y;

draw_set_alpha(0.88);
draw_set_color(make_color_rgb(6,6,6));
draw_rectangle(camera_x + 8, camera_y + 8, camera_x + 312, camera_y + 172, false);
draw_set_alpha(1);

draw_set_font(global.font_main);
draw_set_halign(fa_left);
draw_set_valign(fa_middle);

var enemy_section_x = camera_x + 10;
var enemy_section_y = camera_y + 30;

draw_set_color(make_color_rgb(0,0,0));
draw_text(enemy_section_x + 10, enemy_section_y - 18 + 1, enemy_name_text);
draw_set_color(c_white);
draw_text(enemy_section_x + 10, enemy_section_y - 18, enemy_name_text);

draw_set_halign(fa_right);
draw_set_color(c_white);
draw_text(camera_x + 300, enemy_section_y - 18, "HP: " + string(enemy_current_hp) + "/" + string(enemy_max_hp));

var hp_bar_w = 200;
var hp_bar_h = 12;
var hp_bar_x = camera_x + 50;
var hp_bar_y = enemy_section_y - 25;

var hp_off_x = 0, hp_off_y = 0;
if (hp_shake_timer > 0) {
    hp_off_x = irandom_range(-3,3);
    hp_off_y = irandom_range(-2,2);
}

draw_set_color(make_color_rgb(25,25,25));
draw_rectangle(hp_bar_x + hp_off_x, hp_bar_y + hp_off_y,
               hp_bar_x + hp_bar_w + hp_off_x, hp_bar_y + hp_bar_h + hp_off_y, false);

draw_set_color(make_color_rgb(45,45,45));
draw_rectangle(hp_bar_x + hp_off_x, hp_bar_y + hp_off_y,
               hp_bar_x + hp_bar_w + hp_off_x, hp_bar_y + hp_bar_h + hp_off_y, true);

var hp_pct = clamp(enemy_current_hp / max(1, enemy_max_hp), 0, 1);
if (hp_pct > 0) {
    var hp_color;
    if (hp_pct > 0.6) hp_color = make_color_rgb(60, 200, 80);
    else if (hp_pct > 0.3) hp_color = make_color_rgb(220, 180, 40);
    else hp_color = make_color_rgb(200, 60, 60);
    
    draw_set_color(hp_color);
    draw_rectangle(hp_bar_x + 1 + hp_off_x, hp_bar_y + 1 + hp_off_y,
                   hp_bar_x + ((hp_bar_w - 2) * hp_pct) + hp_off_x,
                   hp_bar_y + hp_bar_h - 1 + hp_off_y, false);
}

draw_set_font(fnt_main);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

var qx = base_x;
var qy = camera_y + 60 + ui_off_y;

draw_set_color(make_color_rgb(0,0,0));
draw_text(qx + 2, qy + 2, current_question);
draw_set_color(c_white);
draw_text(qx, qy, current_question);

var timer_w = 220;
var timer_h = 8;
var timer_x = qx - timer_w/2;
var timer_y = qy + 25;
var timer_pct = clamp(answer_timer / max(1, max_answer_time), 0, 1);

draw_set_color(make_color_rgb(15,15,15));
draw_rectangle(timer_x, timer_y, timer_x + timer_w, timer_y + timer_h, false);
draw_set_color(make_color_rgb(40,40,40));
draw_rectangle(timer_x, timer_y, timer_x + timer_w, timer_y + timer_h, true);

if (timer_pct > 0) {
    var tcol;
    if (timer_pct > 0.6) tcol = make_color_rgb(70,210,90);
    else if (timer_pct > 0.3) tcol = make_color_rgb(240,210,60);
    else tcol = make_color_rgb(220,50,50);
    
    draw_set_color(tcol);
    draw_rectangle(timer_x + 1, timer_y + 1,
                   timer_x + ((timer_w - 2) * timer_pct), timer_y + timer_h - 1, false);
}

draw_set_font(fnt_main);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

var option_base_x = base_x;
var option_base_y = camera_y + 115 + ui_off_y;
var opt_w = 100;
var opt_h = 24;
var spacing_x = 130;
var spacing_y = 34;

var spr_w = sprite_get_width(spr_textbox);
var spr_h = sprite_get_height(spr_textbox);
var spr_scale_x = opt_w / spr_w;
var spr_scale_y = opt_h / spr_h;

for (var i = 0; i < 4; i++) {
    var col = i % 2;
    var row = floor(i / 2);
    var opt_x = option_base_x + (col == 0 ? -spacing_x/2 : spacing_x/2);
    var opt_y = option_base_y + row * spacing_y;
    
    var local_off_x = 0, local_off_y = 0;
    if (damage_shake > 0 && question_answered && selected_option == i) {
        local_off_x = irandom_range(-2,2);
        local_off_y = irandom_range(-2,2);
    }
    
    draw_sprite_ext(spr_textbox, 0, opt_x + local_off_x - opt_w/2, opt_y + local_off_y - opt_h/2,
                    spr_scale_x, spr_scale_y, 0, c_white, 1);
    
    draw_set_color(c_white);
    draw_text(opt_x + local_off_x, opt_y + local_off_y - 2, string(answers[i]));
    
    if (selected_option == i) {
        var arrow_x = opt_x - opt_w/2 - 22;
        var arrow_y = opt_y + local_off_y - 8;
        draw_sprite_ext(spr_textbox_arrow, 0, arrow_x, arrow_y, 1.2, 1.2, 0, c_white, 1);
    }
}

draw_set_font(fnt_main);
var hearts_total = global.max_lives;
var heart_spacing = 28;
var hearts_width = (hearts_total - 1) * heart_spacing;
var hearts_x0 = base_x - hearts_width/2;
var hearts_y = camera_y + 165 + ui_off_y;

for (var i = 0; i < hearts_total; i++) {
    var hx = hearts_x0 + i * heart_spacing;
    var hy = hearts_y;
    
    var hx_sh = 0, hy_sh = 0, scale = 1;
    if (heart_shake_timer > 0 && i == player_lives) {
        hx_sh = irandom_range(-4,4);
        hy_sh = irandom_range(-2,2) + sin(heart_shake_timer * 0.6);
        scale = 1.06;
    }
    
    if (i < player_lives) {
        draw_sprite_ext(spr_heart_cursor, 0, hx + hx_sh, hy + hy_sh, scale, scale, 0, c_white, 1);
    } else {
        draw_sprite_ext(spr_heart_cursor, 0, hx + hx_sh, hy + hy_sh, scale, scale, 0, make_color_rgb(40,40,40), 1);
    }
}

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_font(fnt_main);

if (battle_state == "result") {
    var alpha = 1;
    if (variable_instance_exists(id, "result_timer")) alpha = clamp(result_timer / 120, 0, 1);
    
    var correct = (answers[selected_option] == correct_answer);
    var msg = correct ? "CORRETO!" : "INCORRETO!";
    var color = correct ? make_color_rgb(100,255,120) : make_color_rgb(255,100,100);
    
    draw_set_alpha(alpha);
    draw_set_color(make_color_rgb(0,0,0));
    draw_text(base_x + 2, camera_y + 135 + ui_off_y + 2, msg);
    draw_set_color(color);
    draw_text(base_x, camera_y + 135 + ui_off_y, msg);
    draw_set_alpha(1);
}

if (battle_state == "victory") {
    draw_set_color(make_color_rgb(150,255,150));
    draw_text(base_x, camera_y + 135 + ui_off_y, "Voce venceu!");
}
if (battle_state == "defeat") {
    draw_set_color(make_color_rgb(255,150,150));
    draw_text(base_x, camera_y + 135 + ui_off_y, "DERROTADO");
}

draw_set_halign(fa_left);
draw_set_valign(fa_top);