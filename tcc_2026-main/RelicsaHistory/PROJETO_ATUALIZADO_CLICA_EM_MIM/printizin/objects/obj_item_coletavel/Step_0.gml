// ── ID ÚNICO ──────────────────────────────────────────────────────
// Se o Creation Code não definiu item_uid, usa o text_id.
// Atenção: duas ervas com o mesmo text_id e sem item_uid contam como
// o MESMO item — pegar uma faz a outra sumir. Se tiver mais de uma
// cópia no jogo, dê um item_uid diferente pra cada instância.
var _uid = item_uid;
if (_uid == "") _uid = text_id;

// ── JÁ FOI PEGO? ──────────────────────────────────────────────────
// Roda no Step e não no Create porque o Creation Code da instância
// só executa DEPOIS do Create — no Create o text_id ainda está vazio.
if (!coletado && item_ja_coletado(_uid)) {
    instance_destroy();
    exit;
}

// ── FLUTUAR ───────────────────────────────────────────────────────
float_timer += 3;
y = base_y + dsin(float_timer) * 2;

// ── ALCANCE ───────────────────────────────────────────────────────
// point_distance em vez de place_meeting: não depende de máscara e o
// jogador não precisa estar literalmente em cima do item.
no_alcance = false;
if (!coletado && !global.dialog_active && instance_exists(ObjPlayer)) {
    if (point_distance(x, y, ObjPlayer.x, ObjPlayer.y) <= raio) {
        no_alcance = true;
    }
}

// ── COLETA ────────────────────────────────────────────────────────
var _apertou = false;
if (keyboard_check_pressed(global.key_interact)) _apertou = true;
if (keyboard_check_pressed(vk_enter))            _apertou = true;

if (no_alcance && _apertou) {
    coletado = true;

    // A adição ao inventário acontece dentro de scr_dialogo_item,
    // via create_textbox → scr_game_text → scr_dialogo_item
    create_textbox(text_id);
    global.dialog_active = true;

    marcar_item_coletado(_uid);
    instance_destroy(); // some do chão após a interação
}