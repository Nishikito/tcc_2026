timer++;

// Fases 0 e 1: player e inimigo parados e NA FRENTE do escurecimento
if (phase <= 1) {
    if (player_id != noone && instance_exists(player_id)) {
        player_id.image_speed = 0;
        player_id.depth       = -50010;
    }
    if (instance_exists(enemy)) {
        enemy.image_speed = 0;
        enemy.depth       = -50010;
    }
}

switch (phase) {

    case 0: // "!" sobre o player
        if (timer == 1) audio_play_sound(sfxEnemyEncounter, 0, false);
        if (timer >= t_alert) { phase = 1; timer = 0; }
        break;

    case 1: // fundo escurece, coração pisca
        if (timer >= t_dark) {
            phase = 2; timer = 0;
            audio_play_sound(sfxBattleStart, 0, false);
            // esconde os reais; a Draw GUI desenha as cópias deslizando
            if (player_id != noone && instance_exists(player_id)) player_id.visible = false;
            if (instance_exists(enemy)) enemy.visible = false;
        }
        break;

    case 2: // formação de batalha
        if (timer >= t_slide) { phase = 3; timer = 0; }
        break;

    case 3: // pausa em preto → batalha
        if (timer >= t_hold) {
            global.pre_battle_room = room;
            global.pre_battle_hp   = global.hp;
            if (instance_exists(ObjPlayer)) {
                global.pre_battle_x = ObjPlayer.x;
                global.pre_battle_y = ObjPlayer.y;
            }
            global.current_enemy_id    = enemy_id_value;
            var _edata = get_rh_enemy_data(enemy_id_value);
            global.battle_enemy_hp     = _edata.max_hp;
            global.battle_enemy_max_hp = _edata.max_hp;

            with (ObjPlayer) instance_destroy();
            room_goto(rm_rh_battle);
            instance_destroy();
        }
        break;
}