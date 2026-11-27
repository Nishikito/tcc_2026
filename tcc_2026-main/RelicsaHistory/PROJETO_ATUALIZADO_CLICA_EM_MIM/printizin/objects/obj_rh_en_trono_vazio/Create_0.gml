event_inherited();

// ── FICHA ─────────────────────────────────────────────────────────
enemy_name   = "Trono Vazio";
enemy_max_hp = 560;
dmg_min      = 3;
dmg_max      = 4;

// ── APARÊNCIA ─────────────────────────────────────────────────────
sprite_index = spr_trono_vazio;
spr_hit      = spr_trono_vazio_damage;
spr_defeated = spr_trono_vazio_defeated;
sway_y = 2;  sway_angle = 0;
alarm[0] = -1;

// Fase: 1 (cheio), 2 (abaixo de 2/3), 3 (abaixo de 1/3).
trono_phase = function() {
    // O controller espelha o HP em global.battle_enemy_hp a cada dano.
    // Assim a fase é lida sem guarda instance_exists (que poderia pular levas).
    var _hp = enemy_max_hp;
    if (variable_global_exists("battle_enemy_hp")) {
        _hp = global.battle_enemy_hp;
    }
    _hp = _hp / max(1, enemy_max_hp);
    if (_hp <= 0.33) return 3;
    if (_hp <= 0.66) return 2;
    return 1;
};

// REGRA DE JUSTIÇA: nada de guardas instance_exists() nos padrões, nenhum ataque
// nasce fora da room e todo Other_0 dos objetos de projétil fica vazio (sem
// Outside Room herdado). A caixa é sempre lida de rh_box_inner() (dinâmica).
// Atenção: GML aqui não aceita ternário aninhado; use if/else.

// ── HELPER DE JUSTIÇA DO T1: valida o conjunto de espadas ──────────
// Recebe uma lista de {cx, cy, dir} e devolve true se:
//   (i)  >=30% das células da grade de 6 px estiverem fora de TODAS as trajetórias;
//   (ii) existir uma célula segura a <=56 px do coração (28 frames x 2 px).
// Geometria simples: segmento varrido por cada espada (meia-largura 16*0.7/2).
validar_barreira = function(_lista, _r) {
    var _meia = 16 * 0.7 / 2 + 1.5;
    var _total = 0;
    var _seguras = 0;
    var _alcancavel = false;
    var _hx = rh_heart_x();
    var _hy = rh_heart_y();

    for (var _gx = _r.x1 + 3; _gx <= _r.x2 - 3; _gx += 6) {
        for (var _gy = _r.y1 + 3; _gy <= _r.y2 - 3; _gy += 6) {
            _total++;
            var _livre = true;
            for (var i = 0; i < array_length(_lista); i++) {
                var _e = _lista[i];
                var _x1 = _e.cx - lengthdir_x(40, _e.dir);
                var _y1 = _e.cy - lengthdir_y(40, _e.dir);
                var _x2 = _e.cx + lengthdir_x(220, _e.dir);
                var _y2 = _e.cy + lengthdir_y(220, _e.dir);
                if (rh_dist_to_segment(_gx, _gy, _x1, _y1, _x2, _y2) <= _meia) {
                    _livre = false;
                    break;
                }
            }
            if (_livre) {
                _seguras++;
                if (point_distance(_gx, _gy, _hx, _hy) <= 56) _alcancavel = true;
            }
        }
    }
    return (_total > 0 && _seguras >= _total * 0.30 && _alcancavel);
};

// ── HELPER DE GEOMETRIA DO T3: segmento recortado na caixa ─────────
// Devolve {x1,y1,x2,y2} já dentro da caixa (com margem), para a faixa de 10 px
// não vazar pela borda. Devolve noone se o ponto estiver fora da caixa.
segmento_caixa = function(_px, _py, _ang, _r, _margem) {
    var _dx = cos(degtorad(_ang));
    var _dy = sin(degtorad(_ang));
    var _xa = _r.x1 + _margem;
    var _xb = _r.x2 - _margem;
    var _ya = _r.y1 + _margem;
    var _yb = _r.y2 - _margem;
    var _tmin = -10000;
    var _tmax = 10000;
    if (abs(_dx) < 0.0001) {
        if (_px < _xa || _px > _xb) return noone;
    } else {
        var _ta = (_xa - _px) / _dx;
        var _tb = (_xb - _px) / _dx;
        _tmin = max(_tmin, min(_ta, _tb));
        _tmax = min(_tmax, max(_ta, _tb));
    }
    if (abs(_dy) < 0.0001) {
        if (_py < _ya || _py > _yb) return noone;
    } else {
        var _tc = (_ya - _py) / _dy;
        var _td = (_yb - _py) / _dy;
        _tmin = max(_tmin, min(_tc, _td));
        _tmax = min(_tmax, max(_tc, _td));
    }
    if (_tmax <= _tmin) return noone;
    return {
        x1: _px + _dx * _tmin, y1: _py + _dy * _tmin,
        x2: _px + _dx * _tmax, y2: _py + _dy * _tmax
    };
};

