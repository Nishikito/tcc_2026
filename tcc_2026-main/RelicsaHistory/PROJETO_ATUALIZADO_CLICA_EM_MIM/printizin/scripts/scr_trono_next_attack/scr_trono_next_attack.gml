// ÚNICO lugar onde a ordem dos ataques do Trono Vazio é decidida.
// Recebe o último ataque (0 = nenhum) e o último nível, devolve o próximo par.
// Ciclo: 1 Stars, 2 Tracking Swords, 3 Sword Tunnel, 4 Rotating Slash,
// primeiro tudo no nível 1, depois no 2, depois no 3 e aí repete só o nível 3.
// Usar esta função evita espalhar "attack++" pelo controller e pelo inimigo.
function scr_trono_next_attack(_last_attack, _last_level) {
    var _attack = _last_attack + 1;
    var _level  = _last_level;

    if (_attack > 4) {
        _attack = 1;
        _level  = _last_level + 1;
        if (_level > 3) {
            _level = 3;   // a partir do 3º ciclo, fica em loop no nível 3
        }
    }

    return { attack: _attack, level: _level };
}

// ═══════════════════════════════════════════════════════════════════
// TICKS DOS ATAQUES DO TRONO
// ───────────────────────────────────────────────────────────────────
// Chamados pelo Step de obj_rh_battle_controller, que É um evento que roda
// neste projeto. Os eventos Step dos objetos novos não são confiáveis (o .yy
// antigo de referência usa um número de evento diferente), então a lógica
// fica aqui e o controller da batalha apenas repassa o tempo.
// ═══════════════════════════════════════════════════════════════════

function trono_tick_controller(_ctrl) {
    if (_ctrl == noone || !instance_exists(_ctrl)) exit;

    _ctrl.t++;

    switch (_ctrl.attack_id) {

        case 1:
            // ── ATTACK 1: STARS — nível 1 ──────────────────────────
            if (!_ctrl.spawn_done) {
                _ctrl.spawn_done = true;

                // Origem real do boss; o fallback é o centro usado pela transição.
                var _ox = 267;
                var _oy = 104;
                if (instance_exists(obj_rh_en_trono_vazio)) {
                    _ox = obj_rh_en_trono_vazio.x;
                    _oy = obj_rh_en_trono_vazio.y;
                }

                var _r  = rh_box_inner();
                var _cx = (_r.x1 + _r.x2) / 2;
                var _cy = (_r.y1 + _r.y2) / 2;
                var _base = point_direction(_ox, _oy, _cx, _cy);

                // 5 coroas em leque de ±20°, convergindo para dentro da caixa.
                for (var _i = 0; _i < 5; _i++) {
                    var _c = rh_spawn_attack(obj_trono_coroa, _ox, _oy);
                    _c.ctrl         = _ctrl.id;
                    _c.dir          = _base + (_i - 2) * 10;
                    _c.spd          = 2.4;
                    _c.grow_time    = 0.8 * room_speed;
                    _c.hold_time    = 0.2 * room_speed;
                    _c.back_time    = 1.0 * room_speed;
                    _c.warn_time    = 0.3 * room_speed;
                    _c.fragment_life = 1.2 * room_speed;
                    _c.fragment_n   = 3;
                    _c.fragment_base_dir = irandom(359);
                    _c.trono_fixed_damage = 75;
                    _c.trono_iframes      = 1.0 * room_speed;
                }
            }

            // Só fecha quando não sobrou coroa nem estilhaço deste ataque.
            if (_ctrl.t > 0.2 * room_speed
                && instance_number(obj_trono_coroa) == 0
                && instance_number(obj_trono_fragmento) == 0) {
                _ctrl.finished = true;
                instance_destroy(_ctrl);
            }
            break;

        case 2:
            // ── ATTACK 2: TRACKING SWORDS — nível 1 ─────────────────
            // Oito espadas cercam o coração ao mesmo tempo. O círculo pulsa e
            // gira devagar; cada espada dispara na sua vez (ordem circular).
            if (!_ctrl.spawn_done) {
                _ctrl.spawn_done = true;

                var _warn = 1.0 * room_speed;
                var _gap  = 0.28 * room_speed;   // entre um corte e outro

                for (var _i = 0; _i < 8; _i++) {
                    var _a = _i * 45;
                    var _s = rh_spawn_attack(obj_trono_espada,
                                             rh_heart_x() + lengthdir_x(24, _a),
                                             rh_heart_y() + lengthdir_y(24, _a));
                    _s.ctrl        = _ctrl.id;
                    _s.dir         = _a;
                    _s.base_radius = 24;
                    _s.warn_time   = _warn;
                    _s.freeze_time = 0.12 * room_speed;

                    // A espada i dispara depois da anterior: a ordem fica
                    // previsível e o jogador consegue ler os oito cortes.
                    _s.fire_at = _warn + _i * _gap;
                }
            }

            // Fecha quando todas as espadas viraram corte e os cortes sumiram.
            if (_ctrl.t > 0.2 * room_speed
                && instance_number(obj_trono_espada) == 0
                && instance_number(obj_trono_corte) == 0) {
                _ctrl.finished = true;
                instance_destroy(_ctrl);
            }
            break;

        default:
            // Ataques 3 e 4 ainda serão escritos nas próximas etapas.
            if (_ctrl.t > 0.2 * room_speed) {
                _ctrl.finished = true;
                instance_destroy(_ctrl);
            }
            break;
    }
}

