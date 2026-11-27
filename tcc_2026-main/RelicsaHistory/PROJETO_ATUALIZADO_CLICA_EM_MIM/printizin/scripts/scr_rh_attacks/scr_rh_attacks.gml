// ══════════════════════════════════════════════════════════════════
// ATAQUES VARIADOS (inspirados nos padrões de Undertale) — funções e macros comuns
// ──────────────────────────────────────────────────────────────────
// Quem usa: todos os obj_rh_atk_* (projéteis/ataques) e obj_rh_en_* (inimigos).
// Regra de ouro: TODO ataque é "filho" de obj_rh_battle_bullet. Assim o coração
// (obj_rh_battle_player) e o controller continuam funcionando sem mudanças:
//   - o coração só machuca ataques com active == true, UMA vez por ataque;
//   - o controller apaga todos os filhos de obj_rh_battle_bullet no fim do turno.
// Manual: ATAQUES_VARIADOS.md (na pasta do projeto).
// ══════════════════════════════════════════════════════════════════

#macro RH_BULLET_DEPTH      1   // projéteis: à frente da caixa (10), atrás do coração (-1)

#macro RH_ATK_DEBUG_ZONES   false   // true = contorna em vermelho tudo que está machucando (para testar)
#macro RH_HEART_SHRINK      0.85    // folga a favor do jogador nas hitboxes de geometria própria
#macro RH_BAU_DENTRO        false   // Quinto do Inferno: true = baús desenhados DENTRO da caixa (troca depois)

// ── DIAGNÓSTICO DE ATAQUES (Tarefa 1) ─────────────────────────────
// Mude para true (e, se quiser, RH_DEBUG_FORCE_PATTERN para 0..2) para ver no Output:
// início de turno, padrão escolhido, cada spawn, cada destruição e o motivo.
#macro RH_DEBUG               false
#macro RH_DEBUG_FORCE_PATTERN -1     // -1 = normal; 0, 1, 2... = força esse índice

function rh_debug(_msg) {
    if (RH_DEBUG) show_debug_message("[RH] " + string(_msg));
}

function rh_debug_spawn(_obj, _x, _y) {
    if (RH_DEBUG) {
        show_debug_message("[RH][SPAWN] " + object_get_name(_obj)
                           + " @ " + string(round(_x)) + "," + string(round(_y)));
    }
}

function rh_debug_destroy(_reason) {
    if (RH_DEBUG) {
        show_debug_message("[RH][DESTROY] " + object_get_name(object_index)
                           + " id=" + string(id) + " | motivo: " + string(_reason));
    }
}

/// Distância do centro do coração até um segmento (usada pelo raio do canhão).
function rh_dist_to_segment(_px, _py, _x1, _y1, _x2, _y2) {
    var _dx = _x2 - _x1;
    var _dy = _y2 - _y1;
    var _len2 = _dx * _dx + _dy * _dy;
    if (_len2 <= 0) return point_distance(_px, _py, _x1, _y1);
    var _u = ((_px - _x1) * _dx + (_py - _y1) * _dy) / _len2;
    _u = clamp(_u, 0, 1);
    return point_distance(_px, _py, _x1 + _dx * _u, _y1 + _dy * _u);
}

/// Gira _cur em direção a _target no máximo _max graus (curva limitada da mordida).
function rh_approach_angle(_cur, _target, _max) {
    var _dif = angle_difference(_target, _cur);
    return _cur + clamp(_dif, -_max, _max);
}

/// Desenha um sprite com o PIVÔ em (_px,_py), em vez da origem do arquivo.
/// Necessário para o martelo: a haste nasce no canto inferior esquerdo do arquivo.
function rh_draw_sprite_pivot(_spr, _px, _py, _pivot_x, _pivot_y, _angle, _xs, _ys, _col, _alpha) {
    var _vx = _pivot_x * _xs;
    var _vy = _pivot_y * _ys;
    var _len = point_distance(0, 0, _vx, _vy);
    var _dir = point_direction(0, 0, _vx, _vy) + _angle;
    draw_sprite_ext(_spr, 0,
                    _px - lengthdir_x(_len, _dir),
                    _py - lengthdir_y(_len, _dir),
                    _xs, _ys, _angle, _col, _alpha);
}

