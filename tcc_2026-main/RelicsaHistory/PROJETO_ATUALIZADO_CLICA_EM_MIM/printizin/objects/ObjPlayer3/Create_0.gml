// voltando de batalha: o player já foi recriado, então o do editor some
if (global.battle_return && instance_number(ObjPlayer) > 1) { instance_destroy(); exit; }
x_remainder = 0;
y_remainder = 0;
// Velocidade de movimento
yspd = 0;
xspd = 0;
move_spd = 1.5;
sprint_spd = 2.25;
default_spd = 1.5;

// Sprites por direção
sprite[RIGHT] = SprPlayerRight;
sprite[UP] = SprPlayerUp;
sprite[LEFT] = SprPlayerLeft;
sprite[DOWN] = SprPlayer;
sprite_carol_defeat = SprPlayerDown;

// Direção inicial
face = UP;

// Posição salva antes de entrar numa batalha
pre_battle_x = x;
pre_battle_y = y;
pre_battle_room = room;

// ── Restaura HP se está voltando de uma luta ──
if (variable_global_exists("pre_battle_hp") && global.pre_battle_hp > 0) {
    global.hp = global.pre_battle_hp;
    global.pre_battle_hp = 0;
}

// Timer de invencibilidade após tomar dano
recovery_timer = 0;

// ── SISTEMA DE PARTY / SEGUIDOR ─────────────────────────
pos_history = [];
follow_delay = 16; // Distância de passos entre o jogador e o seguidor