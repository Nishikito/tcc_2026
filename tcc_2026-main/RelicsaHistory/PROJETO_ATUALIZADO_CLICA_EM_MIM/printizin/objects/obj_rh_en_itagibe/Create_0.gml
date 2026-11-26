event_inherited();

// ── FICHA ─────────────────────────────────────────────────────────
enemy_name   = "Itagibe";
enemy_max_hp = 280;
dmg_min      = 2;
dmg_max      = 4;

// ── APARÊNCIA ─────────────────────────────────────────────────────
sprite_index = spr_itagibe;
spr_hit      = spr_itagibe_damage;
spr_defeated = spr_itagibe_defeated;
sway_y = 4;  sway_angle = 0;
alarm[0] = -1;

// ===================================================================
// PADRÕES DO ITAGIBE (estilo Knight/Deltarune)
// Regras comuns: aviso sempre antes do voo; golpes retos e sem perseguição;
// apenas _t (1..300) para o tempo; sempre sobra caminho seguro.
// As constantes de cada padrão ficam no TOPO da função, para o dono ajustar.
// ===================================================================

// ── ROUND 1: lanças laterais (4 raias horizontais) ──────────────────
// Salvas 1 e 3 vêm da direita (sprite original, ponta à esquerda);
// salvas 2 e 4 vêm da esquerda (sprite espelhado, ponta à direita).
round_lancas_laterais = function(_t) {
    var n_raias      = 4;
    var alt_raia     = 19;                    // 78 px úteis / 4
    var topo_lanca   = 3.5;                   // centraliza a lança de 12 px na raia
    var vezes        = [10, 80, 150, 220];    // início da telegrafia de cada salva
    var aviso        = 22;                    // frames piscando antes do voo
    var velocidade   = 4.2;                   // px/frame, reto
    var espaco       = 8;                     // frames entre lanças da mesma salva
    var extras       = [1, 1, 2, 2];          // raias extras (além da do coração)

    for (var _s = 0; _s < array_length(vezes); _s++) {
        if (_t != vezes[_s]) continue;

        var _r = rh_box_inner();
        var _cor_y = rh_heart_y();
        var _raia_coracao = clamp(floor((_cor_y - _r.y1) / alt_raia), 0, n_raias - 1);

        // Travamos a raia do coração no instante do aviso (depois não acompanha).
        var _escolhidas = [_raia_coracao];
        var _disponiveis = [];
        for (var _i = 0; _i < n_raias; _i++) {
            if (_i != _raia_coracao) array_push(_disponiveis, _i);
        }
        for (var _k = 0; _k < extras[_s]; _k++) {
            var _idx = irandom(array_length(_disponiveis) - 1);
            array_push(_escolhidas, _disponiveis[_idx]);
            array_delete(_disponiveis, _idx, 1);
        }

        var _vem_da_direita = (_s == 0 || _s == 2);
        for (var _i = 0; _i < array_length(_escolhidas); _i++) {
            var _y = _r.y1 + _escolhidas[_i] * alt_raia + topo_lanca;
            // Nasce FORA da caixa, mas com a máscara inteira dentro da room:
            // direita -> x = bx2+1 (máscara 205..270); esquerda -> x = bx1-66 (40..105).
            var _x = _vem_da_direita ? (_r.x2 + 1) : (_r.x1 - 66);
            var _l = rh_spawn_attack(obj_rh_atk_lanca_h, _x, _y);
            _l.dir         = _vem_da_direita ? 180 : 0;
            _l.spd         = velocidade;
            // O escalonamento é feito alongando o aviso: todas piscam juntas,
            // mas cada lança entra 8 frames depois da anterior.
            _l.warn_frames = aviso + _i * espaco;
            _l.warn_x1     = _r.x1;
            _l.warn_x2     = _r.x2;
            _l.warn_y1     = _y - topo_lanca;
            _l.warn_y2     = _y - topo_lanca + alt_raia;
        }
    }
};

