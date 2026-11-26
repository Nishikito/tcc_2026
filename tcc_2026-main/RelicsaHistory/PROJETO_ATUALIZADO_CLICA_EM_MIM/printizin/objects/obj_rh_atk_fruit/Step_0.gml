if (mode == 0) {
    x += lengthdir_x(spd, dir);
    y += lengthdir_y(spd, dir);
    // fruta que só aparece dentro da caixa (chuva): some ao passar do chão
    if (clip_to_box && y > by2 + 8) { rh_debug_destroy("fim da vida"); instance_destroy(); }
}
else {
    rad -= rad_spd;
    ang += ang_spd;
    x = cx + lengthdir_x(rad, ang) - sprite_width  / 2;
    y = cy + lengthdir_y(rad, ang) - sprite_height / 2;
    if (rad <= 3) { rh_debug_destroy("fim da vida"); instance_destroy(); }   // o anel fechou
}
