t++;
if (t < warn_t) exit;
x += vx;
if (is_true) active = true; else active = false;
if (x > bx2 + 70 || t > 170) instance_destroy();