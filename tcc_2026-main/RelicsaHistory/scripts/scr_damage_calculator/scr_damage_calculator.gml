#macro DMG_PLAYER_BASE_MIN  10
#macro DMG_PLAYER_BASE_MAX  30
#macro DMG_ENEMY_BASE_MIN    5
#macro DMG_ENEMY_BASE_MAX   12
#macro DMG_SCORE_SCALE       0.5

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