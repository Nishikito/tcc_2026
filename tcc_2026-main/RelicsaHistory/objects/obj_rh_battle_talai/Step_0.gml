if (!instance_exists(obj_rh_battle_controller)) exit;
var _ctrl = obj_rh_battle_controller;

oscilacao_timer += 2;

// Talai oscila suavemente durante MENU e QUESTION
// Durante ATTACK_MINIGAME ele "ataca" (inclinado para frente)
// Durante ENEMY_TURN ele recua levemente
switch (_ctrl.state) {
    case BATTLE_STATE.MENU:
    case BATTLE_STATE.QUESTION:
    case BATTLE_STATE.QUESTION_RESULT:
        y = base_y + dsin(oscilacao_timer) * 2;
        image_angle = 0;
        break;

    case BATTLE_STATE.ATTACK_MINIGAME:
        y = base_y - 4; // levanta levemente ao atacar
        image_angle = -15; // inclinado para frente
        break;

    case BATTLE_STATE.ENEMY_TURN:
        y = base_y + 2; // recua levemente ao defender
        image_angle = 0;
        break;

    default:
        y = base_y;
        image_angle = 0;
        break;
}