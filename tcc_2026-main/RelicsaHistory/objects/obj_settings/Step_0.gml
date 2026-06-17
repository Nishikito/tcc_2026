
if (room == RoomTeachersAbandoned && global.carol_defeated && !carol_transition_done) {
    carol_transition_done = true;

    global.player_knocked_down = true;
    global.fade_active = true;
    if (!instance_exists(obj_fade_intro)) {
        instance_create_layer(0, 0, "Instances", obj_fade_intro);
    }
    if (instance_exists(ObjPlayer)) {
        ObjPlayer.x = 160;
        ObjPlayer.y = 120;
    }
}

if (global.carol_defeated && !global.fade_active && !instance_exists(obj_fade_intro)) {
    global.carol_defeated = false;
    carol_transition_done = false;
}