// ── T1: BARREIRA DE ESPADAS ───────────────────────────────────────
// N=6/8/9, centros com >=18 px entre si, ângulos livres. Ajustes no topo.
pat_barreira = function(_t) {
    var _n = 6;
    var _vel = 3.4;
    var _p = trono_phase();
    if (_p == 2) { _n = 8; _vel = 3.8; }
    else if (_p == 3) { _n = 9; _vel = 4.2; }

    if (_t != 10 && _t != 150) exit;

    var _r = rh_box_inner();
    var _esc = 0.7;
    var _tentativas_max = 25;
    var _lista = [];
    var _candidatos = [];
    var _valido = false;

    for (var _tent = 0; _tent < _tentativas_max; _tent++) {
        _lista = [];
        for (var i = 0; i < _n; i++) {
            var _cx = 0;
            var _cy = 0;
            var _achou = false;
            for (var _k = 0; _k < 30; _k++) {
                var _px = irandom_range(_r.x1 + 8, _r.x2 - 8);
                var _py = irandom_range(_r.y1 + 8, _r.y2 - 8);
                var _longe = true;
                for (var _j = 0; _j < array_length(_lista); _j++) {
                    if (point_distance(_px, _py, _lista[_j].cx, _lista[_j].cy) < 18) {
                        _longe = false;
                        break;
                    }
                }
                if (_longe) { _cx = _px; _cy = _py; _achou = true; break; }
            }
            if (!_achou) continue;
            array_push(_lista, { cx: _cx, cy: _cy, dir: random(360) });
        }
        _candidatos = _lista;
        if (validar_barreira(_lista, _r)) { _valido = true; break; }
    }

    if (!_valido) {
        // Limite de 25 tentativas: remove espadas até a área segura fechar.
        _lista = [];
        for (var i = 0; i < array_length(_candidatos); i++) {
            array_push(_lista, _candidatos[i]);
            if (!validar_barreira(_lista, _r)) array_pop(_lista);
        }
        if (array_length(_lista) == 0) {
            // Válvula de escape: dois eixos opostos deixam bastante área livre.
            _lista = [
                { cx: _r.x1 + 12, cy: _r.y1 + 12, dir: 45 },
                { cx: _r.x2 - 12, cy: _r.y2 - 12, dir: 225 }
            ];
        }
    }

    for (var i = 0; i < array_length(_lista); i++) {
        var _e = _lista[i];
        var _s = rh_spawn_attack(obj_rh_atk_trono_espada, _e.cx, _e.cy);
        _s.dir = _e.dir;
        _s.spd = _vel;
        _s.esc = _esc;
        _s.fade_frames = 12;
        _s.telegraph_frames = 26;
        _s.delay_frames = irandom(8);
        _s.warn_tipo = 0;

        // Ponto da borda da caixa na direção da ponta (linha de aviso).
        var _dx = lengthdir_x(1, _e.dir);
        var _dy = lengthdir_y(1, _e.dir);
        var _tx = 10000;
        var _ty = 10000;
        if (_dx > 0.001) _tx = (_r.x2 - _e.cx) / _dx;
        else if (_dx < -0.001) _tx = (_r.x1 - _e.cx) / _dx;
        if (_dy > 0.001) _ty = (_r.y2 - _e.cy) / _dy;
        else if (_dy < -0.001) _ty = (_r.y1 - _e.cy) / _dy;
        var _tt = max(0, min(_tx, _ty));
        _s.warn_x2 = _e.cx + _dx * _tt;
        _s.warn_y2 = _e.cy + _dy * _tt;
    }
};

