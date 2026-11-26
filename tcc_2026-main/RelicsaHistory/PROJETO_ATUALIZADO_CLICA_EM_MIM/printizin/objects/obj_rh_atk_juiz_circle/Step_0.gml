t++;

// Frame 1: anel de 12 juízes ao redor do centro da caixa (raio 88, escala 0.6).
if (t == 1) {
    var _r  = rh_box_inner();
    var _cx = (_r.x1 + _r.x2) / 2;
    var _cy = (_r.y1 + _r.y2) / 2;
    var _w  = sprite_get_width(spr_juiz_voador_attack)  * 0.6;
    var _h  = sprite_get_height(spr_juiz_voador_attack) * 0.6;
    verdadeiro = irandom(11);   // NÃO é sempre o primeiro

    for (var i = 0; i < 12; i++) {
        var _a = i * 30 + 90;   // graus: começa embaixo e vai no sentido horário
        var _px = _cx + lengthdir_x(88, _a) - _w / 2;
        var _py = _cy + lengthdir_y(88, _a) - _h / 2;
        var _c = rh_spawn_attack(obj_rh_atk_juiz_clone, _px, _py);
        _c.sprite_index = spr_juiz_voador_attack;
        _c.is_true  = (i == verdadeiro);
        _c.ring_pos = i;
        _c.image_alpha = 0;
        array_push(clones, _c);
        array_push(ordem, i);
    }

    // Embaralha a ORDEM DAS INVESTIDAS (Fisher-Yates).
    for (var i = 11; i > 0; i--) {
        var _j = irandom(i);
        var _tmp = ordem[i]; ordem[i] = ordem[_j]; ordem[_j] = _tmp;
    }
    rh_debug("CÍRCULO DO JUIZ | verdadeiro=" + string(verdadeiro + 1)
             + " | ordem sorteada=" + string(ordem));
}

// Fade-in de 6 frames; depois um telégrafo novo a cada 18 frames.
// Telégrafo de 12 frames: investida rápida, sem 3 segundos de buraco.
if (t >= 7 && prox < 12 && (t - 7) mod 18 == 0) {
    var _c = clones[ordem[prox]];
    if (instance_exists(_c)) {
        _c.telegraph_t = 0;
        _c.state = 1;                 // 1 = telegrafando
        _c.aim   = point_direction(_c.x + sprite_get_width(_c.sprite_index) * 0.3,
                                   _c.y + sprite_get_height(_c.sprite_index) * 0.3,
                                   rh_heart_x(), rh_heart_y());  // DIREÇÃO TRAVADA AQUI
        _c.jitter = 0;
        rh_debug("TELEGRAFO JUIZ " + string(prox + 1) + "/" + string(verdadeiro + 1)
                 + " | dir=" + string(_c.aim));
    }
    prox++;
}

if (t > 230) {
    rh_debug_destroy("fim da vida (gerenciador)");
    instance_destroy();
}
