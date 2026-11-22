vy = min(vy + grav, vy_max);
x += vx;
y += vy;
rot += rot_spd;
if (y + sprite_height > by2) instance_destroy();   // bateu no chão da caixa
