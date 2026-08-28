yspd = 0;
xspd = 0;

move_spd    = 1.5;
sprint_spd  = 2.25;
default_spd = 1.5;

sprite[RIGHT] = SprPlayerRight;
sprite[UP]    = SprPlayerUp;
sprite[LEFT]  = SprPlayerLeft;
sprite[DOWN]  = SprPlayer;
sprite_carol_defeat = SprPlayerDown;
face = UP;

recovery_timer = 0;

// Restaura HP se voltando de batalha
if (variable_global_exists("pre_battle_hp") && global.pre_battle_hp > 0) {
    global.hp          = global.pre_battle_hp;
    global.pre_battle_hp = 0;
}

// Restaura posição se voltando de batalha
if (variable_global_exists("pre_battle_x") && global.pre_battle_x != 0) {
    x = global.pre_battle_x;
    y = global.pre_battle_y;
    global.pre_battle_x = 0;
    global.pre_battle_y = 0;
}

// Empurra o player para fora de qualquer colisão no spawn
var raio = 4;
while (place_meeting(x, y, ObjWall) && raio < 128) {
    if (!place_meeting(x + raio, y, ObjWall)) { x += raio; break; }
    if (!place_meeting(x - raio, y, ObjWall)) { x -= raio; break; }
    if (!place_meeting(x, y + raio, ObjWall)) { y += raio; break; }
    if (!place_meeting(x, y - raio, ObjWall)) { y -= raio; break; }
    raio += 4;
}