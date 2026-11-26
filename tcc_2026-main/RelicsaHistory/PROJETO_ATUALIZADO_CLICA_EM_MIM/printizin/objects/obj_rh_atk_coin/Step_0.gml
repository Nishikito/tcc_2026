vy = min(vy + grav, vy_max);
x += vx;
y += vy;
if (y > by2) { rh_debug_destroy("fim da vida"); instance_destroy(); }   // passou do chão da caixa
