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
            var _mod_label;
            if (get_attack_modifier() >= 1.0) {
                _mod_label = "↑ Bônus de ataque!";
            } else {
                _mod_label = "↓ Penalidade de ataque.";
            }
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
            attack_bar_speed = ATTACK_BAR_SPEED;

            // Trilha: mesmas contas que o Draw usa para a caixa (GUI 320 de largura)
            attack_lane_x1  = 4 + 8;
            attack_lane_x2  = (display_get_gui_width() - 4) - 8;
            attack_target_x = attack_lane_x1 + 48;
            attack_bar_x    = attack_lane_x2;

            // Zona escalada pela média: reaproveita o mesmo modificador do dano
            // (1.3 se média > 5, 0.7 caso contrário). Uma fonte só, sem duplicar.
            var _zmod = get_attack_modifier();
            attack_zone_perfect = ATTACK_ZONE_PERFECT * _zmod;
            attack_zone_great   = ATTACK_ZONE_GREAT   * _zmod;
            attack_zone_ok      = ATTACK_ZONE_OK      * _zmod;

            attack_result_text = "";
            attack_damage    = 0;
            state = BATTLE_STATE.ATTACK_MINIGAME;
        }
        break;

    // ── MINIGAME DE ATAQUE ────────────────────────────────────────
    // A barra desliza até o jogador apertar (ou chegar ao fim da trilha).
    // Quando isso acontece, a LÓGICA é resolvida aqui (UMA vez) e a batalha
    // passa para ATTACK_ANIM, que só mostra o resultado visualmente.
    case BATTLE_STATE.ATTACK_MINIGAME:
        attack_bar_x -= attack_bar_speed;

        if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(ord("Z"))) {
            attack_state = 1;

            var _dist = abs(attack_bar_x - attack_target_x);
            var _ratio = 0.0; // 0 = miss, 1 = perfect

            if (_dist <= attack_zone_perfect) {
                attack_result_text = "PERFEITO!!";
                _ratio = 1.0;
            } else if (_dist <= attack_zone_great) {
                attack_result_text = "ÓTIMO!";
                _ratio = 0.75;
            } else if (_dist <= attack_zone_ok) {
                attack_result_text = "OK";
                _ratio = 0.4;
            } else {
                attack_result_text = "ERROU";
                _ratio = 0.0;
            }

            // Dano proporcional ao acerto × dano máximo já modificado pela média
            attack_damage = round(attack_damage_max * _ratio);

            // ── LÓGICA DO DANO: acontece AQUI, uma única vez ──────
            // (a mudança de estado abaixo impede este bloco de rodar de novo)
            if (instance_exists(obj_rh_battle_enemy)) {
                enemy_hp = apply_damage_to_enemy(enemy_hp, attack_damage);
                global.battle_enemy_hp = enemy_hp;
            }

            // ── Entrega para a animação (só visual) ───────────────
            anim_timer       = 0;
            anim_swing       = true;
            anim_hit         = (attack_damage > 0);
            anim_impact_done = false;
            anim_end_frame   = 0; // definido no impacto
            state = BATTLE_STATE.ATTACK_ANIM;

        } else if (attack_bar_x <= attack_lane_x1) {
            // Barra chegou ao fim sem o jogador apertar: erro, sem golpe.
            attack_state       = 1;
            attack_result_text = "ERROU";
            attack_damage      = 0;

            anim_timer       = 0;
            anim_swing       = false;
            anim_hit         = false;
            anim_impact_done = false;
            anim_end_frame   = ANIM_MISS_HOLD_DURATION;
            state = BATTLE_STATE.ATTACK_ANIM;
        }
        break;

    // ── ANIMAÇÃO DE ATAQUE ────────────────────────────────────────
    // Nenhuma entrada do jogador é lida aqui: é isso que bloqueia
    // novas ações. NENHUM dano é calculado aqui: só tempo e visual.
    //   frame 0 .. ANIM_ATTACK_DURATION        → Talai ataca
    //   frame ANIM_ATTACK_DURATION             → IMPACTO (dispara 1 vez)
    //   depois                                 → reação do inimigo + número de dano
    //   anim_end_frame                         → próximo estado
    case BATTLE_STATE.ATTACK_ANIM:
        anim_timer++;

        // Momento do impacto
        if (anim_swing && !anim_impact_done && anim_timer >= ANIM_ATTACK_DURATION) {
            anim_impact_done = true;

            if (anim_hit) {
                // Liga a reação visual no inimigo (ele mesmo desliga ao zerar o timer)
                with (obj_rh_battle_enemy) {
                    hit_duration = ANIM_ENEMY_HIT_DURATION;
                    hit_timer    = ANIM_ENEMY_HIT_DURATION;
                }
                anim_end_frame = ANIM_ATTACK_DURATION
                               + max(ANIM_ENEMY_HIT_DURATION,
                                     ANIM_DAMAGE_DELAY + ANIM_DAMAGE_DISPLAY_DURATION);
            } else {
                anim_end_frame = ANIM_ATTACK_DURATION + ANIM_MISS_HOLD_DURATION;
            }
        }

        // Fim da animação → mesmo fluxo que já existia depois do minigame
        if (anim_end_frame > 0 && anim_timer >= anim_end_frame) {
            with (obj_rh_battle_enemy) hit_timer = 0; // garante que o inimigo volta ao normal

            // Verifica vitória antes de passar o turno
            if (enemy_hp <= 0) {
                state = BATTLE_STATE.VICTORY;
            } else {
                state = BATTLE_STATE.ENEMY_TURN;
                enemy_turn_timer = enemy_turn_max_time;
                menu_option = 0;
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
		global.dialog_active = false; // ← garante input normal ao voltar

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
