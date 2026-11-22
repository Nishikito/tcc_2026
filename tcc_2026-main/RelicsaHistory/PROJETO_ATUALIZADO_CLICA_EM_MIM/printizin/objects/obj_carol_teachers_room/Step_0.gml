var _s = id;
if place_meeting(x+20,y+20,ObjPlayer) and keyboard_check_pressed(vk_enter) and !global.dialog_active {
 
    if (player_said_yes) {
        global.current_enemy_id = "Carol"; 
        global.previous_room = room;
        room_goto(rm_math_battle);
    } else {
        create_textbox(text_id);
        global.dialog_active = true;
    }
}