// ObjPlayer é persistente. Algumas salas (como rm_teste) têm um ObjPlayer COLOCADO no editor;
// ele serve para "recriar" o Talai ao voltar de uma batalha (o monstro destrói o player antes de lutar).
// Se já existe um jogador (por exemplo o que o CONTINUAR do save criou, ou o que veio de outra sala),
// esta cópia é só reserva: some na hora, antes de rodar o resto do Create.
if (instance_number(ObjPlayer) > 1) {
    instance_destroy();
    exit;
}

yspd = 0;
xspd = 0;

// Velocidade de movimento (como no projeto alternativo): CONSTANTE, sem aceleração nem deslize.
// O Talai começa e para na hora. Shift troca de default_spd para sprint_spd (lido a cada frame no Step).
default_spd = 1.5;   // andando
sprint_spd  = 2.25;  // correndo
move_spd    = default_spd;

// Movimento em pixels INTEIROS: a parte fracionária da velocidade fica guardada aqui e vai sendo
// somada (mantém o pixel art limpo e a velocidade média correta).
x_remainder = 0;
y_remainder = 0;

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