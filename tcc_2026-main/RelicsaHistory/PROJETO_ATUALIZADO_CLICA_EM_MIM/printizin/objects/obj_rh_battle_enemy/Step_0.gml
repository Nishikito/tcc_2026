if (!instance_exists(obj_rh_battle_controller)) exit;

// Conta a reação de dano (visual) até zerar
if (hit_timer > 0) hit_timer--;

// Idle: troca de quadros (sprites com vários quadros). Sprite de 1 quadro não muda nada.
idle_timer++;
if (image_number > 1) image_index = (idle_timer div idle_frame_time) mod image_number;

if (obj_rh_battle_controller.state == BATTLE_STATE.ENEMY_TURN) {
    tempo += 3;
    y = centro_y + dsin(tempo) * sway_y;
    image_angle = dsin(tempo) * sway_angle;
}
else {
    // Fora do turno do inimigo: volta ao repouso (antes ele saía do turno torto)
    tempo       = 0;
    y           = centro_y;
    image_angle = 0;
}

// ── PADRÕES DE ATAQUE ──────────────────────────────────────────────
// Só atacam com a caixa 100% aberta (mesma regra do Alarm 0 antigo e do dano do coração).
var _attacking = (obj_rh_battle_controller.state == BATTLE_STATE.ENEMY_TURN
              &&  instance_exists(obj_rh_battle_box)
              &&  obj_rh_battle_box.is_open);

if (!_attacking) {
    pattern_running = false;
}
else if (array_length(patterns) > 0) {
    if (!pattern_running) {
        // Início de um turno: escolhe o próximo padrão.
        // 1º ciclo: em ordem (cada ataque aparece uma vez). Depois: sorteio, sem repetir o anterior.
        pattern_running = true;
        pattern_timer   = 0;
        var _n = array_length(patterns);
        var _pi;
        if (pattern_index < _n) {
            _pi = pattern_index;
        } else {
            _pi = irandom(_n - 1);
            if (_n > 1 && _pi == pattern_last) _pi = (_pi + 1 + irandom(_n - 2)) mod _n;
        }
        pattern_last    = _pi;
        pattern_current = patterns[_pi];
        pattern_index++;
    }
    pattern_timer++;
    pattern_current(pattern_timer);
}
