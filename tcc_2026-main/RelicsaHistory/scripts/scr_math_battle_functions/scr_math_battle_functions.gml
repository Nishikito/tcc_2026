function generate_math_problem_by_difficulty(difficulty) {
    var settings = get_difficulty_settings(difficulty);
    var operators = settings.operators;
    var op = operators[irandom(array_length(operators) - 1)];
    var num1, num2, correct_answer;
    
    switch(op) {
        case "+":
            num1 = irandom_range(settings.min_num, settings.max_num);
            num2 = irandom_range(settings.min_num, settings.max_num);
            correct_answer = num1 + num2;
            break;
            
        case "-":
            num1 = irandom_range(settings.max_num/2, settings.max_num);
            num2 = irandom_range(settings.min_num, num1-settings.min_num);
            correct_answer = num1 - num2;
            break;
            
        case "*":
            num1 = irandom_range(2, min(15, settings.max_num/5));
            num2 = irandom_range(2, min(10, settings.max_num/10));
            correct_answer = num1 * num2;
            break;
            
        case "/":
            var result = irandom_range(2, min(25, settings.max_num/4));
            num2 = irandom_range(2, min(10, settings.max_num/20));
            num1 = result * num2;
            correct_answer = result;
            break;
    }
    
    var problem = string(num1) + " " + op + " " + string(num2);
    return [problem, correct_answer];
}


function generate_wrong_answers(correct_answer) {
    var wrong1, wrong2, wrong3;
    

    wrong1 = correct_answer + irandom_range(5, 20);
    
 
    wrong2 = correct_answer - irandom_range(5, 20);
    if(wrong2 <= 0) wrong2 = correct_answer + irandom_range(10, 30);
    

    wrong3 = correct_answer + irandom_range(-15, -5);
    if(wrong3 <= 0 || wrong3 == wrong2) wrong3 = correct_answer + irandom_range(25, 40);
    

    if(wrong2 == wrong1) wrong2 = wrong1 + 10;
    if(wrong3 == wrong1) wrong3 = wrong1 - 8;
    if(wrong3 == wrong2) wrong3 = wrong2 + 7;
    
    return [wrong1, wrong2, wrong3];
}


function shuffle_array(arr) {
    for(var i = 0; i < 10; i++) { 
        var pos1 = irandom(array_length(arr) - 1);
        var pos2 = irandom(array_length(arr) - 1);
        
        var temp = arr[pos1];
        arr[pos1] = arr[pos2];
        arr[pos2] = temp;
    }
    return arr;
}