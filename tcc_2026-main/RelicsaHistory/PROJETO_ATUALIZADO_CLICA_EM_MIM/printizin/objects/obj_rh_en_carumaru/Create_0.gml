event_inherited();

// ── FICHA ─────────────────────────────────────────────────────────
enemy_name   = "Carumaru";
enemy_max_hp = 240;
dmg_min      = 2;
dmg_max      = 4;

// ── APARÊNCIA ─────────────────────────────────────────────────────
sprite_index = spr_carumaru;
spr_hit      = spr_carumaru_damage;
spr_defeated = spr_carumaru_defeated;
sway_y = 6;  sway_angle = 0;
alarm[0] = -1;

// CORRIGIDO: sequências por tempo (sem guardas instance_exists). Um turno dura 300 frames.
// Os ataques que nascem acima/fora da caixa (mas dentro da room) têm Other_0 vazio e
// se autodestruem por tempo; o Outside Room não os apaga.

// ── AUXILIAR DE SPAWN (C2 e C3) ─────────────────────────────────────
// Cria um fantasma com personalidade. (x,y) = CENTRO do sprite.
// spr_ghost_attack (22x46) = seguidor/eco; spr_fantasma_carumaru_attack (33x65) = parede.
spawn_fantasma_carumaru = function(_tipo) {
    // ── CONSTANTES DE AJUSTE (spawn) ──
    var DIST_MIN   = 40;   // distância mínima do centro do coração no nascimento
    var TENTATIVAS = 20;   // tentativas antes de usar o ponto mais distante
    var MARGEM     = 40;   // faixa fora da caixa onde o fantasma pode nascer
    var VIDA       = 200;  // vida total
    var FADE_IN    = 30;   // frames semi-transparentes e INOFENSIVOS
    var FADE_OUT   = 20;   // frames de fade final (também inofensivos)
    var VEL        = 0.8;  // avanço do seguidor/eco e do deslizamento da parede
    var TURN_EVERY = 60;   // a parede "vira" para o coração a cada 60 frames

    var _r   = rh_box_inner();
    var _spr = (_tipo == "parede") ? spr_fantasma_carumaru_attack : spr_ghost_attack;
    var _sw  = sprite_get_width(_spr);
    var _sh  = sprite_get_height(_spr);
    var _x1  = max(_sw / 2 + 2, _r.x1 - MARGEM + _sw / 2);
    var _x2  = min(room_width  - _sw / 2 - 2, _r.x2 + MARGEM - _sw / 2);
    var _y1  = max(_sh / 2 + 2, _r.y1 - MARGEM + _sh / 2);
    var _y2  = min(room_height - _sh / 2 - 2, _r.y2 + MARGEM - _sh / 2);

    var _hx = rh_heart_x();
    var _hy = rh_heart_y();
    var _bx = _hx;
    var _by = _hy;
    var _best = -1;
    for (var _i = 0; _i < TENTATIVAS; _i++) {
        var _px = random_range(_x1, _x2);
        var _py = random_range(_y1, _y2);
        var _d  = point_distance(_px, _py, _hx, _hy);
        if (_d > _best) { _best = _d; _bx = _px; _by = _py; }
        if (_d >= DIST_MIN) { _bx = _px; _by = _py; break; }
    }

    var _g = rh_spawn_attack(obj_rh_atk_fantasma_carumaru2, _bx, _by);
    _g.personality = _tipo;
    _g.sprite_index = _spr;
    _g.vida       = VIDA;
    _g.fade_in    = FADE_IN;
    _g.fade_out   = FADE_OUT;
    _g.vel        = VEL;
    _g.turn_every = TURN_EVERY;
    _g.eco_buffer = [];
    return _g;
};

// ── PADRÃO 1 (C1): LÁGRIMAS ─────────────────────────────────────────
// TIMELINE: t=10,46,82,118,154,190,226,262 => 5 gotas/fileira (spr_drop_attack 10x17).
//   t+1..t+18: paradas no topo, aviso vermelho, inofensivas;
//   t+19 em diante: queda com vy 0.8 -> 3.0 (grav 0.05);
//   ao tocar o chão: viram 2 gotas "splash" do MESMO objeto, vx = +/-1.7, vida 22.
// O vão é LIVRE entre sprites (>=28 px), então o passo entre centros é 10+28=38 px.
// A deriva é +/-1 coluna por fileira; gotas fora da caixa são recortadas e inofensivas.
pat_lagrimas = function(_t) {
    // ── CONSTANTES DE AJUSTE ──
    var LINHAS     = [10, 46, 82, 118, 154, 190, 226, 262];
    var LAG_VAO    = 28;                       // vão livre entre gotas (px)
    var LAG_WARN   = 18;                       // frames de aviso antes da queda
    var LAG_DERIVA = [0, 1, 0, -1, 0, 1, 0, -1]; // deslocamento em colunas por fileira
    var LAG_Y      = -16;                      // nascem acima da borda superior
    var LAG_VY0    = 0.8;
    var LAG_VYMAX  = 3.0;
    var LAG_GRAV   = 0.05;
    var LAG_N      = 5;                        // gotas por fileira

    var _li = -1;
    for (var _i = 0; _i < array_length(LINHAS); _i++) {
        if (_t == LINHAS[_i]) { _li = _i; break; }
    }
    if (_li < 0) exit;

    var _r    = rh_box_inner();
    var _passo = sprite_get_width(spr_drop_attack) + LAG_VAO;
    var _base = (_r.x1 + _r.x2) / 2 - 2 * _passo;  // 5 colunas: -2,-1,0,+1,+2
    var _x    = _base + LAG_DERIVA[_li] * _passo;
    var _y    = _r.y1 + LAG_Y;
    for (var _c = 0; _c < LAG_N; _c++) {
        var _g = rh_spawn_attack(obj_rh_atk_lagrima_carumaru, _x + _c * _passo, _y);
        _g.modo    = "fileira";
        _g.warn_t  = LAG_WARN;
        _g.vx      = 0;
        _g.vy      = LAG_VY0;
        _g.vy_max  = LAG_VYMAX;
        _g.grav    = LAG_GRAV;
        _g.vida    = 240;  // tempo de segurança (sem Outside Room)
    }
    rh_debug("Carumaru C1: fileira " + string(_li + 1) + "/8 @ t=" + string(_t));
};

