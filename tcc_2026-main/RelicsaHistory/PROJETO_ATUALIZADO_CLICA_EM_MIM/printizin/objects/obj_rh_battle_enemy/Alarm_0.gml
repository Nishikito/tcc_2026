// Inimigos com padrões de ataque (obj_rh_en_*) atacam pelo Step; este alarme é só do inimigo antigo.
if (array_length(patterns) > 0) exit;

if (!instance_exists(obj_rh_battle_controller) || !instance_exists(obj_rh_battle_box)) exit;

// Fora do turno do inimigo, ou com a caixa ainda abrindo: só espera e olha de novo.
if (obj_rh_battle_controller.state != BATTLE_STATE.ENEMY_TURN || !obj_rh_battle_box.is_open) {
    alarm[0] = 10;
    exit;
}

if (obj_rh_battle_controller.state == BATTLE_STATE.ENEMY_TURN
&&  instance_exists(obj_rh_battle_player)) {

    var _dir = point_direction(x, y, obj_rh_battle_player.x, obj_rh_battle_player.y);

    // Mesmo caminho dos ataques variados: cria na layer Bullets e sobe para
    // RH_BULLET_DEPTH, na frente do fundo preto da caixa.
    var _b = rh_spawn_attack(obj_rh_battle_bullet, x, y);
    _b.direction = _dir;
    _b.speed     = spd_bala;
}

alarm[0] = cadencia + irandom(20);
