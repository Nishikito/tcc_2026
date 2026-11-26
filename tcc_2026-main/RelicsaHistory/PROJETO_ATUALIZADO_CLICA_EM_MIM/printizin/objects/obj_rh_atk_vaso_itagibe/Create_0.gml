event_inherited();

// Vaso exclusivo do Itagibe: treme (aviso) -> solta ossos em arco -> afunda.
// O vaso NÃO machuca; só os ossos filhos de obj_rh_atk_bone_arco fazem dano.
active         = false;
destroy_on_hit = false;
clip_to_box    = true;

base_x         = x;
base_y         = y;
t              = 0;
warn_frames    = 24;
n_bones        = 5;
bone_interval  = 9;
dropped        = 0;
estado         = "aviso";
fade           = 0;

// Ajustados pelo padrão logo após rh_spawn_attack().
grav           = 0.16;
vy0_min        = -3.2;
vy0_max        = -3.8;
vx_ossos       = 0;
limite_ossos   = 8;
