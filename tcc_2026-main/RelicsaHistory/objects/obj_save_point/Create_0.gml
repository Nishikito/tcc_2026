// Ponto de save: o jogador chega perto e aperta a tecla de interação (global.key_interact).
// Coloque instâncias deste objeto nas salas onde o jogo pode ser salvo.

// Sprite: se você escolheu um nas propriedades do objeto, ele é usado.
// Senão, procura um sprite chamado "save_star". Se ele não existir, usa o coração
// (provisório) em vez de dar erro.
if (sprite_index == -1) {
    var _spr = asset_get_index("save_star");
    if (_spr >= 0) sprite_index = _spr;
    else sprite_index = spr_heart_cursor;
}
image_speed = 0;
bob_timer   = 0;     // balanço do sprite
near_player = false;