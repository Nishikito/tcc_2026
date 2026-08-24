// Simula 3 respostas e verifica a média
register_answer_score(8);
register_answer_score(6);
register_answer_score(4);
// global.knowledge_average deve ser 6.0
// get_attack_modifier() deve retornar 1.3 (média > 5)
// get_knowledge_label() deve retornar "Bom"
show_message(
    "Média: " + string(global.knowledge_average) + "\n" +
    "Mod ataque: " + string(get_attack_modifier()) + "\n" +
    "Label: " + get_knowledge_label()
);
