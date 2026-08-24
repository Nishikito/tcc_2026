// ── CONFIGURAÇÕES DE DANO ─────────────────────────────────────────
// Altere aqui para balancear o jogo
#macro DMG_PLAYER_BASE_MIN  10   // dano mínimo do jogador ao inimigo
#macro DMG_PLAYER_BASE_MAX  20   // dano máximo do jogador ao inimigo
#macro DMG_ENEMY_BASE_MIN    5   // dano mínimo do inimigo ao jogador
#macro DMG_ENEMY_BASE_MAX   12   // dano máximo do inimigo ao jogador
#macro DMG_SCORE_SCALE      0.5  // quanto o score da resposta afeta o dano (0=nada, 1=total)
 
/// Calcula o dano que o jogador causa ao inimigo.
/// answer_score: score da alternativa escolhida (0-10)
/// Retorna: dano final já com modificador de conhecimento aplicado
function calculate_player_damage(answer_score) {
    // Dano base aleatório dentro do intervalo configurado
    var base = irandom_range(DMG_PLAYER_BASE_MIN, DMG_PLAYER_BASE_MAX);
 
    // Bônus do score da resposta: score 10 = +50% do intervalo, score 0 = 0%
    var score_bonus = (answer_score / 10) * (DMG_PLAYER_BASE_MAX - DMG_PLAYER_BASE_MIN) * DMG_SCORE_SCALE;
 
    // Modificador de conhecimento (média histórica)
    var knowledge_mod = get_attack_modifier();
 
    var final_damage = round((base + score_bonus) * knowledge_mod);
    return max(1, final_damage);  // dano mínimo de 1
}
 
/// Calcula o dano que o inimigo causa ao jogador.
/// Aplica modificador de defesa baseado na média de conhecimento.
/// Retorna: dano final já com modificador de defesa aplicado
function calculate_enemy_damage() {
    var base = irandom_range(DMG_ENEMY_BASE_MIN, DMG_ENEMY_BASE_MAX);
    var defense_mod = get_defense_modifier();
    var final_damage = round(base * defense_mod);
    return max(1, final_damage);  // dano mínimo de 1
}
 
/// Aplica dano ao jogador de forma segura.
/// Garante que HP não vai abaixo de 0.
function apply_damage_to_player(damage) {
    global.hp = max(0, global.hp - damage);
}
 
/// Aplica dano ao inimigo de forma segura.
/// enemy_hp_var: variável local do obj_math_battle que armazena o HP do inimigo
/// Retorna o HP resultante
function apply_damage_to_enemy(current_hp, damage) {
    return max(0, current_hp - damage);
}
 
/// Aplica cura ao jogador de forma segura.
/// Garante que HP não ultrapassa max_hp.
function apply_heal_to_player(amount) {
    global.hp = min(global.max_hp, global.hp + amount);
}
