// Se a Carol já sumiu do jogo, destrói a instância
if (global.carol_disappeared == true) {
    instance_destroy();
    exit;
}

// Atualiza a cutscene da Carol
carol_step_cutscene();

// Mantém o sprite correto enquanto parada
if (npc_state == "idle") {
    sprite_index = sprite[npc_face];
}