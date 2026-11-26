t++;
if (t <= warn_t) exit;   // aviso piscando, ainda sem dano

active = true;
y += fall_spd;
if (y > by2 + 20) {
    rh_debug_destroy("viga passou da caixa");
    instance_destroy();
}
