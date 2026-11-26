x += vx;
y += vy;
if ((vx < 0 && x < bx1 - 12) || (vx > 0 && x > bx2 + 12) || y > by2 + 24) { rh_debug_destroy("fim da vida"); instance_destroy(); }