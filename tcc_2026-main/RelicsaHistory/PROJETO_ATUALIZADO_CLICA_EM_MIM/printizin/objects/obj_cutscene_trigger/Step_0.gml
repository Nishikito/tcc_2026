if (once && variable_struct_exists(global.scenes_done, scene_id)) { instance_destroy(); exit; }
if (global.dialog_active || global.fade_active || global.cutscene_active || global.math_battle_active) exit;
if (!place_meeting(x, y, ObjPlayer)) exit;
if (interact && !keyboard_check_pressed(vk_enter)) exit;

if (once) variable_struct_set(global.scenes_done, scene_id, true);
cutscene_play(scene_id);