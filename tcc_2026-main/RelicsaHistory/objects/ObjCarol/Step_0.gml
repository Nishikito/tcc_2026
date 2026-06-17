if (global.carol_disappeared == true) {
    instance_destroy();
    exit;
}

carol_step_cutscene();

if (npc_state == "idle") {
    sprite_index = sprite[npc_face];
}
