var gui_w = display_get_gui_width();
var gui_h = display_get_gui_height();
var scale = gui_w/320;


//bloco a - overlay
draw_set_alpha(0.80);
draw_set_colour(c_black); //aqui dá pra trocar a cor do fundo do menu
draw_rectangle(0, 0, gui_w, gui_h, false);
draw_set_alpha(1);

//painel

var pw = 300 * scale;
var ph = 210 * scale;
var px = menu_x - ph / 2;
var b = 3 * scale;



//bloco b - background do painel

//versão temporária
draw_set_colour(c_white);
draw_rectangle(px - b, py - b, px + pw + b, py + ph + b, false);
draw_set_colour(c_black);
draw_rectangle(px, py, px + pw, py + ph, false);

//versão definitiva(ainda não utilizada)
//draw_sprite_stretched(spr_inventario_bg, 0, px - b, py - b, pw + b*2, ph + b*2);

//bloco c - abas de navegação
draw_set_font(global.font_main);
draw_set_halign(fa_center);
var tab_w = pw/array_length(tabs);

for(var t = 0; t < array_length(tabs); t++;){
	var tx = px + tab_w * t + tab_w/2;
	var ty = py + 8 * scale;
	
	if(t== current_tab){
		draw_set_colour(c_white); //indica a cor da aba selecionada
		draw_text_transformed(tx, ty, tabs[t], scale * 0.75, scale * 0.75, 0);
		//sublinhado que inidca qaul aba tá ativa
		draw_rectangle(
			px + tab_w * t + tab_w / 2,
			py + 20 * scale,
			px + tab_w * (t+l) - 4 * scale,
			py + 22 * scale,
			false
		);
	}
	else{
		draw_set_colour(make_colour_rgb(100, 100, 100)); // cor de aba inativa
		draw_text_transformed(tx, ty, tabs[t], scale * 0.75, scale * 0.75, 0);
	}
}

//linha que separa abas
draw_set_colour(make_colour_rgb(80, 80, 80)); // cor dessa linha ai
draw_rectangle(px + 6 * scale, py + 24 * scale, px + pw - 6 * scale, py + 25 * scale, false);

//bloco d - aba de status

if(current_tab == 0){
	var cx = px + pw / 2;
	var cy = py + 34 * scale;
	
	draw_set_halign(fa_center);
	draw_set_font(global.font_main);
	
	//nome do protagonista
	draw_set_colour(c_white);
	draw_text_transformed(cx, cy, global.player_name, scale, scale, 0);
	
	//sprite do protagonista(quando houver)
	//draw_sprite(spr_player_portrait, 0, px + 20 * scale, cy + 20 * scale);
	
	//hp(não a marca de imopressora)
	draw_set_halign(fa_left);
	draw_set_colour(make_colour_rgb(255, 100, 100));//cor da barra de hp
	draw_text_transformed(px + 14 * scale, cy + 22 * scale, "PV: "+string(global.hp) + " / " + string(global.max_hp), scale, scale, 0);
	
	//barra de hp/pv
	var bar_x1 = px + 14 * scale;
	var bar_x2 = px + pw - 14 * scale;
	var bar_y = cy + 36 * scale;
	draw_set_colour(make_colour_rgb(60, 20, 20));// bg da barra
	draw_rectangle(bar_x1, bar_y, bar_x2, bar_y + 6*scale, false);
	draw_set_colour(make_colour_rgb(255, 80, 80));//cor de preenchimento da barra
	draw_rectangle(bar_x1, bar_y, bar_x1 + (bar_x2 - bar_x1) * (global.hp / global.max_hp), bar_y + 6 * scale, false);
	
	//conhecimento historico/overall
	
	draw_set_colour(make_colour_rgb(100, 200, 255)); //cor da label de conhecimento/over
	draw_text_transformed(px + 14 * scale, cy + 52 * scale, "Conhecimento: " + string(global.history_knowledge) + "%", scale, scale, 0);
	
	//barra de sabimento kb = knolege bar(ta errado a escrita, eu sei)
	var kb_y = cy + 66 * scale;
	draw_set_colour(make_colour_rgb(20, 40, 60));
	draw_rectangle(bar_x1, kb_y, bar_x2, kb_y + 6 * scale, false);
	draw_set_colour(make_colour_rgb(80, 180, 255));
	draw_rectangle(bar_x1, kb_y, bar_x1 + (bar_x2 - bar_x1) * (global.history_knowledge / 100), kb_y + 6 * scale, false);
	
	//relíquias pegas/coletadas
	//provavelmente isso vai mudar para um caramba
	draw_set_colour(make_colour_rgb(230, 180, 80)); // cor das relquias
	draw_text_transformed(px + 14 * scale, cy + 82 * scale, "Relíquias: "+ string(global.relics_count), scale, scale, 0);
}