// Timer da mensagem de feedback do item — roda em qualquer estado
if (item_msg_timer > 0) item_msg_timer--;

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

                case 1: // ITEM → abre a lista de consumíveis
                    if (array_length(global.inventory_consumables) == 0) {
                        item_msg       = "Nenhum item disponivel.";
                        item_msg_timer = 90;
                    } else {
                        item_sel      = 0;
                        item_view_top = 0;
                        item_msg      = "";
                        item_msg_timer = 0;
                        state = BATTLE_STATE.ITEM_MENU;
                    }
                    break;

                case 2: // DEFENDER — reduz dano recebido neste turno
                    state = BATTLE_STATE.ENEMY_TURN;
                    enemy_turn_timer = enemy_turn_max_time;
                    item_used_name = "";
                    break;
            }
        }
        break;

    // ── MENU DE ITENS ─────────────────────────────────────────────
    case BATTLE_STATE.ITEM_MENU:
        var _inv = global.inventory_consumables;
        var _len = array_length(_inv);

        if (_len <= 0) {
            state          = BATTLE_STATE.MENU;
            menu_option    = 1;
            item_msg       = "Nenhum item disponivel.";
            item_msg_timer = 90;
            break;
        }

        if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(global.key_up)) {
            item_sel = max(0, item_sel - 1);
        }
        if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(global.key_down)) {
            item_sel = min(_len - 1, item_sel + 1);
        }

        if (item_sel < item_view_top) {
            item_view_top = item_sel;
        }
        if (item_sel > item_view_top + item_rows_visible - 1) {
            item_view_top = item_sel - item_rows_visible + 1;
        }

        item_view_top = clamp(
            item_view_top,
            0,
            max(0, _len - item_rows_visible)
        );

        if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(ord("Z"))) {
            var _item = _inv[item_sel];

            var _eh_cura = false;
            if (_item.effect == "effect_erva_cura") _eh_cura = true;

            if (_eh_cura && global.hp >= global.max_hp) {
                item_msg       = "HP ja esta cheio!";
                item_msg_timer = 90;
            } else {
                item_used_name = _item.name;

                scr_inventory_use(global.inventory_consumables, item_sel);

                var _new_len = array_length(global.inventory_consumables);

                if (_new_len <= 0) {
                    item_sel      = 0;
                    item_view_top = 0;
                } else {
                    item_sel = min(item_sel, _new_len - 1);
                    item_view_top = clamp(
                        item_view_top,
                        0,
                        max(0, _new_len - item_rows_visible)
                    );
                }

                item_msg       = "";
                item_msg_timer = 0;
                state            = BATTLE_STATE.ENEMY_TURN;
                enemy_turn_timer = enemy_turn_max_time;
                menu_option      = 0;
            }
        }

        if (keyboard_check_pressed(vk_escape) || keyboard_check_pressed(ord("X"))) {
            state          = BATTLE_STATE.MENU;
            menu_option    = 1;
            item_msg       = "";
            item_msg_timer = 0;
        }
        break;

    // ── QUESTÃO ───────────────────────────────────────────────────
    case BATTLE_STATE.QUESTION:
        if (keyboard_check_pressed(vk_down) || keyboard_check_pressed(global.key_down)) {
            selected_option = (selected_option + 1) % 4;
        }

        if (keyboard_check_pressed(vk_up) || keyboard_check_pressed(global.key_up)) {
            selected_option--;

            if (selected_option < 0) {
                selected_option = 3;
            }
        }

        if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(ord("Z"))) {
            last_answer_score = get_answer_score(
                current_question,
                selected_option
            );

            register_answer_score(last_answer_score);

            attack_damage_max = calculate_player_damage_max(
                last_answer_score
            );

            var _mod_label = "↓ Penalidade de ataque.";

            if (get_attack_modifier() >= 1.0) {
                _mod_label = "↑ Bônus de ataque!";
            }

            result_text =
                "Média: "
                + string_format(global.knowledge_average, 1, 1)
                + " ("
                + get_knowledge_label()
                + ")  "
                + _mod_label
                + "  |  Dano máx: "
                + string(attack_damage_max);

            result_timer = result_timer_max;
            state = BATTLE_STATE.QUESTION_RESULT;
        }
        break;

    // ── RESULTADO DA QUESTÃO ──────────────────────────────────────
    case BATTLE_STATE.QUESTION_RESULT:
        result_timer--;

        if (result_timer <= 0) {
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
        var _box_x1   = 20;
        var _target_x = _box_x1 + 20;

        if (attack_state == 0) {
            attack_bar_x -= attack_bar_speed;

            if (
                keyboard_check_pressed(vk_enter)
                || keyboard_check_pressed(ord("Z"))
            ) {
                attack_state = 1;
                attack_timer = 50;

                var _dist = abs(attack_bar_x - _target_x);
                var _ratio = 0.0;

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

                attack_damage = round(
                    attack_damage_max * _ratio
                );

                if (instance_exists(obj_rh_battle_enemy)) {
                    enemy_hp = apply_damage_to_enemy(
                        enemy_hp,
                        attack_damage
                    );

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
                if (enemy_hp <= 0) {
                    state = BATTLE_STATE.VICTORY;
                } else {
                    state = BATTLE_STATE.ENEMY_TURN;
                    enemy_turn_timer = enemy_turn_max_time;
                    menu_option = 0;
                    item_used_name = "";
                }
            }
        }
        break;

    // ── TURNO DO INIMIGO ──────────────────────────────────────────
    case BATTLE_STATE.ENEMY_TURN:
        enemy_turn_timer--;

        if (global.hp <= 0) {
            with (obj_rh_battle_bullet) instance_destroy();

            state = BATTLE_STATE.DEFEAT;
            break;
        }

        if (enemy_turn_timer <= 0) {
            with (obj_rh_battle_bullet) instance_destroy();

            state = BATTLE_STATE.MENU;
            menu_option = 0;
            item_used_name = "";
        }
        break;

    // ── VITÓRIA ───────────────────────────────────────────────────
    case BATTLE_STATE.VICTORY:
        if (
            keyboard_check_pressed(vk_enter)
            || keyboard_check_pressed(ord("Z"))
        ) {
            global.battle_result = "victory";
            global.dialog_active = false;

            if (!variable_global_exists("defeated_enemies")) {
                global.defeated_enemies = [];
            }

            var _already = false;

            for (
                var i = 0;
                i < array_length(global.defeated_enemies);
                i++
            ) {
                if (
                    global.defeated_enemies[i]
                    == global.current_enemy_id
                ) {
                    _already = true;
                    break;
                }
            }

            if (!_already) {
                array_push(
                    global.defeated_enemies,
                    global.current_enemy_id
                );
            }

            room_goto(global.pre_battle_room);
        }
        break;

    // ── DERROTA ───────────────────────────────────────────────────
    case BATTLE_STATE.DEFEAT:
        if (
            keyboard_check_pressed(vk_enter)
            || keyboard_check_pressed(ord("Z"))
        ) {
            global.battle_result = "defeat";
            global.pre_battle_hp = global.max_hp;

            room_goto(global.pre_battle_room);
        }
        break;
}