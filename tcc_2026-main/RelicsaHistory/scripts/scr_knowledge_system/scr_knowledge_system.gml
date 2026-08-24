// Altere aqui para ajustar o comportamento do sistema de conhecimento
#macro KNOWLEDGE_PASS_THRESHOLD  5.0   // média mínima para bônus
#macro KNOWLEDGE_BUFF_MULTIPLIER 1.3   // multiplicador de dano com média alta
#macro KNOWLEDGE_DEBUFF_MULT     0.7   // multiplicador de dano com média baixa
#macro KNOWLEDGE_DEF_BONUS       0.85  // redução de dano recebido com média alta
#macro KNOWLEDGE_DEF_PENALTY     1.15  // aumento de dano recebido com média baixa
 
/// Registra o score de uma resposta e recalcula a média.
/// Chame após o jogador responder uma questão na batalha.
function register_answer_score(score) {
    array_push(global.knowledge_scores, score);
    global.knowledge_total = array_length(global.knowledge_scores);
 
    var total = 0;
    for (var i = 0; i < global.knowledge_total; i++) {
        total += global.knowledge_scores[i];
    }
    global.knowledge_average = total / global.knowledge_total;
 
    // Atualiza o indicador visual de progresso histórico (0-100)
    global.history_knowledge = round(global.knowledge_average * 10);
}
 
/// Retorna o modificador de ataque baseado na média atual.
/// Multiplique o dano base por este valor.
function get_attack_modifier() {
    if (global.knowledge_average > KNOWLEDGE_PASS_THRESHOLD) {
        return KNOWLEDGE_BUFF_MULTIPLIER;
    }
    return KNOWLEDGE_DEBUFF_MULT;
}
 
/// Retorna o modificador de defesa baseado na média atual.
/// Multiplique o dano recebido por este valor.
function get_defense_modifier() {
    if (global.knowledge_average > KNOWLEDGE_PASS_THRESHOLD) {
        return KNOWLEDGE_DEF_BONUS;
    }
    return KNOWLEDGE_DEF_PENALTY;
}
 
/// Retorna true se o desempenho atual é positivo (média > threshold).
function knowledge_is_passing() {
    return (global.knowledge_average > KNOWLEDGE_PASS_THRESHOLD);
}
 
/// Retorna uma string descritiva do nível de conhecimento atual.
/// Útil para exibir na UI.
function get_knowledge_label() {
    var avg = global.knowledge_average;
    if (avg >= 8.0) return "Excelente";
    if (avg >= 6.0) return "Bom";
    if (avg >= 4.0) return "Regular";
    if (avg >= 2.0) return "Fraco";
    return "Insuficiente";
}

