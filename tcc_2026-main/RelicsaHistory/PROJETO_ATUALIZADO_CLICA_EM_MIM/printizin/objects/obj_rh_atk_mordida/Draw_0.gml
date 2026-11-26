if (state == 0) {
    // Aviso: retângulo na frente, onde a boca vai chegar.
    var _ex = x + lengthdir_x(26 + 8 * lunge_frames, aim);
    var _ey = y + lengthdir_y(26 + 8 * lunge_frames, aim);
    draw_set_alpha(0.45);
    draw_set_color(c_red);
    draw_line_width(x + sprite_get_width(sprite_index) / 2,
                    y + sprite_get_height(sprite_index) / 2, _ex, _ey, 20);
    draw_set_alpha(1);
    draw_set_color(c_white);
}
rh_draw_clipped(sprite_index, image_index, x, y, image_xscale, image_yscale, image_blend, image_alpha);