/// rh_box_inner()
/// Retângulo INTERNO da Battle Box (onde o coração se move), em pixels da room.
/// Devolve { x1, y1, x2, y2 }.
function rh_box_inner() {
    if (!instance_exists(obj_rh_battle_box)) {
        return { x1: 106, y1: 65, x2: 204, y2: 143 };
    }
    var _b = obj_rh_battle_box;
    return {
        x1: _b.x + BOX_BORDER_PIXELS,
        y1: _b.y + BOX_BORDER_PIXELS,
        x2: _b.x + sprite_get_width(_b.sprite_index)  - BOX_BORDER_PIXELS,
        y2: _b.y + sprite_get_height(_b.sprite_index) - BOX_BORDER_PIXELS
    };
}

/// rh_heart_x() / rh_heart_y()
/// Posição do coração (ou o centro da caixa se ele ainda não existe).
function rh_heart_x() {
    if (instance_exists(obj_rh_battle_player)) return obj_rh_battle_player.x;
    var _r = rh_box_inner();
    return (_r.x1 + _r.x2) / 2;
}
function rh_heart_y() {
    if (instance_exists(obj_rh_battle_player)) return obj_rh_battle_player.y;
    var _r = rh_box_inner();
    return (_r.y1 + _r.y2) / 2;
}

/// rh_spawn_attack(objeto, x, y)
/// Cria um ataque na layer "Bullets" (depth RH_BULLET_DEPTH na rm_rh_battle;
/// se ela não existir, cria em depth 200 e sobe para RH_BULLET_DEPTH).
/// Devolve a instância.
/// Ajuste as variáveis do ataque DEPOIS de criar (ex.: _a.vy = 2).
function rh_spawn_attack(_obj, _x, _y) {
    rh_debug_spawn(_obj, _x, _y);
    // Causa raiz histórica dos "turnos vazios": projétil nascia fora da room e
    // o Other/Outside Room do pai destruía a instância antes de ela atravessar a caixa.
    if (_x < 0 || _y < 0 || _x > room_width || _y > room_height) {
        rh_debug("AVISO: spawn FORA DA ROOM @ " + string(round(_x)) + "," + string(round(_y))
                 + " -> obj_rh_battle_bullet/Other vai destruir imediatamente");
    }
    var _inst;
    if (layer_exists("Bullets")) _inst = instance_create_layer(_x, _y, "Bullets", _obj);
    else                         _inst = instance_create_depth(_x, _y, 200, _obj);

    // Na rm_rh_battle a layer "Bullets" já está em RH_BULLET_DEPTH (1), à frente
    // da caixa (10). Se a room não tiver a layer, o fallback cria em 200 e aqui
    // o tiro sobe. Quem define depth próprio no Create (martelo/bota = -5) fica.
    if (_inst.depth == 200) _inst.depth = RH_BULLET_DEPTH;
    return _inst;
}

/// rh_draw_clipped(sprite, quadro, x, y, xscale, yscale, cor, alpha)
/// Desenha o sprite SÓ dentro da Battle Box: o ataque "entra" pela borda da caixa
/// em vez de aparecer solto na tela. (Origem do sprite = canto superior esquerdo.)
function rh_draw_clipped(_spr, _img, _x, _y, _xs, _ys, _col, _alpha) {
    var _r  = rh_box_inner();
    _x = round(_x);
    _y = round(_y);
    var _w  = sprite_get_width(_spr);
    var _h  = sprite_get_height(_spr);
    var _dx1 = max(_x, _r.x1);
    var _dy1 = max(_y, _r.y1);
    var _dx2 = min(_x + _w * _xs, _r.x2);
    var _dy2 = min(_y + _h * _ys, _r.y2);
    if (_dx2 <= _dx1 || _dy2 <= _dy1) return;
    draw_sprite_part_ext(_spr, _img,
                         (_dx1 - _x) / _xs, (_dy1 - _y) / _ys,
                         (_dx2 - _dx1) / _xs, (_dy2 - _dy1) / _ys,
                         _dx1, _dy1, _xs, _ys, _col, _alpha);
}

