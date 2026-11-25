t++;
if (t < warn_t) exit;
active = true;
vy += grav;
y += vy;
if (y > by2 + 30 || t > 170) instance_destroy();