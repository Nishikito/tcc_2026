camera_x = camera_get_view_x(view_camera[0]);
camera_y = camera_get_view_y(view_camera[0]);

if(damage_shake > 0) damage_shake--;
if(heart_shake_timer > 0) heart_shake_timer--;
if(hp_shake_timer > 0) hp_shake_timer--;

switch(battle_state) {
    case "question":
        if(!question_answered) {
            var old_option = selected_option;
            
            if(keyboard_check_pressed(ord("W")) || keyboard_check_pressed(vk_up)) {
                if(selected_option >= 2) selected_option -= 2;
                else selected_option += 2;
            }
            
            if(keyboard_check_pressed(ord("S")) || keyboard_check_pressed(vk_down)) {
                if(selected_option <= 1) selected_option += 2;
                else selected_option -= 2;
            }
            
            if(keyboard_check_pressed(ord("A")) || keyboard_check_pressed(vk_left)) {
                if(selected_option % 2 == 1) selected_option--;
                else selected_option++;
            }
            
            if(keyboard_check_pressed(ord("D")) || keyboard_check_pressed(vk_right)) {
                if(selected_option % 2 == 0) selected_option++;
                else selected_option--;
            }
            
            if(old_option != selected_option) {
                audio_play_sound(sfxSwitch, 0, false);
            }
            
            if(keyboard_check_pressed(vk_enter)) {
                question_answered = true;
                audio_play_sound(sfxSelect, 0, false);
                
                if(answers[selected_option] == correct_answer) {
                    var damage = irandom_range(15, 25);
                    
                    if(is_carol_battle && carol_first_time && carol_question_number == 2) {
                        player_lives = 0;
                        heart_shake_timer = 60;
                        damage_shake = 30;
                        battle_state = "defeat";
                    } else {
                        enemy_current_hp -= damage;
                        hp_shake_timer = 30;
                        
                        if(enemy_current_hp <= 0) {
                            enemy_current_hp = 0;
                            battle_state = "victory";
                        } else {
                            battle_state = "result";
                            result_timer = 120;
                        }
                    }
                } else {
                    if(is_carol_battle && carol_first_time && carol_question_number == 2) {
                        player_lives = 0;
                        heart_shake_timer = 60;
                        damage_shake = 30;
                        battle_state = "defeat";
                    } else {
                        player_lives--;
                        heart_shake_timer = 30;
                        damage_shake = 15;
                        
                        if(player_lives <= 0) {
                            battle_state = "defeat";
                        } else {
                            battle_state = "result";
                            result_timer = 120;
                        }
                    }
                }
            }
            
            answer_timer--;
            if(answer_timer <= 0) {
                question_answered = true;
                
                if(is_carol_battle && carol_first_time && carol_question_number == 2) {
                    player_lives = 0;
                    heart_shake_timer = 60;
                    damage_shake = 30;
                    battle_state = "defeat";
                } else {
                    player_lives--;
                    heart_shake_timer = 30;
                    damage_shake = 15;
                    
                    if(player_lives <= 0) {
                        battle_state = "defeat";
                    } else {
                        battle_state = "result";
                        result_timer = 120;
                    }
                }
            }
        }
        break;
        
    case "result":
        result_timer--;
        if(result_timer <= 0) {
            if(is_carol_battle && carol_first_time) {
                carol_question_number++;
                
                if(carol_question_number <= 2) {
                    generate_new_question();
                } else {
                    global.carol_battle_completed = true;
                    carol_first_time = false;
                    generate_new_question();
                }
            } else {
                generate_new_question();
            }
        }
        break;
        
	case "victory":
	    if(keyboard_check_pressed(vk_enter)) {
	        if(is_carol_battle && carol_first_time) {
	        }
	        end_math_battle(true);
	    }
	    break;
        
    case "defeat":
        if(keyboard_check_pressed(vk_enter)) {
            if(is_carol_battle && carol_first_time && !carol_defeat_processed) {
                global.carol_battle_completed = true;
                carol_defeat_processed = true;
                global.carol_defeated = true;
                global.fade_active = true;
                global.math_battle_active = false;
                global.dialog_active = false;
                room_goto(RoomTeachersAbandoned);
            } else {
                end_math_battle(false);
            }
        }
        break;
}