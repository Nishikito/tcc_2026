// ══════════════════════════════════════════════════════════════════
// VISUAL NOVEL + FORMA DO TALAI
// ──────────────────────────────────────────────────────────────────
// 1) Sprites grandes de visual novel nas falas (Talai e o companion Rasiel).
//    Uso em qualquer scr_dialogo_*:   scr_text("Que lugar é esse?", "talai-preocupado");
//                                     scr_text("Calma, eu explico.",  "rasiel-sorrindo");
//    Falantes do Talai:  "talai" | "talai-falando" | "talai-sorrindo" | "talai-pensando"
//                        "talai-preocupado" | "talai-bravo" | "talai-surpreso"
//    Falantes do Rasiel: "rasiel" | "rasiel-falando" | "rasiel-sorrindo" | "rasiel-preocupado"
//                        "rasiel-bravo" | "rasiel-triste" | "rasiel-desacreditado"
//    ("companion" e "charles" também valem e são o mesmo que "rasiel".)
//    O Talai usa os sprites talaiB (explorador) em rm_inicio e nas salas do mundo
//    da história; nas salas da escola (inclusive o corredor e o refeitório) usa os normais.
//
// 2) Forma do Talai no mapa: em rm_inicio ele passa a usar os spr_talaiB_B/C/D/E da
//    pasta player (frente/costas/direita/esquerda); nas salas da escola, SprPlayer.
//    A mesma lista comanda os retratos grandes das falas.
// ══════════════════════════════════════════════════════════════════

/// Salas do MUNDO DA HISTÓRIA: rm_inicio e as que vêm depois dela na história.
/// A sala antiga onde o Talai acorda não existe mais no projeto:
/// foi substituída por rm_inicio, que já está nesta lista.
/// A cutscene da sala dos professores termina em rm_inicio — é lá que o Talai
/// troca para o talaiB. As salas da escola (pátio, corredor, refeitório,
/// biblioteca e banheiros) NÃO entram aqui: nelas ele continua com SprPlayer.
/// Sala nova do mundo da história? Acrescente aqui.
function room_is_story_world(_room = room) {
    switch (_room) {
        case rm_inicio:
        case rm_aldeia_indigena:
        case rm_caminho_para_oca:
        case rm_conecta_caminho_praia:
        case rm_corredor_pra_praia:
            return true;
    }
    return false;
}

/// Salas da pasta Rooms/overworld (NewSchool + inCreation). Usado pela música
/// SndCastleFunk: toca nessas salas, entre a abertura em RoomClass1_1 e a
/// cutscene da sala dos professores. RoomTeachers_1 também é desta pasta,
/// mas a música é desligada antes da cutscene do livro (ver obj_settings).
function room_is_overworld(_room = room) {
    switch (_room) {
        case RoomClass1_1:
        case RoomSalasCorredor:
        case RoomRefeitorio:
        case RoomPatio:
        case RoomBathroom_1:
        case RoomBathroom1_1:
        case RoomLivro:
        case RoomTeachers_1:
            return true;
    }
    return false;
}

/// Sprite de visual novel do Talai para a emoção pedida (versão talaiB no mundo da história)
function talai_vn_sprite(_emo) {
    var _b = room_is_story_world();
    switch (_emo) {
        case "sorrindo":   return _b ? spr_talaiB_sorrindo_visualNovel     : spr_talai_sorrindo_visual_novel;
        case "pensando":   return _b ? spr_talaiB_pensando_visual_novel    : spr_talai_pensando_visual_novel;
        case "preocupado": return _b ? spr_talaiB_preocupado_visual_novel  : spr_talai_preocupado_visual_novel;
        case "bravo":      return _b ? spr_talaiB_bravo_visual_novel       : spr_talai_bravo_visual_novel;
        case "surpreso":   return _b ? spr_talaiB_surpreso_visual_novel    : spr_talai_surpreso_visual_novel;
        default:           return _b ? spr_talaiB_falando_visual_novel     : spr_talai_falando_visual_novel;   // "falando" e qualquer outro
    }
}

/// Sprite de visual novel do Rasiel (companion) para a emoção pedida
function rasiel_vn_sprite(_emo) {
    switch (_emo) {
        case "sorrindo":      return spr_rasiel_sorrindo_visual_novel;
        case "preocupado":    return spr_rasiel_preocupado_visual_novel;
        case "bravo":         return spr_rasiel_bravo_visual_novel;
        case "triste":        return spr_rasiel_triste_visual_novel;
        case "desacreditado": return spr_rasiel_desacreditado_visual_novel;
        // "explicando" ainda não existe como asset: usa o de falando até o artista importar.
        case "explicando":
            var _explicando = asset_get_index("spr_rasiel_explicando_visual_novel");
            return (_explicando == -1) ? spr_rasiel_falando_visual_novel : _explicando;
        default:              return spr_rasiel_falando_visual_novel;
    }
}

/// Força o retrato talaiB (forma explorador) explicitamente.
/// Usado por scr_text com as chaves "talaiB-<emoção>", independente da sala.
function talaiB_vn_sprite(_emo) {
    switch (_emo) {
        case "sorrindo":   return spr_talaiB_sorrindo_visualNovel;
        case "pensando":   return spr_talaiB_pensando_visual_novel;
        case "preocupado": return spr_talaiB_preocupado_visual_novel;
        case "bravo":      return spr_talaiB_bravo_visual_novel;
        case "surpreso":   return spr_talaiB_surpreso_visual_novel;
        default:           return spr_talaiB_falando_visual_novel;
    }
}

/// Aplica a FORMA do Talai conforme a sala: mundo da história = talaiB, escola = normal.
/// Chamada pelo ObjPlayer ao nascer e a cada início de sala.
function talai_apply_form() {
    if (!instance_exists(ObjPlayer)) return;
    var _b = room_is_story_world();
    with (ObjPlayer) {
        if (_b) {
            // Mesmo padrão do companion (B=frente, C=costas, D=direita, E=esquerda),
            // agora com as 4 direções animadas da pasta Sprites/player/talaiB.
            // Os sprites de batalha (battle/attack/damage) ficam só nas batalhas.
            sprite[DOWN]  = spr_talaiB_B;
            sprite[UP]    = spr_talaiB_C;
            sprite[RIGHT] = spr_talaiB_D;
            sprite[LEFT]  = spr_talaiB_E;
        } else {
            sprite[DOWN] = SprPlayer;  sprite[UP] = SprPlayerUp;  sprite[LEFT] = SprPlayerLeft;  sprite[RIGHT] = SprPlayerRight;
        }
        mask_index   = sprite[DOWN];
        sprite_index = sprite[face];
    }
}
