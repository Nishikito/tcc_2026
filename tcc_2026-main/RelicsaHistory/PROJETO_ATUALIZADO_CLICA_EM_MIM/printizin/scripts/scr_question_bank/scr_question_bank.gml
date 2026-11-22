/// ════════════════════════════════════════════════════════════════════
/// BANCO DE QUESTÕES — História do Brasil (40 questões, só o que ocorreu no Brasil)
/// Questões 1-12 = fácil (1) | 13-26 = média (2) | 27-40 = difícil (3)
/// Cada resposta tem score (10, 7, 4 ou 1); a melhor resposta vale 10.
/// ════════════════════════════════════════════════════════════════════

#macro QUIZ_AVG_HARD    8.0   // média >= 8  -> perguntas difíceis
#macro QUIZ_AVG_MEDIUM  5.0   // média >= 5  -> perguntas médias; abaixo -> fáceis

/// Dados brutos das questões (alternativas na ordem padrão do acervo).
function get_question_bank() {
    return [
        {
            id: "q01",
            difficulty: 1,
            question: "Em 1500, a esquadra portuguesa que chegou ao litoral do atual Brasil era comandada por:",
            answers: [
                { text: "Pedro Álvares Cabral", score: 10 },
                { text: "Cristóvão Colombo", score: 1 },
                { text: "Vasco da Gama", score: 1 },
                { text: "Pero Vaz de Caminha, escrivão da frota", score: 4 }
            ]
        },
        {
            id: "q02",
            difficulty: 1,
            question: "Em que ano os portugueses chegaram ao Brasil?",
            answers: [
                { text: "1492", score: 4 },
                { text: "1500", score: 10 },
                { text: "1530, quando começou a colonização efetiva", score: 7 },
                { text: "1822", score: 1 }
            ]
        },
        {
            id: "q03",
            difficulty: 1,
            question: "Antes da chegada dos portugueses, o território do atual Brasil era habitado por:",
            answers: [
                { text: "Ninguém: a terra estava vazia", score: 1 },
                { text: "Imigrantes europeus e asiáticos", score: 1 },
                { text: "Muitos povos indígenas, com línguas e modos de vida diferentes", score: 10 },
                { text: "Povos indígenas, todos com os mesmos costumes", score: 4 }
            ]
        },
        {
            id: "q04",
            difficulty: 1,
            question: "Qual foi o primeiro produto explorado pelos portugueses no litoral brasileiro?",
            answers: [
                { text: "Cana-de-açúcar", score: 7 },
                { text: "Ouro", score: 4 },
                { text: "Café", score: 1 },
                { text: "Pau-brasil", score: 10 }
            ]
        },
        {
            id: "q05",
            difficulty: 1,
            question: "O escambo, praticado no início da colonização, era:",
            answers: [
                { text: "A troca de mercadorias, como machados e espelhos, pelo trabalho indígena no corte do pau-brasil", score: 10 },
                { text: "A troca de produtos, sem envolver trabalho algum", score: 4 },
                { text: "A compra de produtos com moedas de ouro", score: 1 },
                { text: "O pagamento de impostos à Coroa", score: 1 }
            ]
        },
        {
            id: "q06",
            difficulty: 1,
            question: "As capitanias hereditárias foram:",
            answers: [
                { text: "Terras entregues aos chefes indígenas", score: 1 },
                { text: "Faixas de terra entregues a donatários, que deviam povoá-las e administrá-las", score: 10 },
                { text: "A divisão do Brasil entre Portugal e Espanha", score: 1 },
                { text: "Faixas de terra entregues a nobres, sem nenhuma obrigação", score: 4 }
            ]
        },
        {
            id: "q07",
            difficulty: 1,
            question: "Qual foi a primeira capital do Brasil, sede do Governo-Geral?",
            answers: [
                { text: "São Paulo", score: 1 },
                { text: "Rio de Janeiro", score: 4 },
                { text: "Salvador", score: 10 },
                { text: "Brasília", score: 1 }
            ]
        },
        {
            id: "q08",
            difficulty: 1,
            question: "Quem foi o primeiro governador-geral do Brasil, em 1549?",
            answers: [
                { text: "Getúlio Vargas", score: 1 },
                { text: "Dom Pedro I", score: 1 },
                { text: "Duarte Coelho, donatário de Pernambuco", score: 4 },
                { text: "Tomé de Sousa", score: 10 }
            ]
        },
        {
            id: "q09",
            difficulty: 1,
            question: "Qual foi a principal atividade econômica do litoral nordestino nos séculos XVI e XVII?",
            answers: [
                { text: "A produção de açúcar", score: 10 },
                { text: "A indústria têxtil", score: 1 },
                { text: "A produção de café", score: 1 },
                { text: "A mineração de ouro", score: 4 }
            ]
        },
        {
            id: "q10",
            difficulty: 1,
            question: "O engenho colonial era:",
            answers: [
                { text: "Uma aldeia indígena", score: 1 },
                { text: "A propriedade que produzia açúcar, com plantação de cana, moenda e casa de fervura", score: 10 },
                { text: "Uma fábrica de tecidos", score: 1 },
                { text: "Apenas a máquina que moía a cana", score: 7 }
            ]
        },
        {
            id: "q11",
            difficulty: 1,
            question: "Quem trabalhava nos engenhos de açúcar durante a colonização?",
            answers: [
                { text: "Apenas indígenas escravizados", score: 7 },
                { text: "Trabalhadores livres assalariados", score: 4 },
                { text: "Principalmente africanos escravizados", score: 10 },
                { text: "Imigrantes italianos", score: 1 }
            ]
        },
        {
            id: "q12",
            difficulty: 1,
            question: "O que era um quilombo?",
            answers: [
                { text: "Uma prisão para escravizados", score: 1 },
                { text: "Uma fazenda de açúcar", score: 1 },
                { text: "Uma comunidade de resistência formada apenas por indígenas", score: 4 },
                { text: "Uma comunidade formada por pessoas escravizadas que fugiam e resistiam à escravidão", score: 10 }
            ]
        },
        {
            id: "q13",
            difficulty: 2,
            question: "O Quilombo dos Palmares, o mais famoso do período colonial, ficava na:",
            answers: [
                { text: "Serra da Barriga, no atual estado de Alagoas", score: 10 },
                { text: "Região das minas, em Minas Gerais", score: 4 },
                { text: "Região Sul, perto da fronteira com a Espanha", score: 1 },
                { text: "Floresta Amazônica", score: 1 }
            ]
        },
        {
            id: "q14",
            difficulty: 2,
            question: "Qual foi o papel dos jesuítas no Brasil colonial?",
            answers: [
                { text: "Defender os interesses dos senhores de engenho", score: 4 },
                { text: "Catequizar indígenas, criando escolas e aldeamentos", score: 10 },
                { text: "Comercializar pau-brasil", score: 1 },
                { text: "Comandar os exércitos da colônia", score: 1 }
            ]
        },
        {
            id: "q15",
            difficulty: 2,
            question: "Os bandeirantes foram:",
            answers: [
                { text: "Soldados que defendiam o litoral", score: 4 },
                { text: "Exploradores do interior que ampliaram o território da colônia", score: 7 },
                { text: "Paulistas que entravam no sertão capturando indígenas e procurando ouro e pedras preciosas", score: 10 },
                { text: "Missionários que fundavam aldeias", score: 1 }
            ]
        },
        {
            id: "q16",
            difficulty: 2,
            question: "A pecuária ajudou a ocupar o interior do Nordeste porque:",
            answers: [
                { text: "O gado era criado nos engenhos", score: 4 },
                { text: "Os rebanhos eram trazidos da Europa em navios", score: 1 },
                { text: "Os indígenas proibiram o gado no litoral", score: 1 },
                { text: "O gado era criado no sertão, longe das plantações de cana do litoral", score: 10 }
            ]
        },
        {
            id: "q17",
            difficulty: 2,
            question: "No século XVII, os holandeses ocuparam parte do Nordeste. Quem foi Maurício de Nassau?",
            answers: [
                { text: "O governante holandês que administrou o Brasil Holandês e desenvolveu o Recife", score: 10 },
                { text: "O donatário da capitania de São Vicente", score: 1 },
                { text: "O líder do Quilombo dos Palmares", score: 1 },
                { text: "O governador-geral português na Bahia", score: 4 }
            ]
        },
        {
            id: "q18",
            difficulty: 2,
            question: "Em que região do Brasil foi descoberto ouro no final do século XVII?",
            answers: [
                { text: "Em Goiás e Mato Grosso, já no século XVIII", score: 7 },
                { text: "Em Minas Gerais", score: 10 },
                { text: "Na Amazônia", score: 1 },
                { text: "No litoral de São Paulo", score: 4 }
            ]
        },
        {
            id: "q19",
            difficulty: 2,
            question: "Com a mineração, a capital da colônia foi transferida de Salvador para:",
            answers: [
                { text: "Recife", score: 1 },
                { text: "São Paulo", score: 1 },
                { text: "O Rio de Janeiro", score: 10 },
                { text: "Ouro Preto", score: 4 }
            ]
        },
        {
            id: "q20",
            difficulty: 2,
            question: "O quinto, cobrado na região das minas, era:",
            answers: [
                { text: "Uma taxa paga pelos escravizados", score: 1 },
                { text: "Um imposto de 50% sobre toda a produção", score: 1 },
                { text: "Um imposto de 10% pago à Igreja", score: 4 },
                { text: "Um imposto de 20% sobre o ouro, pago à Coroa portuguesa", score: 10 }
            ]
        },
        {
            id: "q21",
            difficulty: 2,
            question: "As Casas de Fundição serviam para:",
            answers: [
                { text: "Transformar o ouro em barras e cobrar o quinto", score: 10 },
                { text: "Guardar o ouro sem cobrar impostos", score: 4 },
                { text: "Ensinar ofícios aos escravizados", score: 1 },
                { text: "Fabricar armas", score: 1 }
            ]
        },
        {
            id: "q22",
            difficulty: 2,
            question: "A Inconfidência Mineira (1789) foi:",
            answers: [
                { text: "Uma invasão holandesa", score: 1 },
                { text: "Uma conspiração em Minas Gerais contra os impostos e a dominação portuguesa", score: 10 },
                { text: "Uma revolta de mineradores contra o quinto, sem ideias de independência", score: 7 },
                { text: "Uma revolta de agricultores do Nordeste", score: 4 }
            ]
        },
        {
            id: "q23",
            difficulty: 2,
            question: "Tiradentes é lembrado como:",
            answers: [
                { text: "Líder do Quilombo dos Palmares", score: 4 },
                { text: "Rei de Portugal", score: 1 },
                { text: "Participante da Inconfidência Mineira, condenado e executado em 1792", score: 10 },
                { text: "Primeiro governador-geral do Brasil", score: 1 }
            ]
        },
        {
            id: "q24",
            difficulty: 2,
            question: "A derrama era:",
            answers: [
                { text: "Um festival religioso", score: 1 },
                { text: "A distribuição de terras aos mineradores", score: 1 },
                { text: "A cobrança de impostos sobre o açúcar", score: 4 },
                { text: "A cobrança forçada de impostos atrasados em Minas Gerais", score: 10 }
            ]
        },
        {
            id: "q25",
            difficulty: 2,
            question: "Como era a sociedade da região das minas?",
            answers: [
                { text: "Mais urbana e variada, com mineradores, comerciantes, artesãos e escravizados", score: 10 },
                { text: "Formada apenas por grandes fazendeiros", score: 4 },
                { text: "Formada somente por indígenas", score: 1 },
                { text: "Formada somente por funcionários da Coroa", score: 1 }
            ]
        },
        {
            id: "q26",
            difficulty: 2,
            question: "O que aconteceu com a população do interior do Brasil durante o ciclo do ouro?",
            answers: [
                { text: "Cresceu um pouco, apenas entre os portugueses", score: 4 },
                { text: "Cresceu muito, atraindo pessoas de várias regiões e de Portugal", score: 10 },
                { text: "Não mudou", score: 1 },
                { text: "Diminuiu, pois todos foram para o litoral", score: 1 }
            ]
        },
        {
            id: "q27",
            difficulty: 3,
            question: "Zumbi dos Palmares é lembrado em 20 de novembro, o Dia da Consciência Negra, porque:",
            answers: [
                { text: "Foi um dos senhores de engenho do Nordeste", score: 1 },
                { text: "Foi um bandeirante paulista", score: 4 },
                { text: "Foi um dos principais líderes da resistência negra à escravidão", score: 10 },
                { text: "Foi o primeiro governador-geral", score: 1 }
            ]
        },
        {
            id: "q28",
            difficulty: 3,
            question: "A escravidão indígena e a africana na América portuguesa:",
            answers: [
                { text: "foram utilizadas em períodos distintos e também simultâneos, com diferenças legais, regionais e nas formas de captura e exploração.", score: 7 },
                { text: "a escravização indígena permaneceu em várias áreas, enquanto o tráfico atlântico ganhou centralidade crescente no abastecimento de mão de obra escravizada.", score: 4 },
                { text: "assumiram configurações diversas ao longo da colonização, sendo influenciadas por interesses econômicos, legislação, conflitos e resistências.", score: 1 },
                { text: "coexistiram em diferentes momentos e regiões, mas a expansão do tráfico atlântico ampliou a escravização de africanos na economia colonial.", score: 10 }
            ]
        },
        {
            id: "q29",
            difficulty: 3,
            question: "A resistência à escravidão na América portuguesa incluiu:",
            answers: [
                { text: "fugas, formação de quilombos, revoltas, negociações, práticas religiosas e preservação de referências culturais, entre outras estratégias.", score: 10 },
                { text: "formas variadas de enfrentamento à escravidão, desde recusas cotidianas e fugas até movimentos organizados e manutenção de vínculos culturais.", score: 4 },
                { text: "estratégias de sobrevivência e contestação que podiam ser abertas ou cotidianas, individuais ou coletivas, conforme as condições históricas.", score: 1 },
                { text: "ações coletivas e individuais que incluíram resistência armada, criação de comunidades autônomas e busca por espaços de negociação.", score: 7 }
            ]
        },
        {
            id: "q30",
            difficulty: 3,
            question: "O Quilombo dos Palmares é historicamente significativo porque:",
            answers: [
                { text: "constituiu um espaço de autonomia e proteção para pessoas que resistiam à escravização, enfrentando repetidas campanhas coloniais.", score: 4 },
                { text: "teve importância histórica por desafiar a ordem escravista e demonstrar a capacidade de organização política e social de comunidades negras.", score: 1 },
                { text: "foi uma experiência duradoura de resistência à escravidão e à ordem colonial, formada por comunidades diversas e capaz de sustentar organização própria.", score: 10 },
                { text: "reuniu diferentes comunidades e lideranças ao longo do tempo, tornando-se uma referência importante de resistência à escravidão.", score: 7 }
            ]
        },
        {
            id: "q31",
            difficulty: 3,
            question: "Como os povos indígenas reagiram à colonização?",
            answers: [
                { text: "Apenas lutando contra os portugueses", score: 4 },
                { text: "Aceitando tudo sem reagir", score: 1 },
                { text: "De várias formas: lutas armadas, fugas, alianças e negociações", score: 10 },
                { text: "Apenas fugindo para a Europa", score: 1 }
            ]
        },
        {
            id: "q32",
            difficulty: 3,
            question: "A Guerra dos Emboabas (1707-1709) foi um conflito:",
            answers: [
                { text: "Entre holandeses e portugueses em Pernambuco", score: 4 },
                { text: "Entre indígenas e portugueses pelo litoral", score: 1 },
                { text: "Entre escravizados e senhores de engenho", score: 1 },
                { text: "Entre paulistas e forasteiros pelo controle das áreas de mineração", score: 10 }
            ]
        },
        {
            id: "q33",
            difficulty: 3,
            question: "A Revolta de Vila Rica (1720), associada a Filipe dos Santos, relacionou-se principalmente:",
            answers: [
                { text: "à contestação de medidas administrativas da Coroa que afetavam a produção, a circulação do ouro e os interesses dos mineradores.", score: 4 },
                { text: "à insatisfação de setores locais com a intensificação da fiscalização e com as formas de cobrança de tributos sobre o ouro.", score: 7 },
                { text: "às tensões entre autoridades metropolitanas e grupos coloniais diante do aumento do controle fiscal nas regiões mineradoras.", score: 1 },
                { text: "à oposição a medidas fiscais e ao controle metropolitano sobre a mineração, especialmente à instalação das casas de fundição.", score: 10 }
            ]
        },
        {
            id: "q34",
            difficulty: 3,
            question: "A mudança da capital colonial de Salvador para o Rio de Janeiro, em 1763, relacionou-se:",
            answers: [
                { text: "à reorganização das prioridades políticas e econômicas da Coroa, diante do peso crescente das regiões meridionais na colônia.", score: 4 },
                { text: "à crescente importância econômica e estratégica do Centro-Sul, especialmente pela proximidade das áreas mineradoras e das rotas de circulação do ouro.", score: 10 },
                { text: "ao deslocamento do eixo administrativo para uma área considerada mais estratégica para a defesa e a fiscalização dos interesses portugueses.", score: 1 },
                { text: "à necessidade de aproximar a administração colonial dos principais espaços de mineração e de reforçar o controle sobre o Centro-Sul.", score: 7 }
            ]
        },
        {
            id: "q35",
            difficulty: 3,
            question: "O ciclo do ouro mudou o centro econômico da colônia:",
            answers: [
                { text: "Do Norte para o litoral", score: 1 },
                { text: "Do interior para a Europa", score: 4 },
                { text: "Do Nordeste açucareiro para a região Sudeste, em torno das minas", score: 10 },
                { text: "Do Sudeste para o Sul", score: 1 }
            ]
        },
        {
            id: "q36",
            difficulty: 3,
            question: "Por que a Coroa portuguesa criou o Governo-Geral em 1548?",
            answers: [
                { text: "Para dar autonomia aos donatários", score: 4 },
                { text: "Para acabar com a colonização do Brasil", score: 1 },
                { text: "Para entregar o Brasil aos holandeses", score: 1 },
                { text: "Para centralizar a administração e a defesa da colônia, já que as capitanias tinham problemas", score: 10 }
            ]
        },
        {
            id: "q37",
            difficulty: 3,
            question: "A mineração alterou a dinâmica social da colônia porque:",
            answers: [
                { text: "favoreceu o crescimento de vilas e de atividades comerciais e artesanais, sem eliminar desigualdades de condição jurídica e riqueza.", score: 7 },
                { text: "ampliou a circulação de pessoas, a vida urbana e a diversidade de ocupações, mas manteve a escravidão e profundas hierarquias sociais.", score: 10 },
                { text: "criou oportunidades de trabalho e mobilidade para alguns grupos, ao mesmo tempo que reforçou mecanismos de exploração e distinção social.", score: 4 },
                { text: "diversificou as relações sociais nas regiões mineradoras, embora a concentração de riqueza e a escravidão continuassem estruturando a sociedade.", score: 1 }
            ]
        },
        {
            id: "q38",
            difficulty: 3,
            question: "Quem foi Domingos Jorge Velho, que atuou no final do século XVII?",
            answers: [
                { text: "Líder de Palmares", score: 1 },
                { text: "Bandeirante contratado para destruir o Quilombo dos Palmares", score: 10 },
                { text: "Governador holandês de Pernambuco", score: 1 },
                { text: "Donatário de Pernambuco", score: 4 }
            ]
        },
        {
            id: "q39",
            difficulty: 3,
            question: "A Estrada Real era:",
            answers: [
                { text: "Uma estrada que levava gado para o litoral", score: 1 },
                { text: "Uma estrada que ligava o Nordeste ao Sul para levar açúcar", score: 4 },
                { text: "Um caminho usado para transportar o ouro de Minas Gerais até os portos, como Paraty e Rio de Janeiro", score: 10 },
                { text: "Um caminho feito para a família real de Portugal viajar", score: 1 }
            ]
        },
        {
            id: "q40",
            difficulty: 3,
            question: "A fiscalização metropolitana sobre o ouro revela uma característica do sistema colonial:",
            answers: [
                { text: "o uso de mecanismos administrativos para supervisionar uma atividade econômica estratégica e ampliar a arrecadação da monarquia.", score: 1 },
                { text: "a articulação entre administração colonial e interesses fiscais, que condicionava a extração e a circulação legal do ouro.", score: 4 },
                { text: "o esforço da Coroa para controlar a produção aurífera e assegurar receitas por meio de tributos, registros e instituições fiscalizadoras.", score: 10 },
                { text: "a tentativa metropolitana de reduzir o contrabando e garantir que parte da riqueza mineral fosse transferida ao Estado português.", score: 7 }
            ]
        }
    ];
}

