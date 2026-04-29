initial_room   = rm_title;         
scroll_y       = 0;                
scroll_speed   = 2;                 


credits_sprite = spr_credits;       


credits_height = sprite_get_height(credits_sprite);


var cam = view_camera[0];
if (is_real(cam)) {
    view_h = camera_get_view_height(cam);
} else {
    view_h = 480;
}


max_scroll = max(0, credits_height - view_h);
