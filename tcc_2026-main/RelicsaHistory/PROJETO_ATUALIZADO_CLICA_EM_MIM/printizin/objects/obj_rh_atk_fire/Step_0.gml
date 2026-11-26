t++;
y += vy;
x = base_x + dsin(t * 6) * wob;
if (y + sprite_height < by1) { rh_debug_destroy("fim da vida"); instance_destroy(); }   // saiu pelo topo
