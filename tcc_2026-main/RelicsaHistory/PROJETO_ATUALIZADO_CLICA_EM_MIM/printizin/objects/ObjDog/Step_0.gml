wave_timer += wave_speed;

var wave_y = sin(wave_timer) * 10;
var wave_dir = cos(wave_timer);

x = camera_get_view_x(view_camera[0]) + base_x;
y = camera_get_view_y(view_camera[0]) + base_y + wave_y;

image_angle = wave_dir * -7; 