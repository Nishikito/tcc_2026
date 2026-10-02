yspd = 0;
xspd = 0;

// Velocidades ALVO: andando e correndo
default_spd = 1.5;
sprint_spd  = 2.25;

// move_spd agora é a velocidade ATUAL (suavizada). Começa em 0 (parado) e
// sobe/desce até a velocidade alvo. Quem move o player é ela.
move_spd    = 0;

// Ajustes do "feeling" — mexa aqui:
spd_accel      = 0.10; // ganho por frame (0 -> andar em ~15 frames, andar -> correr em ~8)
spd_decel      = 0.45; // perda por frame ao soltar (2.25 -> 0 em ~5 frames). Valor alto = para seco
run_anim_boost = 0.30; // quanto a animação acelera correndo (1.0 = andando, 1.3 = correndo)

// Última direção pedida: usada para deslizar um pouco ao soltar as teclas
last_dir_x = 0;
last_dir_y = 0;

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