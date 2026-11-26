t++;

vy += grav;
x  += vx;
y  += vy;

// O osso gira ao deixar a boca do vaso e estabiliza no topo do arco.
// O Draw desenha SEMPRE com a mesma rotação da máscara, inclusive na borda da
// caixa: desenho e hitbox continuam coincidindo em qualquer posição.
var _amortecimento = max(0, 1 - t / 24);
image_angle = spin_dir * spin_max * dsin(t * 10) * _amortecimento;

// Pico do arremesso: vy0²/(2*grav) <= 3.8²/0.32 ≈ 45 px.
// Nasce em y=78, então o topo chega a y≈33: bem dentro da room.
// Só morre quando o osso inteiro já passou da base da caixa.
if (y > by2 + 4 || t > 120) {
    rh_debug_destroy("fim da vida");
    instance_destroy();
}
