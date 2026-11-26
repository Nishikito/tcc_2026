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
    if (pattern_running && RH_DEBUG) {
        rh_debug("FIM DO TURNO de " + string(enemy_name)
                 + " | padrão " + string(pattern_last + 1)
                 + " | frames sem ataque: " + string(turn_empty_frames)
                 + " | maior sequência vazia: " + string(turn_max_empty_streak)
                 + " | frames rodados: " + string(pattern_timer));
    }
    pattern_running = false;
}
else if (array_length(patterns) > 0) {
    if (!pattern_running) {
        // Início de um turno: escolhe o próximo padrão.
        // 1º ciclo: em ordem (cada ataque aparece uma vez). Depois: sorteio, sem repetir o anterior.
        pattern_running = true;
        pattern_timer   = 0;
        turn_empty_frames      = 0;
        turn_empty_streak      = 0;
        turn_max_empty_streak  = 0;
        var _n = array_length(patterns);
        var _pi;
        if (RH_DEBUG_FORCE_PATTERN >= 0 && RH_DEBUG_FORCE_PATTERN < _n) {
            _pi = RH_DEBUG_FORCE_PATTERN;   // opção de diagnóstico: força um padrão
        } else if (pattern_index < _n) {
            _pi = pattern_index;
        } else {
            _pi = irandom(_n - 1);
            if (_n > 1 && _pi == pattern_last) _pi = (_pi + 1 + irandom(_n - 2)) mod _n;
        }
        pattern_last    = _pi;
        pattern_current = patterns[_pi];
        pattern_index++;

        var _pname = "padrao_" + string(_pi + 1);
        if (variable_instance_exists(id, "pattern_names")
        &&  array_length(pattern_names) > _pi) _pname = pattern_names[_pi];
        rh_debug("INICIO DO TURNO | inimigo=" + string(enemy_name)
                 + " | indice=" + string(_pi) + " | nome=" + string(_pname));
    }
    pattern_timer++;
    pattern_current(pattern_timer);
    if (RH_DEBUG && (pattern_timer == 1 || pattern_timer mod 60 == 0)) {
        rh_debug("pattern_current RODOU | " + string(enemy_name)
                 + " | t=" + string(pattern_timer) + " | ataques ativos="
                 + string(instance_number(obj_rh_battle_bullet)));
    }

    // Mede "turnos vazios": quantos frames se passaram sem NENHUM ataque na sala.
    if (instance_number(obj_rh_battle_bullet) == 0) {
        turn_empty_frames++;
        turn_empty_streak++;
        if (turn_empty_streak > turn_max_empty_streak) turn_max_empty_streak = turn_empty_streak;
    } else {
        turn_empty_streak = 0;
    }
    if (pattern_timer == 300 && RH_DEBUG) {
        rh_debug("TURNO COMPLETO (300 frames) | " + string(enemy_name)
                 + " | sem ataque: " + string(turn_empty_frames)
                 + " | maior sequencia: " + string(turn_max_empty_streak));
    }
}
