t++;
var _impact = warn_frames + prep_frames + fall_frames;   // 30+14+6 = 50

if (shake_t > 0) shake_t--;

// ── Modo 0: martelada das Marteladas ──────────────────────────────
if (mode == 0) {
    // MIRADA: segue o coração durante o aviso e TRAVA 20 frames antes do impacto.
    if (lock_heart && t <= lock_frame) {
        px = clamp(rh_heart_x(), bx1 + 18, bx2 - 18);
        var _h0 = head_pos(ANG_IMPACT);
        var _w0 = HEAD_W * SCALE_H / 2;
        var _h0y = HEAD_H * SCALE_H / 2;
        zone_x1 = max(bx1, _h0.x - _w0);
        zone_y1 = max(by1, _h0.y - _h0y);
        zone_x2 = min(bx2, _h0.x + _w0);
        zone_y2 = min(by2, _h0.y + _h0y);
    }

    if (t <= warn_frames) {
        ang = ANG_UP;                       // aviso: cabeça ainda fora da caixa
    } else if (t <= warn_frames + prep_frames) {
        var _p = (t - warn_frames) / prep_frames;
        ang = ANG_UP + (ANG_PREP - ANG_UP) * _p;   // levanta/inclina para trás
    } else if (t <= _impact) {
        var _f = (t - warn_frames - prep_frames) / fall_frames;
        ang = ANG_PREP + (ANG_IMPACT - ANG_PREP) * _f * _f;   // descida acelerada
    } else {
        ang = ANG_IMPACT;
    }

    if (t == _impact) shake_t = 8;   // tremida curta do próprio golpe

    // Hitbox = cabeça desenhada (36x22), ativa por zone_frames frames.
    if (t > _impact && !was_hit && t <= _impact + zone_frames) {
        var _h = head_pos(ang);
        if (rh_rot_rect_hits_heart(_h.x, _h.y,
                                   HEAD_W * SCALE_H, HEAD_H * SCALE_H, ang)) {
            rh_hurt_heart(id);   // active é false: dano manual, single-hit
        }
    }

    if (t > _impact + zone_frames + 8) {
        rh_debug_destroy("fim da vida (martelo de ferro)");
        instance_destroy();
    }
    exit;
}

// ── Modo 1: martelo pequeno que esmaga a barra da Sentença ────────
if (t <= smash_frames) {
    var _f = t / smash_frames;
    ang = ANG_UP + (ANG_IMPACT - ANG_UP) * _f * _f;
    py  = py_start + (py_end - py_start) * _f * _f;
    if (t == smash_frames) {
        // Impacto no frame 6: a barra sai rastejando logo após o repouso.
        ang = ANG_IMPACT;
        shake_t = 6;
        if (target_bar != noone && instance_exists(target_bar)) {
            target_bar.launch_now = true;
        }
    }
}

if (t > smash_frames + 10) {
    rh_debug_destroy("fim da vida (martelo esmaga)");
    instance_destroy();
}
