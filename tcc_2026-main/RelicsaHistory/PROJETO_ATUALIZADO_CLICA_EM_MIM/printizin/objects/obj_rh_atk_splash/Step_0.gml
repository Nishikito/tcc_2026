x += vx;
life--;
image_alpha = clamp(life / 15, 0, 1);   // some devagar nos últimos 15 frames
active = (life > 8);                    // quase transparente = já não machuca
if (life <= 0) instance_destroy();
