speed = 0;
image_angle = direction;

// ── Atributos usados pelos ataques variados (obj_rh_atk_*) ────────
// Para a bala antiga (MathMonster) estes valores reproduzem o comportamento original.
active         = true;   // false = NÃO machuca (aviso/telégrafo, fade-in, ou já acertou)
dmg_mult       = 1;      // multiplicador do dano (golpes grandes machucam mais)
destroy_on_hit = true;   // true = some ao acertar o coração
was_hit        = false;  // vira true quando o coração é atingido por este ataque (zonas não podem acertar de novo)
clip_to_box    = false;  // true = só é desenhado dentro da Battle Box (ver rh_draw_clipped)
kb_power       = 0;      // >0 = ao acertar, empurra o coração para trás (investida do Juiz)
kb_dir         = 0;      // direção do empurrão (graus)
beam_w         = 0;      // >0 = dano por geometria de segmento, não por máscara de sprite

// Limites internos da Battle Box, guardados uma vez (a caixa não se move)
var _r = rh_box_inner();
bx1 = _r.x1;
by1 = _r.y1;
bx2 = _r.x2;
by2 = _r.y2;