// ── PADRÃO 2 (C2): FANTASMAS ────────────────────────────────────────
// TIMELINE: t=10 => SEGUIDOR + ECO; t=120 => PAREDE (máx. 3 ao mesmo tempo).
//   0..29: semi-transparente e inofensivo; 30..179: ativo;
//   180..199: fade inofensivo; 200: destrói.
// SEGUIDOR: 0.8 px/frame direto ao coração. ECO: alvo = posição do coração 40 frames atrás
//   (buffer por instância, uma posição por frame). PAREDE: borda da caixa, vira a cada 60 frames.
// Hitbox = 80% do sprite; o coração já vem com RH_HEART_SHRINK em rh_heart_rect().
pat_fantasmas = function(_t) {
    // ── CONSTANTES DE AJUSTE ──
    var LANC_T10 = 10;
    var LANC_T120 = 120;
    var MAX_ATIVOS = 3;   // 2 em t=10 + 1 em t=120 (respeita o limite)

    if (_t == LANC_T10) {
        spawn_fantasma_carumaru("seguidor");
        spawn_fantasma_carumaru("eco");
        rh_debug("Carumaru C2: seguidor + eco @ t=" + string(_t));
    }
    if (_t == LANC_T120) {
        spawn_fantasma_carumaru("parede");
        rh_debug("Carumaru C2: parede @ t=" + string(_t));
    }
};

// ── PADRÃO 3 (C3): CHORO ────────────────────────────────────────────
// TIMELINE: t=10,100,190 => 3 arcos de canto (aviso 16 frames);
//           t=55 => 1 seguidor; t=145 => 1 eco. Sem guardas instance_exists.
// Arco: vx 1.6..2.2 cruzando a caixa, vy inicial -1.5, gravidade 0.06, vida 170.
pat_choro = function(_t) {
    // ── CONSTANTES DE AJUSTE ──
    var ARCOS      = [10, 100, 190];
    var FANTASMAS  = [55, 145];
    var ARCO_WARN  = 16;
    var ARCO_N     = 3;
    var ARCO_VXMIN = 1.6;
    var ARCO_VXMAX = 2.2;
    var ARCO_VY0   = -1.5;
    var ARCO_GRAV  = 0.06;
    var ARCO_VIDA  = 170;

    var _r = rh_box_inner();
    for (var _s = 0; _s < array_length(ARCOS); _s++) {
        if (_t != ARCOS[_s]) continue;
        var _lado = (_s mod 2 == 0) ? 1 : -1;  // alterna canto superior esquerdo/direito
        for (var _k = 0; _k < ARCO_N; _k++) {
            var _sx = (_lado > 0) ? _r.x1 - 8 - _k * 12 : _r.x2 + 8 + _k * 12;
            var _sy = _r.y1 - 10 - _k * 4;
            var _a = rh_spawn_attack(obj_rh_atk_lagrima_carumaru, _sx, _sy);
            _a.modo   = "arco";
            _a.warn_t = ARCO_WARN;
            _a.vx     = _lado * random_range(ARCO_VXMIN, ARCO_VXMAX);
            _a.vy     = ARCO_VY0;
            _a.grav   = ARCO_GRAV;
            _a.vy_max = 4.0;
            _a.vida   = ARCO_VIDA;
        }
        rh_debug("Carumaru C3: salvo de arco " + string(_s + 1) + "/3 @ t=" + string(_t));
    }

    if (_t == FANTASMAS[0]) spawn_fantasma_carumaru("seguidor");
    if (_t == FANTASMAS[1]) spawn_fantasma_carumaru("eco");
};

patterns      = [pat_lagrimas, pat_fantasmas, pat_choro];
pattern_names = ["lagrimas", "fantasmas", "choro"];
