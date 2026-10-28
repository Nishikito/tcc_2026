// Não executar se ObjPlayer não existir
if (!instance_exists(ObjPlayer)) exit;

// Enquanto há diálogo ativo (caixa de texto, coleta de item, cutscene) ou
// fade de transição de sala, o monstro fica parado no lugar: não avança
// estado, não persegue, não conta alert_timer/caught_timer. Ele só volta
// a fazer qualquer coisa quando o diálogo termina — sem teleporte, porque
// simplesmente não mexemos em x/y enquanto isso.
if (global.dialog_active || global.fade_active) exit;

var dist = point_distance(x, y, ObjPlayer.x, ObjPlayer.y);

switch(state) {
    case "idle":

        if (dist <= detection_range) {
            state = "alert";
            show_alert = true;
            alert_timer = alert_duration;
        }
        break;
        
    case "alert":
        alert_timer--;
        if (alert_timer <= 0) {
            state = "chasing";
            show_alert = false;
        }
        break;
        
    case "chasing":
        var dir = point_direction(x, y, ObjPlayer.x, ObjPlayer.y);
        var next_x = x + lengthdir_x(speed_follow, dir);
        var next_y = y + lengthdir_y(speed_follow, dir);
        
        var hit_wall_x = place_meeting(next_x, y, ObjNpcWall);
        var hit_wall_y = place_meeting(x, next_y, ObjNpcWall);
      
        if (hit_wall_x || hit_wall_y) {
            state = "idle";
            show_alert = false;
        } else {
            x = next_x;
            y = next_y;
        }
        break;
        
  case "caught":
    break;
}