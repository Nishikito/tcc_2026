if (global.carol_disappeared == true) {
    instance_destroy();
    exit;
}

npc_state = "idle";
npc_face = LEFT;
dialog_finished = false;
move_speed = 0.8;
target_x = x + 64;

sprite[RIGHT] = SprCarolRight;
sprite[LEFT] = SprCarolLeft;
sprite[DOWN] = SprCarol;
face = LEFT;

cutscene_active = false;
cutscene_actions = [];
current_action = 0;
cutscene_timer = 0;

