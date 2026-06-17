if(place_meeting(x,y,ObjPlayer))
{
    if (!music_playing) // Se o jogador está em contato e a música ainda não foi ativada
    {
        audio_play_sound(music, 0, true); // Toca a música em loop
        global.school_sound = true; // Define que o som da escola está ativo
        music_playing = true; // Marca que a música já foi ativada
    }
}
// Não precisamos de um "else" aqui para parar a música,
// porque a intenção é que ela continue tocando.