/// rh_draw_warning(x1, y1, x2, y2, tempo)
/// Retângulo vermelho piscando: o AVISO de onde o golpe vai cair (justiça: o jogador
/// precisa ver antes). "tempo" = frames desde o início do aviso.
function rh_draw_warning(_x1, _y1, _x2, _y2, _t) {
    var _a = 0.22;
    if (((_t div 4) mod 2) == 0) _a = 0.45;
    draw_set_alpha(_a);
    draw_set_color(c_red);
    draw_rectangle(_x1, _y1, _x2, _y2, false);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

/// rh_draw_warning_rect(x1, y1, x2, y2, tempo)
/// Faixa vermelha piscando (mesma linguagem visual de rh_draw_warning), usada
/// pelas raias/colunas do Itagibe. "tempo" = frames desde o início do aviso.
function rh_draw_warning_rect(_x1, _y1, _x2, _y2, _t) {
    var _a = 0.18;
    if (((_t div 4) mod 2) == 0) _a = 0.38;
    draw_set_alpha(_a);
    draw_set_color(c_red);
    draw_rectangle(_x1, _y1, _x2, _y2, false);
    draw_set_alpha(min(1, _a + 0.22));
    draw_rectangle(_x1, _y1, _x2, _y2, true);
    draw_set_alpha(1);
    draw_set_color(c_white);
}

/// rh_draw_warning_line(x1, y1, x2, y2, largura, tempo)
/// Linha vermelha piscando (mesma linguagem de rh_draw_warning), com espessura configurável.
/// Compatibilidade: chamada antiga com 5 argumentos (sem largura) continua valendo 2 px.
function rh_draw_warning_line(_x1, _y1, _x2, _y2, _w, _t) {
    var _width = 2;
    var _tempo = 0;
    if (argument_count >= 6) { _width = _w; _tempo = _t; }
    else                     { _tempo = _w; }
    var _a = 0.34;
    if (((_tempo div 4) mod 2) == 0) _a = 0.68;
    draw_set_alpha(_a);
    draw_set_color(c_red);
    draw_line_width(_x1, _y1, _x2, _y2, max(1, _width));
    draw_set_alpha(1);
    draw_set_color(c_white);
}

// ═══════════════════════════════════════════════════════════════════
// GEOMETRIA E DANO REAPROVEITÁVEL (ataques com desenho próprio)
// Regra: hitbox = desenho, encolhido ~15% (RH_HEART_SHRINK) a favor do jogador.
// Ataques rotacionados/feixes mantêm active = false e chamam rh_hurt_heart() eles mesmos;
// assim a colisão por máscara do coração NÃO acerta "fantasmas" fora do desenho.
// ═══════════════════════════════════════════════════════════════════

/// Retângulo do coração (6x6 nominais), já encolhido. Devolve {x1,y1,x2,y2,cx,cy,hw,hh}.
function rh_heart_rect() {
    var _p = noone;
    if (instance_exists(obj_rh_battle_player)) _p = obj_rh_battle_player;
    var _cx = 155;
    var _cy = 104;
    if (_p != noone) { _cx = _p.x; _cy = _p.y; }
    var _hx = 1;
    var _hy = 1;
    if (_p != noone) { _hx = abs(_p.image_xscale); _hy = abs(_p.image_yscale); }
    var _hw = sprite_get_width(spr_rh_battle_player)  * _hx * RH_HEART_SHRINK / 2;
    var _hh = sprite_get_height(spr_rh_battle_player) * _hy * RH_HEART_SHRINK / 2;
    return { x1: _cx - _hw, y1: _cy - _hh, x2: _cx + _hw, y2: _cy + _hh,
             cx: _cx, cy: _cy, hw: _hw, hh: _hh };
}

/// Retângulo alinhado aos eixos contra o coração.
function rh_rect_hits_heart(_x1, _y1, _x2, _y2) {
    var _h = rh_heart_rect();
    return (_h.x2 >= _x1 && _h.x1 <= _x2 && _h.y2 >= _y1 && _h.y1 <= _y2);
}

/// Retângulo ROTACIONADO (centro _cx,_cy; largura/altura _w,_h; ângulo em graus) contra o coração.
/// Transforma o centro do coração para o espaço local do retângulo e mede a distância até a caixa
/// local encolhida; o coração é tratado como círculo inscrito (levemente mais justo para o jogador).
function rh_rot_rect_hits_heart(_cx, _cy, _w, _h, _angle) {
    var _hr = rh_heart_rect();
    var _dx = _hr.cx - _cx;
    var _dy = _hr.cy - _cy;
    var _a  = degtorad(-_angle);
    var _c  = cos(_a);
    var _s  = sin(_a);
    var _lx = _dx * _c - _dy * _s;
    var _ly = _dx * _s + _dy * _c;
    var _hw = abs(_w) * RH_HEART_SHRINK / 2;
    var _hh = abs(_h) * RH_HEART_SHRINK / 2;
    var _qx = clamp(_lx, -_hw, _hw);
    var _qy = clamp(_ly, -_hh, _hh);
    var _rad = min(_hr.hw, _hr.hh);
    return (point_distance(_lx, _ly, _qx, _qy) <= _rad);
}

/// Segmento com meia-largura _half_w contra o coração (raios, cortes, fios de aviso).
function rh_segment_hits_heart(_x1, _y1, _x2, _y2, _half_w) {
    var _hr = rh_heart_rect();
    var _rad = min(_hr.hw, _hr.hh);
    return (rh_dist_to_segment(_hr.cx, _hr.cy, _x1, _y1, _x2, _y2) <= abs(_half_w) + _rad);
}

/// Aplica dano de UM ataque ao coração. Usado pelo Step do coração e por geometria própria.
/// Respeita was_hit (single-hit), destroy_on_hit, dmg_mult, iframes e estado da batalha.
/// Devolve true se houve acerto.
function rh_hurt_heart(_b) {
    if (_b == noone || !instance_exists(_b)) return false;
    if (!instance_exists(obj_rh_battle_controller) || !instance_exists(obj_rh_battle_player)) return false;
    if (obj_rh_battle_controller.state != BATTLE_STATE.ENEMY_TURN) return false;
    if (!instance_exists(obj_rh_battle_box) || !obj_rh_battle_box.is_open) return false;

    var _p = obj_rh_battle_player;
    if (_p.iframe_timer > 0 || _b.was_hit) return false;

    var _dmg = max(1, round(calculate_enemy_damage() * _b.dmg_mult));
    apply_damage_to_player(_dmg);
    _p.iframe_timer = _p.iframe_max;   // antes: 60 frames; FICA aqui, uma fonte só
    obj_rh_battle_controller.talai_hit_timer = ANIM_TALAI_HIT_DURATION;

    var _kb_power = _b.kb_power;
    var _kb_dir   = _b.kb_dir;
    rh_debug("ACERTO por " + object_get_name(_b.object_index)
             + " | dano " + string(_dmg) + " | iframes " + string(_p.iframe_max));

    with (_b) {
        active  = false;
        was_hit = true;
        if (destroy_on_hit) {
            rh_debug_destroy("acerto no coração");
            instance_destroy();
        }
    }
    if (_kb_power > 0 && instance_exists(_p)) {
        _p.kb_x     = lengthdir_x(_kb_power, _kb_dir);
        _p.kb_y     = lengthdir_y(_kb_power, _kb_dir);
        _p.kb_time  = 12;
        _p.kb_flash = 10;
    }
    return true;
}

// ═══════════════════════════════════════════════════════════════════
// DESENHO ROTACIONADO RECORTADO NA CAIXA
// Escolha: SURFACE do tamanho da Battle Box (99x79), não scissor. O scissor do
// GameMaker é global e não combina com draw_sprite_ext girado/escalado; a surface
// recorta por alpha e funciona com a câmera 320x240 do jogo. Se a surface for
// perdida (troca de foco / resize), ela é recriada aqui mesmo antes do uso.
// ═══════════════════════════════════════════════════════════════════

/// Devolve a surface de recorte, criando/recriando se ela não existir ou mudar de tamanho.
function rh_clip_surface_get(_w, _h) {
    if (!variable_global_exists("rh_clip_surf")) {
        global.rh_clip_surf    = noone;
        global.rh_clip_surf_w  = 0;
        global.rh_clip_surf_h  = 0;
    }
    if (!surface_exists(global.rh_clip_surf)
        || global.rh_clip_surf_w != _w || global.rh_clip_surf_h != _h) {
        if (surface_exists(global.rh_clip_surf)) surface_free(global.rh_clip_surf);
        global.rh_clip_surf   = surface_create(_w, _h);
        global.rh_clip_surf_w = _w;
        global.rh_clip_surf_h = _h;
    }
    return global.rh_clip_surf;
}

/// Desenha um sprite JÁ POSICIONADO (origem do arquivo em _dx,_dy da room) girado, só dentro da caixa.
function rh_draw_clipped_at(_spr, _img, _dx, _dy, _xs, _ys, _angle, _col, _alpha) {
    if (_spr == noone || _alpha <= 0) return;
    var _r = rh_box_inner();
    var _w = _r.x2 - _r.x1 + 1;
    var _h = _r.y2 - _r.y1 + 1;
    var _s = rh_clip_surface_get(_w, _h);
    surface_set_target(_s);
    draw_clear_alpha(c_black, 0);
    draw_sprite_ext(_spr, _img, round(_dx - _r.x1), round(_dy - _r.y1), _xs, _ys, _angle, _col, _alpha);
    surface_reset_target();
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_surface(_s, _r.x1, _r.y1);
}

/// rh_draw_clipped_ext(spr, img, x, y, xscale, yscale, angle, cor, alpha)
/// Desenha girado/escalado recortado na caixa. (x,y) é a posição da ORIGEM do sprite na room;
/// a rotação é em torno do CENTRO GEOMÉTRICO do sprite, qualquer que seja a origem do arquivo.
function rh_draw_clipped_ext(_spr, _img, _x, _y, _xs, _ys, _angle, _col, _alpha) {
    var _ox = sprite_get_xoffset(_spr);
    var _oy = sprite_get_yoffset(_spr);
    var _vx = (sprite_get_width(_spr)  / 2 - _ox) * _xs;
    var _vy = (sprite_get_height(_spr) / 2 - _oy) * _ys;
    var _a  = degtorad(_angle);
    var _dx = _x - (_vx * cos(_a) - _vy * sin(_a));
    var _dy = _y - (_vx * sin(_a) + _vy * cos(_a));
    rh_draw_clipped_at(_spr, _img, _dx, _dy, _xs, _ys, _angle, _col, _alpha);
}

/// Versão com PIVÔ: (_px,_py) é o ponto da room que deve ficar fixo; (_pivot_x,_pivot_y)
/// é o ponto no ARQUIVO do sprite (ex.: a ponta da haste do martelo). Necessário porque o
/// sprite do martelo tem a haste saindo do canto inferior esquerdo.
function rh_draw_clipped_pivot(_spr, _img, _px, _py, _pivot_x, _pivot_y, _angle, _xs, _ys, _col, _alpha) {
    var _vx = (_pivot_x - sprite_get_xoffset(_spr)) * _xs;
    var _vy = (_pivot_y - sprite_get_yoffset(_spr)) * _ys;
    var _a  = degtorad(_angle);
    var _dx = _px - (_vx * cos(_a) - _vy * sin(_a));
    var _dy = _py - (_vx * sin(_a) + _vy * cos(_a));
    rh_draw_clipped_at(_spr, _img, _dx, _dy, _xs, _ys, _angle, _col, _alpha);
}