// ── T2: ANEL QUE CONVERGE ─────────────────────────────────────────
// N=8/10/12, raio 40, abertura de 3 espadas na fase 1 e 2 nas demais.
pat_anel = function(_t) {
    var _n = 8;
    var _gap = 3;
    var _vel = 2.8;
    var _p = trono_phase();
    if (_p == 2) { _n = 10; _gap = 2; _vel = 3.2; }
    else if (_p == 3) { _n = 12; _gap = 2; _vel = 3.6; }

    if (_t != 12 && _t != 156) exit;

    var _r = rh_box_inner();
    var _cx = clamp(rh_heart_x(), _r.x1 + 20, _r.x2 - 20);
    var _cy = clamp(rh_heart_y(), _r.y1 + 20, _r.y2 - 20);
    var _raio = 40;

    // Lado com mais espaço livre: a abertura nunca aponta para a parede.
    var _esq = _cx - _r.x1;
    var _dir = _r.x2 - _cx;
    var _cima = _cy - _r.y1;
    var _baixo = _r.y2 - _cy;
    var _abertura = 180;
    if (_dir > _esq && _dir >= _cima && _dir >= _baixo) _abertura = 0;
    else if (_cima > _esq && _cima >= _dir && _cima >= _baixo) _abertura = 90;
    else if (_baixo > _esq && _baixo >= _dir && _baixo >= _cima) _abertura = 270;

    var _passo = 360 / _n;
    var _idx0 = round(_abertura / _passo) mod _n;
    var _ini = _idx0 - (_gap div 2);

    for (var i = 0; i < _n; i++) {
        var _aberto = false;
        for (var _q = 0; _q < _gap; _q++) {
            if ((((i - (_ini + _q)) mod _n) + _n) mod _n == 0) { _aberto = true; break; }
        }
        if (_aberto) continue;

        var _ang = i * _passo;
        var _sx = _cx + lengthdir_x(_raio, _ang);
        var _sy = _cy + lengthdir_y(_raio, _ang);
        var _s = rh_spawn_attack(obj_rh_atk_trono_espada, _sx, _sy);
        _s.dir = point_direction(_sx, _sy, _cx, _cy);
        _s.spd = _vel;
        _s.esc = 0.7;
        _s.fade_frames = 8;
        _s.telegraph_frames = 28;
        _s.delay_frames = 0;
        _s.warn_tipo = 1;
        _s.warn_x2 = _cx;
        _s.warn_y2 = _cy;
    }
};

// ── T3: CORTES DIAGONAIS ──────────────────────────────────────────
// 2/3/4 linhas: fio vermelho 32 frames, faixa branca 7 frames, +8 de fade.
pat_cortes = function(_t) {
    var _n = 2;
    var _p = trono_phase();
    if (_p == 2) _n = 3;
    else if (_p == 3) _n = 4;

    if (_t != 10 && _t != 110 && _t != 210) exit;

    var _r = rh_box_inner();
    var _hx = rh_heart_x();
    var _hy = rh_heart_y();

    for (var i = 0; i < _n; i++) {
        var _ang = irandom_range(15, 165);
        var _px = irandom_range(_r.x1 + 8, _r.x2 - 8);
        var _py = irandom_range(_r.y1 + 8, _r.y2 - 8);
        if (i == 0) {
            // Passa perto do coração, mas NUNCA em cima dele no aviso.
            var _lado = choose(-1, 1);
            var _dst = irandom_range(12, 18) * _lado;
            var _perp = _ang + 90;
            _px = _hx + lengthdir_x(_dst, _perp);
            _py = _hy + lengthdir_y(_dst, _perp);
        }
        var _seg = segmento_caixa(_px, _py, _ang, _r, 6);
        if (_seg == noone) continue;

        var _s = rh_spawn_attack(obj_rh_atk_trono_slash,
                                 clamp(_px, _r.x1, _r.x2), clamp(_py, _r.y1, _r.y2));
        _s.x1 = _seg.x1;
        _s.y1 = _seg.y1;
        _s.x2 = _seg.x2;
        _s.y2 = _seg.y2;
        _s.ang = _ang;
        _s.largura = 10;
        _s.aviso_frames = 32;
        _s.delay_frames = i * 14;   // escalonadas: no máximo 1 ativa por vez
        _s.active_frames = 7;
        _s.fade_frames = 8;
    }
};