// ── ROUND 2: lanças verticais (6 colunas) ──────────────────────────
// Sempre 3 de cima; nas salvas ímpares, +1 de baixo.
// Um par de colunas adjacentes é sorteado ANTES como vão seguro.
// Atenção: em GML 90° = baixo e 270° = cima — por isso usamos vy explícito.
round_lancas_verticais = function(_t) {
    var n_colunas    = 6;
    var vezes        = [8, 84, 160, 236];
    var aviso        = 20;                    // ~22 frames, nunca menos que 20
    var velocidade   = 4.2;
    var espaco       = 4;                     // salva vertical mais compacta (cabe antes de 300)
    var cima         = 3;                     // lanças de cima por salva
    var baixo        = 1;                     // lanças de baixo nas salvas ímpares

    for (var _s = 0; _s < array_length(vezes); _s++) {
        if (_t != vezes[_s]) continue;

        var _r = rh_box_inner();
        var _largura_coluna = (_r.x2 - _r.x1 + 1) / n_colunas; // ~16.5 px
        var _coluna_coracao = clamp(floor((rh_heart_x() - _r.x1) / _largura_coluna), 0, n_colunas - 1);

        // Escolhe um vão seguro de 2 colunas adjacentes que NÃO contenha o coração.
        var _vaos = [];
        for (var _g = 0; _g < n_colunas - 1; _g++) {
            if (_g != _coluna_coracao && _g + 1 != _coluna_coracao) array_push(_vaos, _g);
        }
        var _vao = _vaos[irandom(array_length(_vaos) - 1)];

        // As colunas atacadas são o complemento do vão; a do coração está garantida.
        var _atacadas = [];
        for (var _c = 0; _c < n_colunas; _c++) {
            if (_c != _vao && _c != _vao + 1) array_push(_atacadas, _c);
        }
        // Embaralha só a ordem de chegada; a coluna do coração continua no grupo.
        for (var _i = array_length(_atacadas) - 1; _i > 0; _i--) {
            var _j = irandom(_i);
            var _tmp = _atacadas[_i]; _atacadas[_i] = _atacadas[_j]; _atacadas[_j] = _tmp;
        }

        var _impares = (_s == 0 || _s == 2);
        var _de_baixo = _impares ? _atacadas[array_length(_atacadas) - 1] : -1;

        // 3 lanças descendo (ponta para baixo).
        for (var _i = 0; _i < cima; _i++) {
            var _c = _atacadas[_i];
            var _x = _r.x1 + _c * _largura_coluna + (_largura_coluna - 12) / 2;
            // y = by1-66 = -1: ponta em y=64 (logo acima da caixa) e máscara -1..64,
            // parcialmente dentro da room, então o Outside Room não a destrói.
            var _l = rh_spawn_attack(obj_rh_atk_lanca_v, _x, _r.y1 - 66);
            _l.sprite_index = spr_lanca_down_attack;
            _l.vy           = velocidade;
            _l.warn_frames  = aviso + _i * espaco;
            _l.warn_x1      = _x;
            _l.warn_x2      = _x + 12;
            _l.warn_y1      = _r.y1;
            _l.warn_y2      = _r.y2;
            _l.sair         = "baixo";
        }

        // 1 lança subindo (ponta para cima), só nas salvas ímpares.
        if (_impares && _de_baixo >= 0) {
            var _xb = _r.x1 + _de_baixo * _largura_coluna + (_largura_coluna - 12) / 2;
            var _b = rh_spawn_attack(obj_rh_atk_lanca_v, _xb, _r.y2 + 1);
            _b.sprite_index = spr_lanca_up_attack;
            _b.vy           = -velocidade;
            _b.warn_frames  = aviso;
            _b.warn_x1      = _xb;
            _b.warn_x2      = _xb + 12;
            _b.warn_y1      = _r.y1;
            _b.warn_y2      = _r.y2;
            _b.sair         = "cima";
        }
    }
};

