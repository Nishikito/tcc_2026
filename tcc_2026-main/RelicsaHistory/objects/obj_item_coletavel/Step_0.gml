if (!coletado && place_meeting(x, y, ObjPlayer) &&  keyboard_check_pressed(vk_enter) &&  !global.dialog_active) {
    create_textbox(text_id);
    global.dialog_active = true;
    coletado = true;
    instance_destroy(); // some do chão após a interação
}