function trono_tick_coroa(_c) {
    if (_c == noone || !instance_exists(_c)) exit;

    _c.t++;

    var _r  = rh_box_inner();
    var _cx = (_r.x1 + _r.x2) / 2;
    var _cy = (_r.y1 + _r.y2) / 2;

    switch (_c.estado) {

        case 0:
            // Aviso: só a linha no Draw. active continua false.
            if (_c.t >= _c.warn_time) { _c.estado = 1; _c.t = 0; }
            exit;

        case 1:
            // Cresce no lugar, ainda inofensiva.
            _c.grow_t++;
            var _p = clamp(_c.grow_t / max(1, _c.grow_time), 0, 1);
            // 40% do tamanho original (antes 0.3 + 0.7 * _p): o ataque ficava grande demais na caixa.
            _c.image_xscale = 0.12 + 0.28 * _p;
            _c.image_yscale = _c.image_xscale;
            if (_c.grow_t >= _c.grow_time) {
                _c.estado = 2;
                _c.t = 0;
                _c.active = true;
            }
            exit;

        case 2:
            // Avança até o meio da caixa; limite evita atravessar a sala toda.
            _c.x += lengthdir_x(_c.spd, _c.dir);
            _c.y += lengthdir_y(_c.spd, _c.dir);
            if (point_distance(_c.x, _c.y, _cx, _cy) <= _c.spd
                || point_distance(_c.orig_x, _c.orig_y, _c.x, _c.y) > 400) {
                _c.estado = 3;
                _c.t = 0;
            }
            exit;

        case 3:
            // Pausa: os estilhaços nascem uma vez só.
            if (!_c.frag_spawned) {
                _c.frag_spawned = true;
                var _passo = 360 / 6;   // 6 direções possíveis; o nível escolhe quantas
                for (var _i = 0; _i < _c.fragment_n; _i++) {
                    var _a = _c.fragment_base_dir + _i * _passo;
                    var _f = rh_spawn_attack(obj_trono_fragmento, _c.x, _c.y);
                    _f.ctrl = _c.ctrl;
                    _f.dir  = _a;
                    _f.spd  = 2.0;
                    _f.life = _c.fragment_life;
                    _f.trono_fixed_damage = _c.trono_fixed_damage;
                    _f.trono_iframes      = _c.trono_iframes;
                }
            }
            _c.hold_t++;
            if (_c.hold_t >= _c.hold_time) { _c.estado = 4; _c.t = 0; }
            exit;

        case 4:
            // Volta pelo mesmo caminho.
            _c.back_t++;
            _c.x -= lengthdir_x(_c.spd, _c.dir);
            _c.y -= lengthdir_y(_c.spd, _c.dir);
            if (_c.back_t >= _c.back_time) {
                _c.estado = 5;
                _c.t = 0;
                _c.active = false;
            }
            exit;

        case 5:
            _c.image_alpha -= 0.12;
            if (_c.image_alpha <= 0) {
                with (_c) rh_debug_destroy("Stars: coroa terminou o ciclo");
                instance_destroy(_c);
            }
            exit;
    }
}

function trono_tick_fragmento(_f) {
    if (_f == noone || !instance_exists(_f)) exit;

    _f.t++;
    _f.x += lengthdir_x(_f.spd, _f.dir);
    _f.y += lengthdir_y(_f.spd, _f.dir);

    // O alpha só cai no último terço da vida.
    if (_f.t > _f.life * 0.66) {
        _f.image_alpha = clamp(1 - (_f.t - _f.life * 0.66) / max(1, _f.life * 0.34), 0, 1);
    }

    if (_f.t >= _f.life || _f.image_alpha <= 0) {
        with (_f) rh_debug_destroy("Stars: estilhaço expirou");
        instance_destroy(_f);
    }
}

