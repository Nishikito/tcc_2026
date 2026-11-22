event_inherited();
// Classe BASE: não é criada direto. obj_rh_atk_hammer e obj_rh_atk_boot herdam e só trocam sprite/dano.
active   = false;   // o dano vem da zona criada no impacto
depth    = -5;      // desenhado por cima da caixa
zone_x   = 106;     // coluna que vai ser atingida (preencha depois de criar)
zone_w   = 48;
warn_t   = 30;      // frames de AVISO (coluna vermelha piscando)
drop_t   = 6;       // frames da queda
hold_t   = 16;      // frames parado depois do impacto
rise_t   = 10;      // frames subindo
flip_on_right = false;   // true = espelha o sprite quando o golpe é na metade DIREITA da caixa (martelo)
zone_life = 10;     // frames em que a coluna machuca (queda + impacto)
t = 0;
zone_made = false;
