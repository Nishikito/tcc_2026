#macro DMG_PLAYER_BASE_MIN  10
#macro DMG_PLAYER_BASE_MAX  30
#macro DMG_ENEMY_BASE_MIN    2//alterado para possibildade de um combate mais longevo para o pitch
#macro DMG_ENEMY_BASE_MAX    6//mesma coisa do acima
#macro ENEMY_MAX_W 100   // área livre à direita da caixa (x 205..320)
#macro ENEMY_MAX_H 130   // acima do HUD (que começa em y=170)
#macro DMG_SCORE_SCALE       0.5

// ── DEFENDER ──────────────────────────────────────────────────────
// Redução BASE de dano ao escolher DEFENDER (0.40 = 40%). Na prática ela é
// multiplicada por get_attack_modifier() (1.3 ou 0.7), igual ao dano do jogador:
//   média > 5  → 0.40 * 1.3 = 52% de redução  (fator 0.48)
//   média <= 5 → 0.40 * 0.7 = 28% de redução  (fator 0.72)
#macro DEFEND_REDUCTION      0.40

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

// Fator de dano recebido ao DEFENDER (0.48 com média alta, 0.72 com média baixa).
// Reaproveita get_attack_modifier(): UMA fonte para "o quanto a média pesa".
function get_defend_factor() {
    return 1 - DEFEND_REDUCTION * get_attack_modifier();
}

// Dano de UMA bala no jogador. Os fatores se EMPILHAM (multiplicam):
//   dano = sorteio(dmg_min..dmg_max) × modificador passivo (0.85 / 1.15)
//                                    × fator de DEFENDER (só se estiver defendendo)
function calculate_enemy_damage() {
    var _d    = get_rh_enemy_data(global.current_enemy_id);
    var _base = irandom_range(_d.dmg_min, _d.dmg_max);
    var _mult = get_defense_modifier();

    if (instance_exists(obj_rh_battle_controller) && obj_rh_battle_controller.is_defending) {
        _mult *= get_defend_factor();
    }
    return max(1, round(_base * _mult));
}

