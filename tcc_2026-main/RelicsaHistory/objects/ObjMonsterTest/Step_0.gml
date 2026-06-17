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
        caught_timer--;
        if (caught_timer <= 0) {
            room_goto(rm_math_battle);
        }
        break;
}