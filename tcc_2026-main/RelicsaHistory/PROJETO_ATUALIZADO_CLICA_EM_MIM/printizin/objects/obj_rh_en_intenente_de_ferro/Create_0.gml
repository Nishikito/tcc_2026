event_inherited();

// ── FICHA ─────────────────────────────────────────────────────────
enemy_name   = "Intenente de Ferro";
enemy_max_hp = 400;
dmg_min      = 4;   // antes era 5: agora 4-5
dmg_max      = 5;

// ── APARÊNCIA ─────────────────────────────────────────────────────
// Posição e escala vêm do obj_rh_battle_enemy (sprite encaixado na área do inimigo).
sprite_index = spr_intenente_de_ferro;
spr_hit      = spr_intenente_de_ferro_damage;
spr_defeated = spr_intenente_de_ferro_defeated;
sway_y = 4;  sway_angle = 0;
alarm[0] = -1;

// Contadores de ritmo: os padrões usam só _t e estes contadores (sem instance_exists).
martelo_step  = 0;   // 0 = esquerda, 1 = direita, 2 = MIRADA no coração
sentenca_step = 0;   // alterna o lado da Sentença

// ── PADRÃO 1: Marteladas ── (esquerda → direita → MIRADA travada no coração)
pat_marteladas = function(_t) {
    // ── CONSTANTES DE AJUSTE ──────────────────────────────────────
    var AVISO   = 30;   // frames de aviso vermelho na área de impacto
    var PREP    = 14;   // preparação: levantar/inclinar para trás com tremida
    var QUEDA   = 6;    // descida rápida e acelerada
    var ZONA    = 10;   // frames da hitbox da cabeça (single-hit)
    var DMG     = 1.5;  // golpe pesado
    var MARGEM  = 22;   // distância do centro da cabeça até a borda da caixa
    var LOCK_DT = 20;   // MIRADA: trava o x do coração 20 frames antes do impacto

    if (_t != 8 && _t != 100 && _t != 190) exit;

    var _r = rh_box_inner();
    var _step = martelo_step mod 3;
    var _px, _py, _lock;

    if (_step == 0) {
        _px   = _r.x1 + MARGEM;   // martelada da esquerda
        _lock = false;
    } else if (_step == 1) {
        _px   = _r.x2 - MARGEM;   // martelada da direita
        _lock = false;
    } else {
        // MIRADA: começa sobre o coração, mas congela no fim do aviso.
        _px   = clamp(rh_heart_x(), _r.x1 + MARGEM, _r.x2 - MARGEM);
        _lock = true;
    }
    _py = max(0, _r.y1 - 8);   // spawn SEMPRE dentro da room

    var _h = rh_spawn_attack(obj_rh_atk_martelo_ferro, _px, _py);
    _h.mode        = 0;
    _h.px          = _px;
    _h.py          = _py;
    _h.warn_frames = AVISO;
    _h.prep_frames = PREP;
    _h.fall_frames = QUEDA;
    _h.zone_frames = ZONA;
    _h.lock_heart  = _lock;
    _h.lock_frame  = AVISO + PREP + QUEDA - LOCK_DT;   // 50 - 20 = 30
    _h.dmg_mult    = DMG;

    martelo_step++;
};

// ── PADRÃO 2: Barras ── (salvas de 2 barras em colunas; brilham e quebram no chão)
pat_barras = function(_t) {
    // ── CONSTANTES DE AJUSTE ──────────────────────────────────────
    var AVISO  = 22;     // aviso no ponto de pouso antes de aparecer
    var GRAV   = 0.12;   // aceleração por frame
    var VY_MAX = 3.4;    // velocidade máxima de queda
    var ESCALA = 0.6;    // 43x14 -> ~25.8x8.4 px
    var GAP    = 32;     // vão MÍNIMO entre os centros das duas barras
    var DMG    = 1.0;

    if (_t != 10 && _t != 100 && _t != 190) exit;

    var _r = rh_box_inner();
    var _bw = sprite_get_width(spr_donou2_attack)  * ESCALA;
    var _bh = sprite_get_height(spr_donou2_attack) * ESCALA;

    // Uma barra fica sobre a coluna do coração: posição TRAVADA no aviso.
    var _hx = clamp(rh_heart_x(), _r.x1 + _bw / 2, _r.x2 - _bw / 2);
    // A outra fica a GAP px para o lado com MAIS ESPAÇO: mantém o vão mesmo
    // quando o coração está encostado numa borda da caixa.
    var _dir = (_hx - _r.x1 < _r.x2 - _hx) ? 1 : -1;
    var _ox  = clamp(_hx + _dir * GAP,
                     _r.x1 + _bw / 2, _r.x2 - _bw / 2);

    var _b1 = rh_spawn_attack(obj_rh_atk_barra_ferro, _hx - _bw / 2, _r.y1 + 4);
    var _b2 = rh_spawn_attack(obj_rh_atk_barra_ferro, _ox - _bw / 2, _r.y1 + 4);

    var _i;
    for (_i = 0; _i < 2; _i++) {
        var _b = (_i == 0) ? _b1 : _b2;
        _b.mode        = 0;   // salvo comum: quebra ao tocar o chão
        _b.bar_w       = _bw;
        _b.bar_h       = _bh;
        _b.ground_y    = _r.y2 - _bh;
        _b.warn_frames = AVISO;
        _b.grav        = GRAV;
        _b.vy_max      = VY_MAX;
        _b.dmg_mult    = DMG;
    }
};

// ── PADRÃO 3: Sentença ── (barra repousa, martelo esmaga, barra rasteja)
pat_sentenca = function(_t) {
    // ── CONSTANTES DE AJUSTE ──────────────────────────────────────
    var AVISO  = 22;     // aviso no ponto de pouso
    var GRAV   = 0.12;   // aceleração da queda
    var VY_MAX = 3.4;
    var RESTO  = 30;     // frames inofensiva, parada no chão
    var LINHA  = 20;     // aviso de seta/linha no chão antes do lançamento
    var SMASH  = 6;      // frames do martelo pequeno que esmaga
    var VX     = 5;      // px/frame da barra lançada
    var ESCALA = 0.6;
    var DMG    = 1.0;

    if (_t != 10 && _t != 150) exit;

    var _r = rh_box_inner();
    var _bw = sprite_get_width(spr_donou2_attack)  * ESCALA;
    var _bh = sprite_get_height(spr_donou2_attack) * ESCALA;
    var _esquerda = (sentenca_step mod 2 == 0);   // alterna o lado
    var _cx = _esquerda ? _r.x1 + _bw / 2 + 6 : _r.x2 - _bw / 2 - 6;

    var _b = rh_spawn_attack(obj_rh_atk_barra_ferro, _cx - _bw / 2, _r.y1 + 4);
    _b.mode             = 1;   // Sentença: não quebra ao pousar
    _b.bar_w            = _bw;
    _b.bar_h            = _bh;
    _b.ground_y         = _r.y2 - _bh;
    _b.warn_frames      = AVISO;
    _b.grav             = GRAV;
    _b.vy_max           = VY_MAX;
    _b.rest_frames      = RESTO;
    _b.warn_line_frames = LINHA;
    _b.smash_frames     = SMASH;
    _b.launch_dir       = _esquerda ? 1 : -1;   // para o lado oposto
    _b.launch_speed     = VX;
    _b.dmg_mult         = DMG;

    sentenca_step++;
};

patterns      = [pat_marteladas, pat_barras, pat_sentenca];
pattern_names = ["marteladas", "barras", "sentenca"];