// ── DADOS POR INIMIGO (batalha RH) ────────────────────────────────
// Um lugar só para o balanceamento de cada inimigo. Para criar um novo:
// copie um bloco "case", troque o ID (o mesmo do enemy_id do objeto do mapa)
// e ajuste os números. IDs não listados caem no "default".
// (O get_enemy_data do scr_enemy_data é do sistema ANTIGO de matemática.)
function get_rh_enemy_data(enemy_id) {
    switch (enemy_id) {
        case "MathMonster":
            return {
                name:         "Inimigo",
                max_hp:       50,
                dmg_min:      DMG_ENEMY_BASE_MIN,   // dano por bala (antes da defesa)
                dmg_max:      DMG_ENEMY_BASE_MAX,
                cadence:      40,                   // frames entre tiros (mais baixo = mais tiros)
                bullet_speed: 2.5                   // pixels por frame
            };
        default:
            return {
                name:         "Inimigo",
                max_hp:       50,
                dmg_min:      DMG_ENEMY_BASE_MIN,
                dmg_max:      DMG_ENEMY_BASE_MAX,
                cadence:      40,
                bullet_speed: 2.5
            };
    }
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
#macro ANIM_ATTACK_WINDUP_FRAMES     10   // frames "preparando" (Talai recua) antes de soltar o orbe
#macro ANIM_PROJECTILE_TRAVEL_FRAMES 14   // frames do orbe viajando até o inimigo. MAIOR = orbe mais lento
#macro ANIM_ATTACK_DURATION          (ANIM_ATTACK_WINDUP_FRAMES + ANIM_PROJECTILE_TRAVEL_FRAMES)   // até o IMPACTO (calculado, não edite)
#macro ANIM_ATTACK_POSE_HOLD_FRAMES  18   // frames que o Talai segura a pose de ataque (livro) depois de soltar o orbe
#macro ANIM_TALAI_WINDUP_PIXELS       8   // quanto o Talai recua ao preparar o ataque
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

// ── Projétil do Talai (orbe que sai do livro) ─────────────────────
#macro ANIM_PROJECTILE_SCALE         1.5  // tamanho do orbe (o Talai é desenhado em 1.5)
#macro ANIM_PROJECTILE_BOOK_OFFSET_X  54  // onde o orbe nasce, contado a partir do Talai (ponta do livro)
#macro ANIM_PROJECTILE_BOOK_OFFSET_Y  25  //   (36 x 16.5 do sprite de ataque, vezes 1.5)
#macro ANIM_PROJECTILE_FLIES_ON_MISS true // true = se ERRAR, o orbe passa direto pelo inimigo | false = não sai

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
#macro ANIM_SLOT_PROJECTILE_SPRITE     spr_talaiB_projectle   // orbe lançado pelo livro (aponta para a DIREITA)
#macro ANIM_SLOT_ATTACK_FX_SPRITE      noone   // efeito de corte/impacto sobre o inimigo
#macro ANIM_SLOT_ENEMY_HIT_SPRITE      spr_caravela//provisorio   // inimigo tomando dano (substitui spr_rh_battle_enemy)

#macro ANIM_TALAI_ATTACK_SPRITE_SPEED  0.5

// ── TALAI ATINGIDO (por bala do inimigo) ──────────────────────────
#macro ANIM_TALAI_HIT_DURATION        24   // frames mostrando o sprite de dano. MAIOR = fica mais tempo
#macro ANIM_TALAI_HIT_SHAKE_PIXELS     2   // amplitude da tremidinha (px). 0 = sem tremer
#macro ANIM_SLOT_TALAI_HIT_SPRITE     spr_talaiB_damage   // Talai tomando dano
#macro ANIM_ATTACK_FX_SPRITE_SPEED     0.5
#macro ANIM_ENEMY_HIT_SPRITE_SPEED     0.5


// ══════════════════════════════════════════════════════════════════
// BATTLE BOX — abertura/fechamento (obj_rh_battle_box)
// ──────────────────────────────────────────────────────────────────
// A caixa abre durante o ENEMY_TURN e fecha nos outros estados.
// O coração e os tiros do inimigo só funcionam com ela 100% aberta.
// ══════════════════════════════════════════════════════════════════
#macro BOX_ANIM_FRAMES     26        // frames para abrir (e para fechar). MENOR = mais rápida
#macro BOX_SPIN_DEGREES   360        // graus que ela gira enquanto abre (0 = não gira)
#macro BOX_TRAIL_COUNT      4        // cópias do rastro (0 = sem rastro)
#macro BOX_TRAIL_ALPHA    0.4        // transparência da cópia mais próxima da caixa
#macro BOX_BORDER_PIXELS    1        // espessura da borda do sprite: o coração fica DENTRO dela
#macro BOX_TINT       c_white        // cor multiplicada sobre o sprite (c_white = cor original)


// ══════════════════════════════════════════════════════════════════
// UI DA BATALHA (HUD) — sprites e cores
// ──────────────────────────────────────────────────────────────────
// O controller guarda a LÓGICA (menu_option, state...). Estes macros dizem
// QUAL SPRITE representa cada peça. Trocar a arte = apontar o macro.
// ══════════════════════════════════════════════════════════════════
#macro UI_SLOT_PANEL_SPRITE    spr_bt_panel   // moldura dos painéis: frame 0 = compacto | frame 1 = alto. Origem: canto SUPERIOR ESQUERDO
#macro UI_SLOT_COMMAND_SPRITE  spr_bt_cmd     // ícones de comando 17x13: frames 0-3 normais | 4-7 selecionados (mesma ordem)
#macro UI_PANEL_CAP_PIXELS     10             // largura das pontas da moldura (não esticam)
#macro UI_PANEL_CAP_VERTICAL     6             // altura das pontas da moldura (não esticam). Moldura mínima = 2 x isto
#macro UI_SLOT_CURSOR_SPRITE   spr_heart_cursor   // cursor das listas (coração 9x9)
#macro UI_CURSOR_BOB_PIXELS    2              // quanto o cursor balança para cima/baixo (0 = parado)
#macro UI_CURSOR_BOB_SPEED     0.12           // velocidade do balanço (mesma do menu de pause)
#macro UI_SLOT_AVG_BAR_BASE_SPRITE  spr_tp_base   // barra vertical de MÉDIA: fundo (10x90, origem canto superior esquerdo)
#macro UI_SLOT_AVG_BAR_FILL_SPRITE  spr_tp_fill   // barra vertical de MÉDIA: preenchimento (mesmo tamanho do fundo)
#macro UI_AVG_BAR_X                 4             // posição da barra de média na GUI
#macro UI_AVG_BAR_Y                 36
#macro UI_COLOR_SELECTED       make_color_rgb(0, 174, 240)   // azul do comando selecionado
#macro UI_COLOR_HP_LABEL       make_color_rgb(255, 220, 60)  // amarelo do rótulo "HP"
