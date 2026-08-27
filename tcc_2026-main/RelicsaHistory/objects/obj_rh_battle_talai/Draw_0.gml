// Usa o sprite do ObjPlayer se existir, senão usa placeholder
var _spr = SprPlayerDown; // sprite padrão do Talai

draw_sprite_ext(
    _spr, 0,
    x, y,
    1.5, 1.5,          // escala 1.5x — maior que na exploração
    image_angle,
    c_white, 1
);