// ── T4: CHUVA DIAGONAL ────────────────────────────────────────────
// 10 espadas, 20° da vertical, lado alternado, corredor livre >=30 px.
pat_chuva_diagonal = function(_t) {
    var _vel = 3.2;
    var _p = trono_phase();
    if (_p == 2) _vel = 3.6;
    else if (_p == 3) _vel = 4.0;

    if (_t != 8 && _t != 100 && _t != 192) exit;

    var _r = rh_box_inner();
    var _lado = -1;
    if (_t == 100) _lado = 1;
    var _dir = 90 + _lado * 20;
    var _ang_perp = _dir + 90;

    // Corredor novo a cada volley: 42 px entre os centros dos grupos (a largura
    // 11 da espada deixa >=30 px de vão). Mantido perto do centro da caixa.
    var _pc = irandom_range(-15, 15);
    for (var i = 0; i < 10; i++) {
        var _coord;
        if (i < 5) _coord = -58 + (i + 0.5) * ((_pc - 21) + 58) / 5;
        else       _coord = (_pc + 21) + (i - 5 + 0.5) * (58 - (_pc + 21)) / 5;

        // Nasce dentro da room: y=30..52, x clampado em 10..310.
        var _sx = clamp(160 + lengthdir_x(_coord, _ang_perp), 10, 310);
        var _sy = clamp(42 + lengthdir_y(_coord, _ang_perp), 30, 52);

        var _s = rh_spawn_attack(obj_rh_atk_trono_espada, _sx, _sy);
        _s.dir = _dir;
        _s.spd = _vel;
        _s.esc = 0.7;
        _s.fade_frames = 4;
        _s.telegraph_frames = 22;
        _s.delay_frames = 0;
        _s.warn_tipo = 0;
        _s.warn_fraco = true;
        var _dx = lengthdir_x(1, _dir);
        var _dy = lengthdir_y(1, _dir);
        var _tt = (_r.y2 - _sy) / max(0.01, _dy);
        _s.warn_x2 = _sx + _dx * _tt;
        _s.warn_y2 = _r.y2;
    }
};

// ── T5: CHIFRES E CARTAS ──────────────────────────────────────────
// Tempo por _t (sem guarda exit). Chifre avisa 20 frames na altura travada.
pat_chifres_cartas = function(_t) {
    var _p = trono_phase();
    var _r = rh_box_inner();

    if (_t == 30 || _t == 110 || _t == 190) {
        var _da_esquerda = (_t != 110);
        var _cx = _r.x2 - 20;
        var _sentido = -1;
        if (_da_esquerda) { _cx = _r.x1 - 40; _sentido = 1; }
        var _c = rh_spawn_attack(obj_rh_atk_chifre, _cx,
                                 clamp(rh_heart_y() - 27, _r.y1 + 4, _r.y2 - 55));
        _c.vx = 2.5 * _sentido;
        if (_p == 3) _c.vx = 3.1 * _sentido;
        _c.y_travada = _c.y;
    }

    if (_t == 70 || _t == 150 || _t == 230) {
        var _n2 = 2;
        if (_p == 3) _n2 = 3;
        for (var i = 0; i < _n2; i++) {
            var _k = rh_spawn_attack(obj_rh_atk_carta, _r.x1 + 4,
                                     irandom_range(_r.y1 + 8, _r.y2 - 24));
            _k.vx = 2.0 + i * 0.15;
        }
    }
};

// ── T6: ICEBERGS ──────────────────────────────────────────────────
// 2 por leva, >=32 px entre centros, 22 frames de aviso na base.
pat_icebergs = function(_t) {
    var _p = trono_phase();
    if (_t != 16 && _t != 90 && _t != 164 && _t != 238) exit;

    var _r = rh_box_inner();
    var _lim = _r.x2 - 48;
    var _px0 = irandom_range(_r.x1 + 6, _r.x1 + 24);
    var _px1 = _px0 + irandom_range(32, 44);
    if (_px1 > _lim) {
        _px1 = _lim;
        _px0 = min(_px0, _px1 - 32);
    }
    var _pos = [_px0, _px1];

    for (var i = 0; i < 2; i++) {
        // y=149 e y=165: dentro da room, sem cortar a sprite de 42x47.
        var _ice = rh_spawn_attack(obj_rh_atk_iceberg, _pos[i], 149 + i * 16);
        _ice.vy = -2.0;
        if (_p == 3) _ice.vy = -2.6;
        _ice.y_base = _ice.y;
    }
};

patterns      = [pat_barreira, pat_anel, pat_cortes, pat_chuva_diagonal, pat_chifres_cartas, pat_icebergs];
pattern_names = ["barreira", "anel", "cortes", "chuva_diagonal", "chifres_e_cartas", "icebergs"];
