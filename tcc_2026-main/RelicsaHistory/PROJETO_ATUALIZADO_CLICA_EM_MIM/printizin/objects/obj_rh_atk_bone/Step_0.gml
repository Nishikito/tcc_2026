x += vx;
y += vy;
if ((vx < 0 && x < bx1 - 12) || (vx > 0 && x > bx2 + 12) || y > by2 + 24) instance_destroy();