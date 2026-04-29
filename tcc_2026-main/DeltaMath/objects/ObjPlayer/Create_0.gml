yspd = 0;
xspd = 0;

move_spd= 1.5;
sprint_spd = 2.25;
default_spd = 1.5;

sprite[RIGHT] = SprPlayerRight;
sprite[UP] = SprPlayerUp;
sprite[LEFT] = SprPlayerLeft;
sprite[DOWN] = SprPlayer;
sprite_carol_defeat = SprPlayerDown;
face = UP;

pre_battle_x = x;
pre_battle_y = y;
pre_battle_room = room;


recovery_timer = 0;

// Empurra o player para fora de qualquer colisão no spawn
var raio = 4;
while (place_meeting(x, y, ObjWall) && raio < 128) {
    if (!place_meeting(x + raio, y, ObjWall)) { x += raio; break; }
    if (!place_meeting(x - raio, y, ObjWall)) { x -= raio; break; }
    if (!place_meeting(x, y + raio, ObjWall)) { y += raio; break; }
    if (!place_meeting(x, y - raio, ObjWall)) { y -= raio; break; }
    raio += 4;
}