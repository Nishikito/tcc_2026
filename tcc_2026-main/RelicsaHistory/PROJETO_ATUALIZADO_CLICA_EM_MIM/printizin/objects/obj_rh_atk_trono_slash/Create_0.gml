event_inherited();

// Corte do Trono Vazio: faixa branca desenhada por código, sem sprite de lâmina.
// Nunca usa colisão por máscara: active=false e rh_hurt_heart() no Step.
active         = false;
destroy_on_hit = false;   // was_hit garante o single-hit
clip_to_box    = false;   // o desenho já vem recortado pela geometria
sprite_index   = noone;

t             = 0;
aviso_frames  = 32;       // fio vermelho fino
delay_frames  = 0;        // escalonamento entre linhas
active_frames = 7;        // faixa branca machucando
fade_frames   = 8;        // desaparecendo
largura       = 10;
x1 = 0; y1 = 0; x2 = 0; y2 = 0;
ang = 0;
