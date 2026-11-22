vy = min(vy + grav, vy_max);
x += vx;
y += vy;
if (y > by2) instance_destroy();   // passou do chão da caixa
