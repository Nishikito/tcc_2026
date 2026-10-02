if (!instance_exists(obj_rh_battle_controller)) exit;

// Conta a reação de dano (visual) até zerar
if (hit_timer > 0) hit_timer--;

if (obj_rh_battle_controller.state == BATTLE_STATE.ENEMY_TURN) {
    tempo += 3;
    y = centro_y + dsin(tempo) * 20;
    image_angle = dsin(tempo) * 15;
}
else {
    // Fora do turno do inimigo: volta ao repouso (antes ele saía do turno torto)
    tempo       = 0;
    y           = centro_y;
    image_angle = 0;
}

