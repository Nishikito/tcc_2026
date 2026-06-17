text_id = "carol";

// Se a Carol já sumiu, o speakerblock também some
if (global.carol_dialogue_end == true) {
    instance_destroy();
}