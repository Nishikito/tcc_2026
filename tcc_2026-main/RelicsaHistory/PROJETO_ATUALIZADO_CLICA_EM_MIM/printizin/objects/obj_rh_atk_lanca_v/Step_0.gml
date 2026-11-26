t++;

if (estado == "aviso") {
    if (t >= warn_frames) {
        estado = "voo";
        active = true;
        image_angle = 0;   // sprites de cima/baixo já estão alinhados ao eixo
    }
    exit;
}

y += vy;   // reto e constante

var _saiu = (sair == "baixo") ? (y > by2) : (y + 66 < by1);
if (_saiu || t > warn_frames + 90) {
    rh_debug_destroy("fim da vida");
    instance_destroy();
}
