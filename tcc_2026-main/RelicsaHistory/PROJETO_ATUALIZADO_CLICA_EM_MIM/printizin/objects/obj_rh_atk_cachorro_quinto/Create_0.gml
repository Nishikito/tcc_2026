event_inherited();

sprite_index = spr_cachorro_inferno_attack;   // olha para a esquerda
image_speed  = 0;                             // animação manual: 0,25 quadro/frame
image_index  = 0;
image_xscale = 0.75;
image_yscale = 0.75;
clip_to_box  = true;

// Corpo: hitbox 15% menor que o sprite, calculada por geometria própria.
active         = false;
dmg_mult       = 1;
destroy_on_hit = false;   // o cachorro continua correndo depois do primeiro acerto
was_hit        = false;

aviso_total      = 22;
tempo_parada     = 18;
vel_cachorro     = 2.24;   // 30% mais lento (era 3.2)
escala_cachorro  = 0.75;
max_passagens    = 3;
max_paradas      = 3;
fogos_por_parada = 2;
max_fogos        = 6;
atira            = true;

t              = 0;
t_cor          = 0;
t_parada       = 0;
estado         = 0;   // 0 = aviso, 1 = correndo, 2 = parado, 3 = saindo
dir            = 1;   // 1 = direita, -1 = esquerda
passagem       = 1;
paradas        = 0;
meio_x         = 0;
meio_atingido  = false;
base_x         = x;
t_fim          = 0;
largura        = sprite_get_width(sprite_index)  * image_xscale;
altura         = sprite_get_height(sprite_index) * image_yscale;
y              = by2 - altura;   // rento ao chão da caixa

// Usa o espelho quando corre para a DIREITA (rh_draw_clipped não aceita xscale negativo).
atualiza_sprite = function() {
    if (dir > 0) sprite_index = spr_cachorro_inferno_right_attack;
    else         sprite_index = spr_cachorro_inferno_attack;
    largura = sprite_get_width(sprite_index)  * image_xscale;
    altura  = sprite_get_height(sprite_index) * image_yscale;
};

// Dois foguinhos pela boca, na frente do sprite (lado da cabeça), SEM mirar o coração.
solta_fogos = function() {
    var _boca_x = (dir > 0) ? (64 - 7) : 7;   // 7 px desde a ponta do focinho
    var _mx = x + _boca_x * image_xscale;
    var _my = y + 14 * image_yscale;
    // O cachorro nasce FORA da caixa: sem este clamp o foguinho batia na parede
    // de entrada, virava para fora e esgotava os 3 rebotes sem entrar na arena.
    var _fw = sprite_get_width(spr_fire_attack)  * 0.5;
    var _fh = sprite_get_height(spr_fire_attack) * 0.5;
    _mx = clamp(_mx, bx1, bx2 - _fw);
    _my = clamp(_my, by1, by2 - _fh);
    for (var i = 0; i < fogos_por_parada; i++) {
        if (instance_number(obj_rh_atk_fogo_quinto) >= max_fogos) break;
        var _angulo = irandom_range(200, 340);   // para CIMA / diagonal
        var _f = rh_spawn_attack(obj_rh_atk_fogo_quinto, _mx, _my);
        // 30% mais lento (era 2 px/frame); a direção continua aleatória para cima.
        _f.vx = lengthdir_x(1.4, _angulo);
        _f.vy = lengthdir_y(1.4, _angulo);
        _f.image_angle = _angulo - 90;
    }
};
