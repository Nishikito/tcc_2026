speed = 0;
image_angle = direction;

// ── Atributos usados pelos ataques variados (obj_rh_atk_*) ────────
// Para a bala antiga (MathMonster) estes valores reproduzem o comportamento original.
active         = true;   // false = NÃO machuca (aviso/telégrafo, fade-in, ou já acertou)
dmg_mult       = 1;      // multiplicador do dano (golpes grandes machucam mais)
destroy_on_hit = true;   // true = some ao acertar o coração
clip_to_box    = false;  // true = só é desenhado dentro da Battle Box (ver rh_draw_clipped)

// Limites internos da Battle Box, guardados uma vez (a caixa não se move)
var _r = rh_box_inner();
bx1 = _r.x1;
by1 = _r.y1;
bx2 = _r.x2;
by2 = _r.y2;
