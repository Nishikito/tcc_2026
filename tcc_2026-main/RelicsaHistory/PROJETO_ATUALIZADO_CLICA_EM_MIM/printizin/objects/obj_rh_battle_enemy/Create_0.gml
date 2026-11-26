// ══════════════════════════════════════════════════════════════════
// INIMIGO BASE — cada inimigo é um OBJETO FILHO (obj_rh_en_*) com a própria ficha e os próprios ataques
// ──────────────────────────────────────────────────────────────────
// A room tem UM obj_rh_battle_enemy (marcador de posição). Ao nascer, ele olha o inimigo da
// batalha (get_rh_enemy_object) e, se houver um objeto próprio, cria esse objeto no mesmo lugar e some.
// Os filhos chamam event_inherited(): aí object_index já não é obj_rh_battle_enemy e o resto
// deste Create roda normalmente (posição, escala e variáveis padrão), e o filho só sobrescreve o que é dele.
// Se não houver objeto próprio (ex.: "MathMonster"), este mesmo objeto é o inimigo antigo (tiro mirado).
// ══════════════════════════════════════════════════════════════════
var _obj = get_rh_enemy_object(global.current_enemy_id);
if (object_index == obj_rh_battle_enemy && _obj != obj_rh_battle_enemy) {
    instance_create_layer(x, y, layer, _obj);
    instance_destroy();
    exit;
}

// ── FICHA DO INIMIGO ──────────────────────────────────────────────
// Os filhos (obj_rh_en_*) sobrescrevem estes valores. O controller lê nome e HP daqui na batalha.
enemy_name   = "Inimigo";
enemy_max_hp = 200;
dmg_min      = DMG_ENEMY_BASE_MIN;   // dano por ataque (antes de defesa/média)
dmg_max      = DMG_ENEMY_BASE_MAX;

// ── POSIÇÃO / ESCALA ──────────────────────────────────────────────
// O sprite é encaixado na área do inimigo (ENEMY_MAX_W x ENEMY_MAX_H), centrado onde a room o colocou.
// A transição de batalha calcula o mesmo encaixe pelo sprite do objeto (obj_battle_transition).
// enemy_anchor_x/y guardam o ponto da room: os filhos podem mudar o tamanho depois
// do event_inherited() sem deslocar o inimigo.
enemy_anchor_x  = x;
enemy_anchor_y  = y;
enemy_size_mult = 1;
var _fit = min(ENEMY_MAX_W / sprite_get_width(sprite_index),
               ENEMY_MAX_H / sprite_get_height(sprite_index));
image_xscale = _fit;
image_yscale = _fit;
// O ponto onde a room colocou o marcador é o CENTRO do inimigo. Reposiciona pela origem do sprite:
// sprites com origem no canto (0,0), como Carumaru, Apressador, Juiz e Trono, ficavam fora da tela / em cima do HUD.
x -= (sprite_get_width(sprite_index)  / 2 - sprite_get_xoffset(sprite_index)) * _fit;
y -= (sprite_get_height(sprite_index) / 2 - sprite_get_yoffset(sprite_index)) * _fit;
image_speed  = 0;   // a troca de quadros do idle é feita à mão no Step (idle_frame_time)
tempo        = 0;
centro_y     = y;

// Chamado pelos filhos após event_inherited(): 1 = tamanho original,
// 0.4 = 60% menor, 0.75 = 25% menor, 1.05 = 5% maior.
// Recalcula o encaixe e reposiciona mantendo o centro da room como âncora.
set_enemy_size = function(_mult) {
    enemy_size_mult = _mult;
    var _escala = min(ENEMY_MAX_W / sprite_get_width(sprite_index),
                      ENEMY_MAX_H / sprite_get_height(sprite_index)) * _mult;
    image_xscale = _escala;
    image_yscale = _escala;
    x = enemy_anchor_x - (sprite_get_width(sprite_index)  / 2 - sprite_get_xoffset(sprite_index)) * _escala;
    y = enemy_anchor_y - (sprite_get_height(sprite_index) / 2 - sprite_get_yoffset(sprite_index)) * _escala;
    centro_y = y;
};
// Aplica o multiplicador do objeto (a transição lê a mesma função).
set_enemy_size(get_rh_enemy_size(object_index));

// ── TIRO MIRADO ANTIGO ────────────────────────────────────────────
// Só vale para o inimigo sem padrões (patterns = []). Os obj_rh_en_* fazem alarm[0] = -1.
cadencia     = 40;    // frames entre tiros (mais baixo = mais tiros)
spd_bala     = 2.5;   // pixels por frame
alarm[0]     = cadencia + irandom(cadencia);

// ── Reação de dano (VISUAL) ───────────────────────────────────────
// O controller liga isto no momento do impacto (hit_timer = duração).
// O Step desconta 1 por frame; o Draw usa hit_timer para tremer/piscar.
// hit_timer == 0  →  inimigo normal.
hit_timer    = 0;
hit_duration = 1; // nunca 0 (evita divisão por zero); é sobrescrito pelo controller

// ── Variações por inimigo (os filhos obj_rh_en_* mudam estes valores) ──
sway_y          = 20;      // amplitude da oscilação vertical no turno inimigo (pixels)
sway_angle      = 15;      // amplitude da rotação no turno inimigo (graus)
idle_timer      = 0;
idle_frame_time = 14;      // frames de jogo por quadro do idle (só vale p/ sprites com >1 quadro)
spr_hit         = noone;   // sprite de dano (noone = usa o slot ANIM_SLOT_ENEMY_HIT_SPRITE)
spr_defeated    = noone;   // sprite mostrado na vitória (noone = continua o sprite normal)

// ── Padrões de ataque ──────────────────────────────────────────────
// patterns = array de funções function(_t). Cada turno inimigo roda UM padrão,
// na ordem (0, 1, 2) só no 1º ciclo, para o jogador conhecer cada ataque; depois a ordem
// é sorteada (sem repetir o mesmo padrão duas vezes seguidas). _t = frames desde a caixa abrir (1, 2, 3...).
// Array vazio = comportamento antigo (Alarm 0 atira uma bala mirada).
patterns        = [];
pattern_index   = 0;
pattern_last    = -1;   // índice do último padrão usado (para não repetir seguido)
pattern_timer   = 0;
pattern_running = false;
pattern_current = undefined;
pattern_names   = [];       // opcional: nomes dos padrões, só para o RH_DEBUG
turn_empty_frames     = 0;  // diagnóstico: frames do turno sem nenhum ataque ativo
turn_empty_streak     = 0;
turn_max_empty_streak = 0;

// ── Ajudantes para os padrões ──────────────────────────────────────
// Convertem um ponto do sprite (em pixels do ARQUIVO, contados do canto superior esquerdo,
// ex.: "a trouxa fica em 14,46") para a posição real na room, já com escala e origem.
enemy_px = function(_fx) { return x + (_fx - sprite_get_xoffset(sprite_index)) * image_xscale; }
enemy_py = function(_fy) { return y + (_fy - sprite_get_yoffset(sprite_index)) * image_yscale; }