/// Inicializa o estado do sorteio (chamado automaticamente na 1ª pergunta).
function quiz_init() {
    if (variable_global_exists("quiz_ready") && global.quiz_ready) return;
    global.quiz_ready = true;
    global.quiz_bank  = get_question_bank();
    global.quiz_piles = [[], [], [], []];   // índice = dificuldade (1..3): fila embaralhada
    global.quiz_last  = [-1, -1, -1, -1];   // última questão sorteada por dificuldade
    // Por questão: posições (0-3) já usadas pela resposta correta; a 1ª exibição é a ordem padrão
    global.quiz_used_pos = array_create(array_length(global.quiz_bank), undefined);
    for (var i = 0; i < array_length(global.quiz_bank); i++) global.quiz_used_pos[i] = [];
}

/// Dificuldade (1 fácil, 2 média, 3 difícil) conforme a média de conhecimento.
function get_quiz_difficulty() {
    var _avg = variable_global_exists("knowledge_average") ? global.knowledge_average : 0;
    if (_avg >= QUIZ_AVG_HARD)   return 3;
    if (_avg >= QUIZ_AVG_MEDIUM) return 2;
    return 1;
}

/// Posição (0-3) da resposta correta (a de maior score) numa lista de respostas.
function quiz_correct_index(answers) {
    var _best = 0;
    for (var i = 1; i < array_length(answers); i++) {
        if (answers[i].score > answers[_best].score) _best = i;
    }
    return _best;
}

