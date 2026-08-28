switch (state) {

    // ── MENU ──────────────────────────────────────────────────────
    case BATTLE_STATE.MENU:
        if (keyboard_check_pressed(vk_right) || keyboard_check_pressed(global.key_right)) {
            menu_option = (menu_option + 1) % array_length(menu_names);
        }
        if (keyboard_check_pressed(vk_left) || keyboard_check_pressed(global.key_left)) {
            menu_option--;
            if (menu_option < 0) menu_option = array_length(menu_names) - 1;
        }

        if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(ord("Z"))) {
            switch (menu_option) {
                case 0: // LUTAR → vai para questão
                    current_question = get_random_question();
                    selected_option  = 0;
                    state = BATTLE_STATE.QUESTION;
                    break;

                case 1: // ITEM — por ora vai direto para turno do inimigo
                    state = BATTLE_STATE.ENEMY_TURN;
                    enemy_turn_timer = enemy_turn_max_time;
                    break;

                case 2: // DEFENDER — reduz dano recebido neste turno
                    state = BATTLE_STATE.ENEMY_TURN;
                    enemy_turn_timer = enemy_turn_max_time;
                    break;
            }
        }
        break;

    // ── QUESTÃO ───────────────────────────────────────────────────
    case BATTLE_STATE.QUESTION:
        if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(global.key_down)) {
            selected_option = (selected_option + 1) % 4;
        }
        if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(global.key_up)) {
            selected_option--;
            if (selected_option < 0) selected_option = 3;
        }

        if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(ord("Z"))) {
            // Registra a resposta e atualiza a média
            last_answer_score = get_answer_score(current_question, selected_option);
            register_answer_score(last_answer_score);

            // Calcula o dano máximo da barra já com o modificador da nova média
            attack_damage_max = calculate_player_damage_max(last_answer_score);

            // Monta o texto de feedback
            var _mod_label = (get_attack_modifier() >= 1.0) ? "↑ Bônus de ataque!" : "↓ Penalidade de ataque.";
            result_text = "Média: " + string_format(global.knowledge_average, 1, 1)
                        + " (" + get_knowledge_label() + ")  "
                        + _mod_label
                        + "  |  Dano máx: " + string(attack_damage_max);

            result_timer = result_timer_max;
            state = BATTLE_STATE.QUESTION_RESULT;
        }
        break;

    // ── RESULTADO DA QUESTÃO (caixa de diálogo inferior) ─────────
    case BATTLE_STATE.QUESTION_RESULT:
        result_timer--;
        if (result_timer <= 0) {
            // Configura o minigame com o dano máximo calculado
            attack_state     = 0;
            attack_bar_x     = room_width - 40;
            attack_bar_speed = 9;
            attack_result_text = "";
            attack_damage    = 0;
            state = BATTLE_STATE.ATTACK_MINIGAME;
        }
        break;

    // ── MINIGAME DE ATAQUE ────────────────────────────────────────
    case BATTLE_STATE.ATTACK_MINIGAME:
        var _box_x1      = 20;
        var _target_x    = _box_x1 + 20;

        if (attack_state == 0) {
            attack_bar_x -= attack_bar_speed;

            if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(ord("Z"))) {
                attack_state = 1;
                attack_timer = 50;

                var _dist = abs(attack_bar_x - _target_x);
                var _ratio = 0.0; // 0 = miss, 1 = perfect

                if (_dist <= 8) {
                    attack_result_text = "PERFEITO!!";
                    _ratio = 1.0;
                } else if (_dist <= 30) {
                    attack_result_text = "ÓTIMO!";
                    _ratio = 0.75;
                } else if (_dist <= 80) {
                    attack_result_text = "OK";
                    _ratio = 0.4;
                } else {
                    attack_result_text = "ERROU";
                    _ratio = 0.0;
                }

                // Dano proporcional ao acerto × dano máximo já modificado pela média
                attack_damage = round(attack_damage_max * _ratio);

                if (instance_exists(obj_rh_battle_enemy)) {
                    enemy_hp = apply_damage_to_enemy(enemy_hp, attack_damage);
                    global.battle_enemy_hp = enemy_hp;
                }
            }

            if (attack_bar_x <= _box_x1 + 8) {
                attack_state       = 1;
                attack_timer       = 50;
                attack_result_text = "ERROU";
                attack_damage      = 0;
            }
        } else {
            attack_timer--;
            if (attack_timer <= 0) {
                // Verifica vitória antes de passar o turno
                if (enemy_hp <= 0) {
                    state = BATTLE_STATE.VICTORY;
                } else {
                    state = BATTLE_STATE.ENEMY_TURN;
                    enemy_turn_timer = enemy_turn_max_time;
                    menu_option = 0;
                }
            }
        }
        break;

    // ── TURNO DO INIMIGO ──────────────────────────────────────────
    case BATTLE_STATE.ENEMY_TURN:
        enemy_turn_timer--;
        if (enemy_turn_timer <= 0) {
            with (obj_rh_battle_bullet) instance_destroy();
            if (global.hp <= 0) {
                state = BATTLE_STATE.DEFEAT;
            } else {
                state = BATTLE_STATE.MENU;
                menu_option = 0;
            }
        }
        break;

    // ── VITÓRIA ───────────────────────────────────────────────────
    case BATTLE_STATE.VICTORY:
    if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(ord("Z"))) {
        global.battle_result = "victory";

        // Marca inimigo como derrotado
        if (!variable_global_exists("defeated_enemies")) {
            global.defeated_enemies = [];
        }
        var _already = false;
        for (var i = 0; i < array_length(global.defeated_enemies); i++) {
            if (global.defeated_enemies[i] == global.current_enemy_id) {
                _already = true;
                break;
            }
        }
        if (!_already) array_push(global.defeated_enemies, global.current_enemy_id);

        // Volta para a sala — ObjPlayer será recriado por ela
        room_goto(global.pre_battle_room);
    }
    break;

case BATTLE_STATE.DEFEAT:
    if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(ord("Z"))) {
        global.battle_result  = "defeat";
        global.pre_battle_hp  = global.max_hp; // restaura HP cheio na derrota
        // posição é mantida — player reaparece onde estava

        room_goto(global.pre_battle_room);
    }
    break;
}