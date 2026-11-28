event_inherited();

// ── FICHA ─────────────────────────────────────────────────────────
enemy_name   = "Quinto do Inferno";
enemy_max_hp = 440;
dmg_min      = 4;
dmg_max      = 5;

// ── APARÊNCIA ─────────────────────────────────────────────────────
sprite_index = spr_quinto_do_inferno;
spr_hit      = spr_quinto_do_inferno_damage;
spr_defeated = spr_quinto_do_inferno_defeated;
sway_y = 4;  sway_angle = 0;
alarm[0] = -1;

// Estado dos quatro baús: frame em que termina a telegrafia de cada um.
// Um baú em telegrafia nunca entra em outro grupo; a fumaça é contada à parte.
bau_tele_ate = [0, 0, 0, 0];

// ── AUXILIAR: prepara um grupo de baús ─────────────────────────────
// Respeita: máx. 2 baús por grupo (nunca 3 adjacentes explodindo juntos),
// máx. 2 fumaças vivas e a geometria DINÂMICA da caixa (rh_box_inner).
quinto_spawn_baus = function(_t, _qtd_max, _tele, _escala, _gap, _yoff, _max_fuma) {
    var _r  = rh_box_inner();
    var _cx = (_r.x1 + _r.x2) / 2;
    var _bw = sprite_get_width(spr_bau_fechado_attack) * _escala;
    var _bh = sprite_get_height(spr_bau_fechado_attack) * _escala;
    var _passo = _bw + _gap;
    var _x0 = _cx - (4 * _bw + 3 * _gap) / 2;
    var _y  = _r.y2 + _yoff;

    // Se a opção de desenhar dentro da caixa for ligada, o baú precisa nascer dentro dela.
    if (RH_BAU_DENTRO) _y = _r.y2 - _bh - 2;

    // Baús disponíveis = os que não estão em telegrafia neste frame.
    var _disp = [0, 0, 0, 0];
    var _nd = 0;
    for (var i = 0; i < 4; i++) {
        if (_t >= bau_tele_ate[i]) { _disp[_nd] = i; _nd++; }
    }
    if (_nd <= 0) exit;
    if (instance_number(obj_rh_atk_fumaca_quinto) >= _max_fuma) exit;

    var _n = irandom_range(1, min(_qtd_max, _nd));  // sempre 1 ou 2
    for (var k = 0; k < _n; k++) {
        var _p   = irandom(_nd - 1);
        var _idx = _disp[_p];
        _disp[_p] = _disp[_nd - 1];  // remove sem buracos
        _nd--;

        var _b = rh_spawn_attack(obj_rh_atk_bau_quinto, _x0 + _idx * _passo, _y);
        _b.bau_idx     = _idx;
        _b.tele_total  = _tele;
        _b.escala_bau  = _escala;
        bau_tele_ate[_idx] = _t + _tele;
    }
};

// ── AUXILIAR: prepara o cachorro ──────────────────────────────────
quinto_spawn_cachorro = function(_aviso, _escala, _vel, _passagens, _paradas, _fogos, _max_fogos, _atira) {
    var _r = rh_box_inner();
    var _larg = sprite_get_width(spr_cachorro_inferno_attack) * _escala;
    var _alt  = sprite_get_height(spr_cachorro_inferno_attack) * _escala;
    var _da_esquerda = (irandom(1) == 0);
    var _x = _r.x1 - _larg - 2;
    if (!_da_esquerda) _x = _r.x2 + 2;   // nasce DENTRO da room, fora da caixa

    var _d = rh_spawn_attack(obj_rh_atk_cachorro_quinto, _x, _r.y2 - _alt);
    _d.dir              = _da_esquerda ? 1 : -1;
    _d.aviso_total      = _aviso;
    _d.escala_cachorro  = _escala;
    _d.vel_cachorro     = _vel;
    _d.max_passagens    = _passagens;
    _d.max_paradas      = _paradas;
    _d.tempo_parada     = 18;
    _d.fogos_por_parada = _fogos;
    _d.max_fogos        = _max_fogos;
    _d.atira            = _atira;
};

// ── PADRÃO 1: BAÚS ────────────────────────────────────────────────
pat_baus = function(_t) {
    // ── CONSTANTES ────────────────────────────────────────────────
    var TEMPOS     = [8, 60, 112, 164];  // início de cada grupo
    var TELE       = 90;                 // telegrafia; explosão em +90
    var MAX_GRUPO  = 2;                  // nunca 3 baús adjacentes juntos
    var MAX_FUMA   = 2;                  // no máx. 2 fumaças ativas
    var ESCALA_BAU = 0.85;
    var GAP_BAU    = 1;
    var YOFF_BAU   = 3;                  // topo em by2+3, termina antes do HUD (y=170)

    if (_t == 1) {
        for (var i = 0; i < 4; i++) bau_tele_ate[i] = 0;
    }
    for (var i = 0; i < 4; i++) {
        if (_t == TEMPOS[i]) {
            quinto_spawn_baus(_t, MAX_GRUPO, TELE, ESCALA_BAU, GAP_BAU, YOFF_BAU, MAX_FUMA);
            exit;
        }
    }
};

// ── PADRÃO 2: CACHORRO ────────────────────────────────────────────
pat_cachorro = function(_t) {
    // ── CONSTANTES ────────────────────────────────────────────────
    var SPAWN_T    = 6;
    var AVISO      = 22;
    var ESCALA     = 0.75;   // 64x47 -> 48x35, ~43 px livres acima
    var VEL        = 2.24;   // 30% mais lento (era 3.2)
    var PASSAGENS  = 3;
    var PARADAS    = 3;
    var FOGOS      = 2;
    var MAX_FOGOS  = 6;

    if (_t != SPAWN_T) exit;
    quinto_spawn_cachorro(AVISO, ESCALA, VEL, PASSAGENS, PARADAS, FOGOS, MAX_FOGOS, true);
};

// ── PADRÃO 3: COBRANÇA ────────────────────────────────────────────
// Baú (t=8) -> cachorro sem tiro (t=120) -> baú (t=160). As explosões
// (98 e 250) não coincidem com a travessia (~142..190).
pat_cobranca = function(_t) {
    // ── CONSTANTES ────────────────────────────────────────────────
    var TEMPOS     = [8, 160];
    var TELE       = 90;
    var MAX_GRUPO  = 1;
    var MAX_FUMA   = 2;
    var ESCALA_BAU = 0.85;
    var GAP_BAU    = 1;
    var YOFF_BAU   = 3;
    var CACH_T     = 120;
    var AVISO      = 22;
    var ESCALA     = 0.75;
    var VEL        = 2.24;   // 30% mais lento (era 3.2)

    if (_t == 1) {
        for (var i = 0; i < 4; i++) bau_tele_ate[i] = 0;
    }
    if (_t == CACH_T) {
        quinto_spawn_cachorro(AVISO, ESCALA, VEL, 1, 0, 0, 0, false);
    }
    for (var i = 0; i < 2; i++) {
        if (_t == TEMPOS[i]) {
            quinto_spawn_baus(_t, MAX_GRUPO, TELE, ESCALA_BAU, GAP_BAU, YOFF_BAU, MAX_FUMA);
            exit;
        }
    }
};

patterns      = [pat_baus, pat_cachorro, pat_cobranca];
pattern_names = ["baus", "cachorro", "cobranca"];
