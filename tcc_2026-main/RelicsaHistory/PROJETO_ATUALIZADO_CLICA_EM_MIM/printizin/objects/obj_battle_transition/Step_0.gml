timer++;
if (phase <= 1) capture_world();   // NOVA: mantém a captura sempre atualizada

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
        if (timer == 1) {
            // Corta QUALQUER música de sala (overworld ou ambiente) no encontro.
            // obj_settings escolhe de novo a trilha ao voltar da batalha.
            stop_all_ambient_music();
            global.overworld_music_on = false;
            global.ambient_music_on   = false;
            global.current_music_track = noone;
            audio_play_sound(sfxEnemyEncounter, 0, false);
        }
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
                global.pre_battle_x    = ObjPlayer.x;
                global.pre_battle_y    = ObjPlayer.y;
                global.pre_battle_face = ObjPlayer.face;
            }
            global.current_enemy_id    = enemy_id_value;
            // HP e nome vêm do PRÓPRIO objeto do inimigo: o controller lê quando a batalha começa
            global.battle_enemy_hp     = 0;
            global.battle_enemy_max_hp = 0;

            // Avisa o controller: os sprites JÁ estão em formação, não faça fade a partir do preto
            global.battle_from_transition = true;

            with (ObjPlayer) instance_destroy();
            room_goto(rm_rh_battle);
            instance_destroy();
        }
        break;
}