// ── ROUND 3: vasos e chuva de ossos ────────────────────────────────
// Três formações sorteadas a cada onda:
//   0 "pontas":  dois vasos nas pontas, POUCOS ossos convergindo para o meio;
//   1 "centro":  vasos no meio, CHUVA com mais ossos caindo quase reto;
//   2 "terços":  formação intermediária, ossos convergindo com mais vagar.
// O vaso treme 24 frames (aviso); os ossos giram por código ao sair dele.
round_vasos_ossos = function(_t) {
    var vezes        = [8, 150];       // duas ondas
    var larg_vaso    = 27;
    var sep_minima   = 36;             // entre os dois vasos
    var dist_coracao = 18;             // ~20 px do centro do coração (geometria da caixa limita)
    var intervalo    = 9;
    var grav         = 0.16;           // ver relatório: 0.11 deixava o último osso passar de 300
    var vy0_min      = -3.2;
    var vy0_max      = -3.8;
    var limite_ossos = 8;

    // Constantes de cada formação ficam juntas, no topo do padrão.
    var formacoes = [
        { tipo: 0, ossos: 2, tendencia: 0.45 },  // pontas: poucos ossos, convergindo
        { tipo: 1, ossos: 4, tendencia: 0.12 },  // centro: chuva mais cheia, quase reta
        { tipo: 2, ossos: 3, tendencia: 0.22 }   // terços: intermediário
    ];

    for (var _o = 0; _o < array_length(vezes); _o++) {
        if (_t != vezes[_o]) continue;

        var _r = rh_box_inner();
        var _cor_x = rh_heart_x();
        var _y_vaso = _r.y2 - 15;      // apoiado no chão da caixa
        var _meio_caixa = (_r.x1 + _r.x2) / 2;
        var _f = formacoes[irandom(array_length(formacoes) - 1)];

        var _x1, _x2;
        if (_f.tipo == 0) {
            // Pontas: pequeno deslocamento para dentro, nunca exatamente no canto.
            _x1 = _r.x1 + 2 + irandom(8);
            _x2 = _r.x2 - larg_vaso - 2 - irandom(8);
        } else if (_f.tipo == 1) {
            // Centro: separação de 40 px entre os centros dos vasos.
            _x1 = _meio_caixa - 20 - larg_vaso / 2 + irandom_range(-6, 6);
            _x2 = _meio_caixa + 20 - larg_vaso / 2 + irandom_range(-6, 6);
        } else {
            // Terços: entre o canto e o centro, com jitter.
            _x1 = _r.x1 + 13.5 + 14 - larg_vaso / 2 + irandom_range(-6, 6);
            _x2 = _r.x2 - 13.5 - 14 - larg_vaso / 2 + irandom_range(-6, 6);
        }
        if (_x1 > _x2) { var _tmp = _x1; _x1 = _x2; _x2 = _tmp; }

        // Ajuste iterativo: afasta do coração e preserva a separação mínima.
        for (var _k = 0; _k < 6; _k++) {
            var _xs = [_x1, _x2];
            for (var _i = 0; _i < 2; _i++) {
                var _x = _xs[_i];
                var _centro = _x + larg_vaso / 2;
                if (abs(_centro - _cor_x) < dist_coracao) {
                    var _afasta = (_centro < _cor_x) ? -1 : 1;
                    _x += _afasta * (dist_coracao - abs(_centro - _cor_x));
                    _x = clamp(_x, _r.x1 - 18, _r.x2 - larg_vaso + 18);
                }
                _xs[_i] = _x;
            }
            _x1 = _xs[0];
            _x2 = _xs[1];

            var _sep = abs((_x2 + larg_vaso / 2) - (_x1 + larg_vaso / 2));
            if (_sep >= sep_minima) break;

            // Quem está mais longe do coração é empurrado para fora da caixa.
            var _falta = sep_minima - _sep + 0.5;
            var _d1 = abs(_x1 + larg_vaso / 2 - _cor_x);
            var _d2 = abs(_x2 + larg_vaso / 2 - _cor_x);
            if (_d1 >= _d2) {
                _x1 += ((_x1 < _x2) ? -1 : 1) * _falta;
            } else {
                _x2 += ((_x2 > _x1) ? 1 : -1) * _falta;
            }
            _x1 = clamp(_x1, _r.x1 - 18, _r.x2 - larg_vaso + 18);
            _x2 = clamp(_x2, _r.x1 - 18, _r.x2 - larg_vaso + 18);
        }

        for (var _v = 0; _v < 2; _v++) {
            var _x = (_v == 0) ? _x1 : _x2;
            var _vaso = rh_spawn_attack(obj_rh_atk_vaso_itagibe, _x, _y_vaso);
            _vaso.n_bones        = _f.ossos;
            _vaso.bone_interval  = intervalo;
            _vaso.grav           = grav;
            _vaso.vy0_min        = vy0_min;
            _vaso.vy0_max        = vy0_max;
            _vaso.limite_ossos   = limite_ossos;
            // vx compartilhado por todos os ossos do mesmo vaso mantém a coerência
            // e a cobertura bem abaixo de 40% da caixa.
            if (_f.tipo == 1) {
                _vaso.vx_ossos = choose(-1 * _f.tendencia, 0, _f.tendencia);
            } else {
                var _para_o_meio = (_x < _meio_caixa) ? 1 : -1;
                _vaso.vx_ossos = _para_o_meio * _f.tendencia + choose(-0.05, 0, 0.05);
            }
        }
    }
};

patterns = [round_lancas_laterais, round_lancas_verticais, round_vasos_ossos];

pattern_names = ["lancas laterais", "lancas verticais", "vasos e ossos"];
