if (t <= warn_t) {
    draw_sprite_ext(sprite_index, 0, x, y, 1, 1, 0, c_red,
                    0.35 + 0.35 * dsin(t * 12));
} else {
    draw_self();
}
