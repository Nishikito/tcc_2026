t++;
y += vy;
x = base_x + dsin(t * 6) * wob;
if (y + sprite_height < by1) instance_destroy();   // saiu pelo topo
