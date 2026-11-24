/// Executor de cutscenes: o cutscene_play cria este objeto e entrega o array da cena em scene_info.
/// Cada passo é [função, arg1, arg2...]; a função devolve true quando termina.
depth = -99990;          // por cima de tudo, menos da caixa de texto

scene_info     = [];
current_step   = 0;

// variáveis que as ações (scr_cutscene_actions / scr_cutscene_fx) usam
action_started = false;
timer          = 0;
target_x       = 0;
target_y       = 0;
shake_target   = noone;

// tremida da câmera
shake_on  = false;
shake_str = 0;
cam_jx    = 0;           // quanto a câmera está deslocada pela tremida agora
cam_jy    = 0;

// escuridão com foco de luz em volta do player
dark_alpha  = 0;         // 0 = claro, 1 = preto total
dark_radius = 0;         // raio do foco de luz (0 = sem foco)
dark_surf   = -1;
fx_a0       = 0;
fx_r0       = 0;

global.cutscene_active = true;
