var _dx = 0;
var _dy = 0;
if (kb_flash > 0 && ((kb_flash div 2) mod 2 == 0)) {
    _dx = lengthdir_x(2, kb_dir);
    _dy = lengthdir_y(2, kb_dir);
}
var _blend = (kb_flash > 0) ? c_red : c_white;

// Pisca enquanto os iframes duram (4 frames aceso / 4 apagado ≈ 7,5 Hz).
// image_alpha (fade da caixa) continua sendo respeitado.
var _alpha = image_alpha;
if (iframe_timer > 0 && ((iframe_timer div 4) mod 2 == 0)) _alpha *= 0.3;

draw_sprite_ext(sprite_index, image_index, x + _dx, y + _dy,
                image_xscale, image_yscale, image_angle, _blend, _alpha);
