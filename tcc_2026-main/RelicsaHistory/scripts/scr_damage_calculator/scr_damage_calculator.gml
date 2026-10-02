#macro DMG_PLAYER_BASE_MIN  10
#macro DMG_PLAYER_BASE_MAX  30
#macro DMG_ENEMY_BASE_MIN    2//alterado para possibildade de um combate mais longevo para o pitch
#macro DMG_ENEMY_BASE_MAX    6//mesma coisa do acima
#macro DMG_SCORE_SCALE       0.5

// ── MINIGAME DE ATAQUE ────────────────────────────────────────────
// Velocidade da barra em pixels por frame. FIXA: não muda durante a partida.
// (antes: 7 no Create e 9 no QUESTION_RESULT, o do Create nunca era usado)
#macro ATTACK_BAR_SPEED        5

// Meia-largura de cada faixa de acerto, em pixels, PARA MÉDIA NEUTRA.
// Na prática ela é multiplicada por get_attack_modifier() (1.3 ou 0.7).
// Distância do centro do alvo até a barra: <= PERFECT = 100% do dano,
// <= GREAT = 75%, <= OK = 40%, acima disso erra.
#macro ATTACK_ZONE_PERFECT     8
#macro ATTACK_ZONE_GREAT      20
#macro ATTACK_ZONE_OK         36

function calculate_player_damage_max(answer_score) {
    var base_max    = DMG_PLAYER_BASE_MAX;
    var score_bonus = (answer_score / 10.0)
                    * (DMG_PLAYER_BASE_MAX - DMG_PLAYER_BASE_MIN)
                    * DMG_SCORE_SCALE;
    var knowledge_mod = get_attack_modifier();
    return round((base_max + score_bonus) * knowledge_mod);
}

function calculate_player_damage(answer_score) {
    var base        = irandom_range(DMG_PLAYER_BASE_MIN, DMG_PLAYER_BASE_MAX);
    var score_bonus = (answer_score / 10.0)
                    * (DMG_PLAYER_BASE_MAX - DMG_PLAYER_BASE_MIN)
                    * DMG_SCORE_SCALE;
    var knowledge_mod = get_attack_modifier();
    return max(1, round((base + score_bonus) * knowledge_mod));
}

function calculate_enemy_damage() {
    var base = irandom_range(DMG_ENEMY_BASE_MIN, DMG_ENEMY_BASE_MAX);
    return max(1, round(base * get_defense_modifier()));
}

function apply_damage_to_player(damage) {
    global.hp = max(0, global.hp - damage);
}

function apply_damage_to_enemy(current_hp, damage) {
    return max(0, current_hp - damage);
}

function apply_heal_to_player(amount) {
    global.hp = min(global.max_hp, global.hp + amount);
}


// ══════════════════════════════════════════════════════════════════
// ANIMAÇÃO DE ATAQUE (estado BATTLE_STATE.ATTACK_ANIM)
// ──────────────────────────────────────────────────────────────────
// TODOS os tempos abaixo são em FRAMES. O jogo roda a 60 fps:
//     60 frames = 1 segundo | 30 = 0,5 s | 12 = 0,2 s
// Mexeu aqui, mexeu na animação inteira — não há valores soltos
// em outros arquivos. Manual: seção "ONDE EU MEXO?".
// ══════════════════════════════════════════════════════════════════

// ── Fase 1: Talai ataca (do clique até o IMPACTO) ─────────────────
#macro ANIM_ATTACK_DURATION          20   // frames até o impacto. MAIOR = ataque mais lento
#macro ANIM_TALAI_WINDUP_PIXELS       8   // quanto o Talai recua antes de avançar
#macro ANIM_TALAI_LUNGE_PIXELS      120   // quanto o Talai avança até o inimigo
#macro ANIM_TALAI_RETURN_FRAMES      12   // frames que o Talai leva para voltar à posição

// ── Fase 2: impacto e reação do inimigo ───────────────────────────
#macro ANIM_FX_DURATION              14   // duração do efeito de impacto (corte)
#macro ANIM_ENEMY_HIT_DURATION       30   // duração da reação do inimigo. MAIOR = reação mais lenta
#macro ANIM_ENEMY_HIT_SHAKE_PIXELS    6   // amplitude da tremida (px)
#macro ANIM_ENEMY_HIT_FLASH_FRAMES    3   // frames por piscada vermelha

// ── Fase 3: número de dano ────────────────────────────────────────
#macro ANIM_DAMAGE_DELAY              6   // frames ENTRE o impacto e o número aparecer
#macro ANIM_DAMAGE_DISPLAY_DURATION  45   // quanto tempo o número fica na tela
#macro ANIM_DAMAGE_RISE_PIXELS       14   // quanto o número sobe

// ── Errou ─────────────────────────────────────────────────────────
#macro ANIM_MISS_HOLD_DURATION       40   // tempo parado mostrando "ERROU" antes de seguir

// ══════════════════════════════════════════════════════════════════
// SLOTS DE SPRITE — PREENCHER QUANDO O ARTISTA ENTREGAR
// ──────────────────────────────────────────────────────────────────
// Enquanto estiver `noone`, a animação usa o visual procedural
// (Talai com SprPlayerDown, corte desenhado por linhas, inimigo
// tremendo e piscando em vermelho). Para usar um sprite, troque
// `noone` pelo NOME do sprite, ex.:  #macro ANIM_SLOT_ATTACK_FX_SPRITE  spr_slash
// O sprite precisa já existir no projeto, senão o jogo não compila.
// A velocidade abaixo é "frames do sprite por frame do jogo"
// (0.5 = troca de imagem a cada 2 frames do jogo; 1 = a cada frame).
// ══════════════════════════════════════════════════════════════════
#macro ANIM_SLOT_TALAI_ATTACK_SPRITE   spr_talaiB_attack   // Talai atacando (substitui SprPlayerDown no golpe)
#macro ANIM_SLOT_ATTACK_FX_SPRITE      noone   // efeito de corte/impacto sobre o inimigo
#macro ANIM_SLOT_ENEMY_HIT_SPRITE      spr_caravela//provisorio   // inimigo tomando dano (substitui spr_rh_battle_enemy)

#macro ANIM_TALAI_ATTACK_SPRITE_SPEED  0.5
#macro ANIM_ATTACK_FX_SPRITE_SPEED     0.5
#macro ANIM_ENEMY_HIT_SPRITE_SPEED     0.5

