text_id = "carol";

// Se a Carol já sumiu, o speakerblock também some
if (global.carol_dialogo_fim == true) {
    instance_destroy();
}