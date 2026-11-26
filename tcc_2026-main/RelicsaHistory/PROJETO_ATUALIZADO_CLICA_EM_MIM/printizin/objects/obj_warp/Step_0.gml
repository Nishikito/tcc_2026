// Anti-loop: após uma transição o jogador pode nascer em cima deste warp
// (a máscara está esticada com scaleX). Só libera quando ele sai de todos.
if (!variable_global_exists("warp_suppressed")) global.warp_suppressed = false;
if (global.warp_suppressed) exit;

if place_meeting(x, y, ObjPlayer) and !instance_exists(obj_fade){
	global.warp_suppressed = true;
	var instantiated = instance_create_depth(0, 0, -99999, obj_fade)
	instantiated.target_x = target_x
	instantiated.target_y = target_y
	instantiated.target_room = target_room
}
