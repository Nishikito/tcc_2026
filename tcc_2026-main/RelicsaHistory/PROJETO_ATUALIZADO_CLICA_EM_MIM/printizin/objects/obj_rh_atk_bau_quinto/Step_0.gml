t++;

if (estado == 0) {
    // Tremor 0..2 px e cor branco -> vermelho ao longo da telegrafia.
    var _p = clamp(t / max(1, tele_total), 0, 1);
    var _amplitude = 2 * _p;
    x = base_x + random_range(-_amplitude, _amplitude);
    image_blend = merge_color(c_white, c_red, _p);

    if (t >= tele_total) {
        // Explosão: t_grupo + 90. Abre, dá o "pop" e solta a fumaça.
        estado = 1;
        x = base_x;
        sprite_index = spr_bau_aberto_attack;
        image_blend  = c_white;
        pop = 6;

        var _fw = sprite_get_width(spr_fumaca_attack)  * 0.6;
        var _fh = sprite_get_height(spr_fumaca_attack) * 0.6;
        var _bw = sprite_get_width(spr_bau_fechado_attack) * escala_bau;
        var _fx = x + (_bw - _fw) / 2;
        var _fy = by2 - 8;   // sobe para DENTRO da caixa (desenho recortado)
        var _f  = rh_spawn_attack(obj_rh_atk_fumaca_quinto, _fx, _fy);
        _f.escala_fumaca = 0.6;
        _f.vel_fumaca    = -1.1;
        _f.vida_fumaca   = 40;
    }
    exit;
}

if (estado == 1) {
    if (pop > 0) pop--;
    if (t >= tele_total + 8) {
        // Volta fechado, mas escurecido: o baú já foi usado.
        estado = 2;
        sprite_index = spr_bau_fechado_attack;
        image_blend  = make_color_rgb(90, 90, 90);
    }
}

if (t >= tele_total + 30) {
    rh_debug_destroy("fim do baú");
    instance_destroy();
}
