event_inherited();
clip_to_box = true;
vx = choose(-2.6, 2.6);   // o padrão do Trono sobrescreve (direção por fase)
t = 0; life = 150;
warn_frames = 20;         // faixa vermelha na altura travada antes de entrar
estado = 0;               // 0 = aviso | 1 = entrada
y_travada = y;
active = false;           // o aviso não machuca
