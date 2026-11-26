if (image_index <= 0.1) {
    global.fade_active = false;

    // RoomClass1_1: o pensamento do Talai entra assim que o fade de abertura clareia.
    // Fica aqui (e não num trigger) porque o player ainda pode estar em qualquer posição.
    if (room == RoomClass1_1) {
        create_textbox("historia_acordar");
        global.dialog_active = true;
    }

    instance_destroy();
}