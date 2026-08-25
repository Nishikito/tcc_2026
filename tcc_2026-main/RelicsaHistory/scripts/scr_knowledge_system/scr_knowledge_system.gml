#macro KNOWLEDGE_PASS_THRESHOLD  5.0
#macro KNOWLEDGE_BUFF_MULTIPLIER 1.3
#macro KNOWLEDGE_DEBUFF_MULT     0.7
#macro KNOWLEDGE_DEF_BONUS       0.85
#macro KNOWLEDGE_DEF_PENALTY     1.15

function register_answer_score(score) {
    array_push(global.knowledge_scores, score);
    global.knowledge_total = array_length(global.knowledge_scores);
    var total = 0;
    for (var i = 0; i < global.knowledge_total; i++) {
        total += global.knowledge_scores[i];
    }
    global.knowledge_average = total / global.knowledge_total;
    global.history_knowledge = round(global.knowledge_average * 10);
}

function get_attack_modifier() {
    if (global.knowledge_average > KNOWLEDGE_PASS_THRESHOLD) return KNOWLEDGE_BUFF_MULTIPLIER;
    return KNOWLEDGE_DEBUFF_MULT;
}

function get_defense_modifier() {
    if (global.knowledge_average > KNOWLEDGE_PASS_THRESHOLD) return KNOWLEDGE_DEF_BONUS;
    return KNOWLEDGE_DEF_PENALTY;
}

function get_knowledge_label() {
    var avg = global.knowledge_average;
    if (avg >= 8.0) return "Excelente";
    if (avg >= 6.0) return "Bom";
    if (avg >= 4.0) return "Regular";
    if (avg >= 2.0) return "Fraco";
    return "Insuficiente";
}