/// Reabastece a fila embaralhada de uma dificuldade, evitando repetir
/// a última pergunta logo no começo da nova rodada.
function quiz_refill_pile(difficulty) {
    var _ids = [];
    for (var i = 0; i < array_length(global.quiz_bank); i++) {
        if (global.quiz_bank[i].difficulty == difficulty) array_push(_ids, i);
    }
    // Fisher-Yates
    for (var i = array_length(_ids) - 1; i > 0; i--) {
        var j = irandom(i);
        var _t = _ids[i]; _ids[i] = _ids[j]; _ids[j] = _t;
    }
    // Se a última sorteada cairia primeiro, troca com outra posição
    if (array_length(_ids) > 1 && _ids[array_length(_ids) - 1] == global.quiz_last[difficulty]) {
        var _k = irandom(array_length(_ids) - 2);
        var _t2 = _ids[_k]; _ids[_k] = _ids[array_length(_ids) - 1]; _ids[array_length(_ids) - 1] = _t2;
    }
    // (a fila é consumida pelo fim com array_pop)
    global.quiz_piles[difficulty] = _ids;
}

/// Monta a questão a ser exibida, posicionando a resposta correta numa
/// posição ainda não usada (sem alterar textos). Quando todas as 4 posições
/// já foram usadas, volta à ordem padrão e reinicia o ciclo.
function quiz_build_question(idx) {
    var _src     = global.quiz_bank[idx];
    var _used    = global.quiz_used_pos[idx];
    var _std_pos = quiz_correct_index(_src.answers);
    var _n       = array_length(_src.answers);
    var _target;
    var _answers = [];

    if (array_length(_used) == 0 || array_length(_used) >= _n) {
        // ordem padrão (1ª exibição ou ciclo completo reiniciado)
        _used = [_std_pos];
        _target = _std_pos;
        for (var i = 0; i < _n; i++) _answers[i] = _src.answers[i];
    } else {
        var _free = [];
        for (var p = 0; p < _n; p++) {
            var _taken = false;
            for (var u = 0; u < array_length(_used); u++) if (_used[u] == p) _taken = true;
            if (!_taken) array_push(_free, p);
        }
        _target = _free[irandom(array_length(_free) - 1)];
        array_push(_used, _target);
        // distratores embaralhados nas demais posições
        var _wrong = [];
        for (var i = 0; i < _n; i++) if (i != _std_pos) array_push(_wrong, _src.answers[i]);
        for (var i = array_length(_wrong) - 1; i > 0; i--) {
            var j = irandom(i);
            var _t = _wrong[i]; _wrong[i] = _wrong[j]; _wrong[j] = _t;
        }
        var _w = 0;
        for (var i = 0; i < _n; i++) {
            if (i == _target) _answers[i] = _src.answers[_std_pos];
            else { _answers[i] = _wrong[_w]; _w++; }
        }
    }
    global.quiz_used_pos[idx] = _used;

    return {
        id: _src.id,
        difficulty: _src.difficulty,
        question: _src.question,
        answers: _answers
    };
}

/// Sorteia a próxima pergunta. Sem argumento (-1), a dificuldade vem da média.
function get_random_question(difficulty = -1) {
    quiz_init();
    if (difficulty < 1 || difficulty > 3) difficulty = get_quiz_difficulty();
    if (array_length(global.quiz_piles[difficulty]) == 0) quiz_refill_pile(difficulty);
    var _idx = array_pop(global.quiz_piles[difficulty]);
    global.quiz_last[difficulty] = _idx;
    return quiz_build_question(_idx);
}

/// Pontuação (0-10) da alternativa escolhida.
function get_answer_score(question, answer_index) {
    return question.answers[answer_index].score;
}
