event_inherited();
// Martelo que tomba (substitui o giro). Desenho FEITO POR CÓDIGO com pivô na ponta da haste.
active = false;          // o martelo em si NUNCA machuca; só a zona de impacto
clip_to_box = false;
visible = true;          // o Draw deste objeto desenha (não usar draw_self)
sprite_index = spr_hammer_attack;

scale_h   = 0.55;
// Tomba para o lado onde o coração está: o golpe sempre cai na área que ele pode ocupar.
side_left = (rh_heart_x() < (bx1 + bx2) / 2);
pivot_x   = side_left ? bx1 + 4 : bx2 - 4;
pivot_y   = by2 - 4;

// No arquivo a haste vai do canto inferior esquerdo (0,78) até a cabeça no superior direito.
// -53 graus deixa a haste VERTICAL com a cabeça para cima.
base_angle = -53;
ang       = 0;
ang_acc   = 0.8;
t         = 0;
stand_t   = 26;          // fica em pé ~26 frames com leve tremida
zone_made = false;
zone_w    = 58;
zone_h    = 42;
shake_t   = 0;
dmg_mult  = 1.4;

// Mesma matemática do tombo, usada no aviso e no impacto (não pode divergir).
zone_for_angle = function(_ang) {
    var _dx = 82 * scale_h;
    var _dy = (10 - 78) * scale_h;
    var _da = base_angle + (side_left ? _ang : -_ang);
    var _hx = pivot_x + _dx * cos(degtorad(_da)) - _dy * sin(degtorad(_da));
    var _hy = pivot_y + _dx * sin(degtorad(_da)) + _dy * cos(degtorad(_da));
    return {
        x: clamp(_hx - zone_w / 2, bx1 + 2, bx2 - zone_w - 2),
        y: clamp(_hy - zone_h / 2, by1 + 2, by2 - zone_h)
    };
};

// Aviso JÁ aparece no lugar onde a cabeça vai bater (antes ficava em x=0).
var _zp = zone_for_angle(90);
zone_x = _zp.x;
zone_y = _zp.y;