function trono_tick_espada(_s) {
    if (_s == noone || !instance_exists(_s)) exit;

    _s.t++;

    var _now = 0;
    if (instance_exists(_s.ctrl)) _now = _s.ctrl.t;

    // Pouco antes do disparo a espada fica vermelha e para: ela marca a reta
    // que o corte vai percorrer, para o jogador ainda poder sair da linha.
    if (_s.estado == 0 && _now >= _s.fire_at - _s.freeze_time) {
        _s.estado = 1;
        _s.fx = rh_heart_x();
        _s.fy = rh_heart_y();
        _s.image_blend = c_red;
    }

    if (_s.estado == 0) {
        // Círculo ao redor do coração: gira devagar e pulsa para dentro/fora
        // enquanto acompanha o jogador. active é false, então não machuca.
        _s.dir += 0.25;
        var _r = _s.base_radius + dsin(_s.t * 0.07) * 2;
        _s.x = rh_heart_x() + lengthdir_x(_r, _s.dir);
        _s.y = rh_heart_y() + lengthdir_y(_r, _s.dir);
        _s.image_angle = _s.dir + 90;   // ponta embaixo no sprite: olha para dentro
        exit;
    }

    // Na vez desta espada, ela desaparece e deixa o corte branco.
    if (_now >= _s.fire_at) {
        var _c = rh_spawn_attack(obj_trono_corte, _s.fx, _s.fy);
        _c.ctrl       = _s.ctrl;
        _c.angle      = _s.dir + 90;   // reta perpendicular à espada
        _c.slash_time = 0.26 * room_speed;
        _c.trono_fixed_damage = 30;    // escalado para os 50 HP do projeto
        _c.trono_iframes      = 0.4 * room_speed;

        with (_s) rh_debug_destroy("Tracking Swords: espada virou corte");
        instance_destroy(_s);
    }
}

/// Recorta uma reta infinita (centro _cx,_cy; direção _ang) nos limites da caixa.
/// Liang-Barsky: evita desenhar o corte fora da Battle Box.
function trono_clipped_line(_cx, _cy, _ang) {
    var _r  = rh_box_inner();

    // O segmento vai de (_cx - _dx) até (_cx + _dx), então o "vão" é o DOBRO
    // de _dx. Usar só _dx fazia o corte parar no meio da caixa (bug dos feixes).
    var _dx = lengthdir_x(1000, _ang);
    var _dy = lengthdir_y(1000, _ang);
    var _span_x = 2 * _dx;
    var _span_y = 2 * _dy;
    var _x0 = _cx - _dx;
    var _y0 = _cy - _dy;
    var _t0 = 0;
    var _t1 = 1;

    var _p = [-_span_x, _span_x, -_span_y, _span_y];
    var _q = [_x0 - _r.x1, _r.x2 - _x0, _y0 - _r.y1, _r.y2 - _y0];

    for (var _i = 0; _i < 4; _i++) {
        if (_p[_i] == 0) {
            if (_q[_i] < 0) {
                return { found: false, x1: 0, y1: 0, x2: 0, y2: 0 };
            }
        } else {
            var _u = _q[_i] / _p[_i];
            if (_p[_i] < 0) {
                if (_u > _t1) return { found: false, x1: 0, y1: 0, x2: 0, y2: 0 };
                if (_u > _t0) _t0 = _u;
            } else {
                if (_u < _t0) return { found: false, x1: 0, y1: 0, x2: 0, y2: 0 };
                if (_u < _t1) _t1 = _u;
            }
        }
    }

    return {
        found: true,
        x1: _x0 + _t0 * _span_x,
        y1: _y0 + _t0 * _span_y,
        x2: _x0 + _t1 * _span_x,
        y2: _y0 + _t1 * _span_y
    };
}

function trono_tick_corte(_c) {
    if (_c == noone || !instance_exists(_c)) exit;

    _c.t++;

    // Um único acerto por corte; o segmento já está limitado à caixa.
    var _ln = trono_clipped_line(_c.x, _c.y, _c.angle);
    if (_ln.found && !_c.was_hit) {
        if (rh_segment_hits_heart(_ln.x1, _ln.y1, _ln.x2, _ln.y2, 3)) {
            rh_hurt_heart(_c);
        }
    }

    if (_c.t >= _c.slash_time) {
        with (_c) rh_debug_destroy("Tracking Swords: corte terminou");
        instance_destroy(_c);
    }
}
