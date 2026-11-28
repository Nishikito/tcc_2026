t++;
y += vel_fumaca;

var _w = sprite_get_width(sprite_index)  * image_xscale;
var _h = sprite_get_height(sprite_index) * image_yscale;

// Single-hit, mas a hitbox coincide com o desenho durante TODO o trajeto:
// encostar na fumaça machuca, inclusive quando ela já está no topo da arena.
if (!was_hit) {
    if (rh_rect_hits_heart(x, y, x + _w, y + _h)) {
        rh_hurt_heart(id);
    }
}

if (t >= vida_fumaca) {
    rh_debug_destroy("fim da fumaça");
    instance_destroy();
}
