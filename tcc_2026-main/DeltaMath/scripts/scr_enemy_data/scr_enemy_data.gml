/// Sistema de dados dos inimigos

function get_enemy_data(enemy_id) {
    switch(enemy_id) {
        case "Carol":
            return {
                name: "Carol",
                max_hp: 1500,
                current_hp: 1500,
                difficulty: "special",
                sprite: noone
            };
        case "MathMonster":
            return {
                name: "Monstro Matemático",
                max_hp: 80,
                current_hp: 80,
                difficulty: "easy",
                sprite: noone
            };
        case "AlgebraGhost":
            return {
                name: "Fantasma da Álgebra",
                max_hp: 120,
                current_hp: 120,
                difficulty: "medium",
                sprite: noone
            };
        case "CalculusDevil":
            return {
                name: "Demônio do Cálculo",
                max_hp: 200,
                current_hp: 200,
                difficulty: "hard",
                sprite: noone
            };
        default:
            return {
                name: "Inimigo Desconhecido",
                max_hp: 50,
                current_hp: 50,
                difficulty: "easy",
                sprite: noone
            };
    }
}

function get_difficulty_settings(difficulty) {
    switch(difficulty) {
        case "easy":
            return {
                min_num: 5,
                max_num: 50,
                operators: ["+", "-"],
                time_limit: 10 * 60
            };
        case "medium":
            return {
                min_num: 10,
                max_num: 100,
                operators: ["+", "-", "*"],
                time_limit: 8 * 60
            };
        case "hard":
            return {
                min_num: 20,
                max_num: 150,
                operators: ["+", "-", "*", "/"],
                time_limit: 6 * 60
            };
        case "special":
 
            return {
                min_num: 1,
                max_num: 10,
                operators: ["+", "-"],
                time_limit: 10 * 6
            };
        default:
            return get_difficulty_settings("easy");
    }
}