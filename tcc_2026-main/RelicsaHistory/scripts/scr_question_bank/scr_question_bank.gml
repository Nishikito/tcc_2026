/// Retorna o banco de questões de História do Brasil.
/// Cada questão tem: id, theme, period, difficulty, question, answers[]
/// Cada answer tem: text, score (0-10)
/// score 10 = muito correto | score 0 = muito inadequado
function get_question_bank() {
    return [
 
        // ── QUESTÃO 1 ────────────────────────────────────────────────
        {
            id:         "colonial_001",
            theme:      "Brasil Colonial",
            period:     "Século XVI",
            difficulty: 1,
            question:   "Qual foi o principal produto de exportação do Brasil durante o período colonial inicial?",
            answers: [
                { text: "Ouro",            score: 3  },
                { text: "Pau-brasil",       score: 10 },
                { text: "Cana-de-açúcar",  score: 6  },
                { text: "Borracha",         score: 0  }
            ]
        },
 
        // ── QUESTÃO 2 ────────────────────────────────────────────────
        {
            id:         "colonial_002",
            theme:      "Brasil Colonial",
            period:     "Século XVII",
            difficulty: 1,
            question:   "As capitanias hereditárias foram criadas com qual objetivo principal?",
            answers: [
                { text: "Organizar a defesa militar do litoral",             score: 5  },
                { text: "Distribuir terras para colonização e administração", score: 10 },
                { text: "Explorar ouro no interior do Brasil",               score: 2  },
                { text: "Estabelecer rotas comerciais com a China",          score: 0  }
            ]
        },
 
        // ── QUESTÃO 3 ────────────────────────────────────────────────
        {
            id:         "imperio_001",
            theme:      "Período Imperial",
            period:     "Século XIX",
            difficulty: 2,
            question:   "A Independência do Brasil em 1822 foi um processo que beneficiou principalmente qual grupo?",
            answers: [
                { text: "Os escravizados, que conquistaram liberdade",          score: 0  },
                { text: "A elite agrária brasileira, que manteve seus privilégios", score: 10 },
                { text: "Os indígenas, que recuperaram suas terras",            score: 0  },
                { text: "Os comerciantes portugueses radicados no Brasil",      score: 4  }
            ]
        },
 
        // ── QUESTÃO 4 ────────────────────────────────────────────────
        {
            id:         "republica_001",
            theme:      "República Velha",
            period:     "Início do Século XX",
            difficulty: 2,
            question:   "A política do café-com-leite na Primeira República representava um acordo entre:",
            answers: [
                { text: "Rio de Janeiro e Bahia",         score: 1  },
                { text: "São Paulo e Minas Gerais",       score: 10 },
                { text: "Pernambuco e Rio Grande do Sul", score: 1  },
                { text: "São Paulo e Rio de Janeiro",     score: 3  }
            ]
        },
 
        // ── QUESTÃO 5 ────────────────────────────────────────────────
        {
            id:         "moderna_001",
            theme:      "Era Vargas",
            period:     "Século XX",
            difficulty: 2,
            question:   "O Estado Novo de Getúlio Vargas (1937-1945) é caracterizado principalmente por:",
            answers: [
                { text: "Democracia plena e eleições livres",                    score: 0  },
                { text: "Centralização do poder, censura e industrialização",    score: 10 },
                { text: "Política externa de alinhamento incondicional com EUA", score: 3  },
                { text: "Reforma agrária e distribuição de terras",              score: 2  }
            ]
        }
 
        // Adicione novas questões aqui, seguindo o mesmo padrão
    ];
}
 
/// Retorna uma questão aleatória do banco.
/// Parâmetro opcional: difficulty (1, 2, 3) para filtrar por dificuldade.
/// Se não filtrar ou não encontrar, retorna qualquer questão.
function get_random_question(difficulty = -1) {
    var bank = get_question_bank();
    var filtered = [];
 
    if (difficulty > 0) {
        for (var i = 0; i < array_length(bank); i++) {
            if (bank[i].difficulty == difficulty) {
                array_push(filtered, bank[i]);
            }
        }
    }
 
    var pool = (array_length(filtered) > 0) ? filtered : bank;
    return pool[irandom(array_length(pool) - 1)];
}
 
/// Retorna o score da alternativa escolhida pelo jogador.
function get_answer_score(question, answer_index) {
    if (answer_index < 0 || answer_index >= array_length(question.answers)) return 0;
    return question.answers[answer_index].score;
}
