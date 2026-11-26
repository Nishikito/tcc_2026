t++;
if (x < bx1 - 22 || x > bx2 + 22 || y < by1 - 22 || y > by2 + 22) {
    rh_debug_destroy("bala de canhão saiu da caixa");
    instance_destroy();
}
if (t > life) {
    rh_debug_destroy("fim da vida (bala de canhão)");
    instance_destroy();
}