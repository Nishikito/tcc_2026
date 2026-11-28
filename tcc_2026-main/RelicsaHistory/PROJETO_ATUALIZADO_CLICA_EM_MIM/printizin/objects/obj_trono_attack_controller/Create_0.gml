// Controlador ISOLADO dos ataques do Trono Vazio.
// O obj_rh_battle_controller só cria esta instância e espera: quando ela some
// (ou finished vira true), o turno volta ao normal. Nada aqui mexe na máquina de estados.
// attack_id e level são passados pelo controller ANTES do primeiro Step.

attack_id  = 1;      // 1 Stars | 2 Tracking Swords | 3 Sword Tunnel | 4 Rotating Slash
level      = 1;      // 1, 2 ou 3
t          = 0;      // frames desde o início deste ataque
finished   = false;  // sinal para o controller da batalha
spawn_done = false;  // evita criar projéteis duas vezes se o Step repetir
