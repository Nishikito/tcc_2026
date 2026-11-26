t++;

if (estado == "aviso") {
    // A lança ainda não machuca e ainda está fora da caixa.
    if (t >= warn_frames) {
        estado = "voo";
        active = true;
        sprite_index = (dir == 0) ? spr_lanca_right_attack : spr_lanca_attack;
        image_angle  = 0;   // garantido: rotação nenhuma
    }
    exit;
}

// Voo reto, velocidade constante, sem perseguir o coração.
x += lengthdir_x(spd, dir);

var _largura = sprite_get_width(sprite_index);
var _saiu = (dir == 180) ? (x + _largura < bx1) : (x > bx2);
if (_saiu || t > warn_frames + 90) {
    rh_debug_destroy("fim da vida");
    instance_destroy();
}
