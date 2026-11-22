function init_carol_cutscene() {
    // Dados da cutscene da Carol
    global.carol_cutscene = {
        trigger_global: "carol_dialog_finished",
        npc_object: ObjCarol,
        actions: [
            {
                type: "walk",
                target_x: 356,
                speed: 0.5,
                direction: "right"
            },
            {
                type: "destroy_at_x",
                x_position: 356,
                set_global: "carol_disappeared"
            }
        ]
    };
}

function process_carol_cutscene() {
    if (global.carol_dialog_finished == true) {
        start_carol_cutscene();
        global.carol_dialog_finished = false;
    }
}

function start_carol_cutscene() {
    with (ObjCarol) {
        if (!cutscene_active) {
            cutscene_active = true;
            cutscene_actions = global.carol_cutscene.actions;
            current_action = 0;
            cutscene_timer = 0;
        }
    }
}

function carol_step_cutscene() {
    if (cutscene_active && current_action < array_length(cutscene_actions)) {
        var action = cutscene_actions[current_action];
        
        switch (action.type) {
            case "walk":
                execute_walk_action(action);
                break;
                
            case "destroy_at_x":
                execute_destroy_at_x_action(action);
                break;
        }
    }
}

function execute_walk_action(action) {
    npc_state = "walking";
    target_x = action.target_x;
    move_speed = action.speed;
    npc_face = RIGHT;
    sprite_index = sprite[RIGHT];
    
    if (x < target_x) {
        x += move_speed;
    } else {
        npc_state = "idle";
        current_action++;
    }
}

function execute_destroy_at_x_action(action) {
    if (x >= action.x_position) {
        global.carol_disappeared = true;
        instance_destroy();
    }
}