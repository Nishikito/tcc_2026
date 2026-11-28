// O corte só existe dentro da caixa: trono_clipped_line() recorta a reta
// nos limites internos antes de desenhar (Liang-Barsky).
var _ln = trono_clipped_line(x, y, angle);
if (!_ln.found) exit;

var _p = clamp(1 - t / max(1, slash_time), 0, 1);

draw_set_color(c_white);
draw_set_alpha(0.28 * _p);
draw_line_width(_ln.x1, _ln.y1, _ln.x2, _ln.y2, 12);   // brilho
draw_set_alpha(_p);
draw_line_width(_ln.x1, _ln.y1, _ln.x2, _ln.y2, 4);    // núcleo branco
draw_set_alpha(1);
draw_set_color(c_white);
