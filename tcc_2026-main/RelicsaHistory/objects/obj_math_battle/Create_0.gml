depth = -1000;

if(!variable_global_exists("defeated_enemies")) {
    global.defeated_enemies = [];
}
if(room != rm_math_battle) {
    instance_destroy();
    exit;
}

if(variable_global_exists("current_enemy_id") && global.current_enemy_id != "") {
    var enemy_data = get_enemy_data(global.current_enemy_id);
    enemy_name_text = enemy_data.name;
    enemy_max_hp = enemy_data.max_hp;
    enemy_current_hp = enemy_data.current_hp;
    enemy_difficulty = enemy_data.difficulty;
    enemy_sprite = enemy_data.sprite;
} else {
    enemy_name_text = "Inimigo Desconhecido";
    enemy_max_hp = 50;
    enemy_current_hp = 50;
    enemy_difficulty = "easy";
    enemy_sprite = noone;
}

player_lives = global.max_lives;
global.math_battle_active = true;

current_question = "";
correct_answer = 0;
answers = [];
selected_option = 0;
question_answered = false;

if(enemy_name_text == "Carol") {
    answer_timer = 600;
    max_answer_time = 600;
} else {
    var difficulty_settings = get_difficulty_settings(enemy_difficulty);
    answer_timer = difficulty_settings.time_limit;
    max_answer_time = difficulty_settings.time_limit;
}

battle_state = "question";
result_timer = 0;

camera_x = camera_get_view_x(view_camera[0]);
camera_y = camera_get_view_y(view_camera[0]);

damage_shake = 0;
heart_shake_timer = 0;
hp_shake_timer = 0;

timer_display = answer_timer;
hp_display = enemy_current_hp;

ui_center_x = 160;
ui_width = 320;
question_y = 30;
timer_w = 260;
timer_h = 14;
option_box_w = 140;
option_box_h = 36;
option_spacing_x = 152;
option_spacing_y = 52;
option_start_y = 100;
heart_spacing = 36;
heart_draw_scale = 1;

is_carol_battle = (enemy_name_text == "Carol");
carol_question_number = 0;
carol_first_time = false;
carol_defeat_processed = false;
battle_ended = false;

if(is_carol_battle) {
    if(!variable_global_exists("carol_battle_completed")) {
        global.carol_battle_completed = false;
    }
    if(!global.carol_battle_completed) {
        carol_first_time = true;
        carol_question_number = 0;
    }
}

function generate_carol_special_question() {
    switch(carol_question_number) {
        case 0:
            current_question = "1 + 1";
            correct_answer = 2;
            answers = [2, 3, 1, 4];
            break;
        case 1:
            current_question = "1 - 1";
            correct_answer = 0;
            answers = [0, 1, -1, 2];
            break;
        case 2:
            current_question = "f(x) = ln(int_0^pi sin^2(x) dx)";
            correct_answer = 42;
            answers = ["???", "???", "???", "???"];
            break;
    }

    if(carol_question_number < 2) {
        answers = shuffle_array(answers);
    }

    answer_timer = max_answer_time;
    selected_option = 0;
    question_answered = false;
    battle_state = "question";
}

function generate_new_question() {
    if(is_carol_battle && carol_first_time) {
        generate_carol_special_question();
    } else if(enemy_name_text == "Carol") {
        var problem_data = generate_math_problem_by_difficulty("easy");
        current_question = problem_data[0];
        correct_answer = problem_data[1];
        
        var wrong_answers = generate_wrong_answers(correct_answer);
        answers = [correct_answer, wrong_answers[0], wrong_answers[1], wrong_answers[2]];
        answers = shuffle_array(answers);
        
        answer_timer = 600;
        max_answer_time = 600;
        selected_option = 0;
        question_answered = false;
        battle_state = "question";
    } else {
        var problem_data = generate_math_problem_by_difficulty(enemy_difficulty);
        current_question = problem_data[0];
        correct_answer = problem_data[1];
        
        var wrong_answers = generate_wrong_answers(correct_answer);
        answers = [correct_answer, wrong_answers[0], wrong_answers[1], wrong_answers[2]];
        answers = shuffle_array(answers);
        
        var difficulty_settings = get_difficulty_settings(enemy_difficulty);
        answer_timer = difficulty_settings.time_limit;
        max_answer_time = difficulty_settings.time_limit;
        selected_option = 0;
        question_answered = false;
        battle_state = "question";
    }
}

function end_math_battle(success) {
    if(success) {
        global.math_battle_active = false;
        global.dialog_active = false;
        global.fade_active = false;
        
        if(variable_global_exists("current_enemy_id") && global.current_enemy_id != "") {
            var enemy_found = false;
            for(var i = 0; i < array_length(global.defeated_enemies); i++) {
                if(global.defeated_enemies[i] == global.current_enemy_id) {
                    enemy_found = true;
                    break;
                }
            }
            
            if(!enemy_found) {
                array_push(global.defeated_enemies, global.current_enemy_id);
            }
        }
        
        global.current_enemy_id = "";
        
        if(instance_exists(ObjPlayer)) {
            with(ObjPlayer) {
                global.dialog_active = false;
                global.fade_active = false;
            }
            
            room_goto(ObjPlayer.pre_battle_room);
        } else {
            room_goto(global.previous_room);
        }
        
        instance_destroy();
    } else {
        global.math_battle_active = false;
        global.dialog_active = false;
        global.fade_active = false;
        global.current_enemy_id = "";
        
        if(variable_instance_exists(id, "room_on_defeat") && room_exists(room_on_defeat)) {
            room_goto(room_on_defeat);
        } else {
            room_goto(RoomTeachersAbandoned);
        }
        instance_destroy();
    }
}

function check_carol_battle() {
    if(enemy_name_text == "Carol") {
        is_carol_battle = true;
        if(!variable_global_exists("carol_battle_completed")) {
            global.carol_battle_completed = false;
        }
        if(!global.carol_battle_completed) {
            carol_first_time = true;
            carol_question_number = 0;
        }
    }
}

alarm[0] = 1;
generate_new_question();