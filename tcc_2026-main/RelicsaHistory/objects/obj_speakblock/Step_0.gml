var _s = id;

if place_meeting(x,y,ObjPlayer) and keyboard_check_pressed(vk_enter) and !global.dialog_active {
	create_textbox(text_id);
	global.dialog_active = true;
}