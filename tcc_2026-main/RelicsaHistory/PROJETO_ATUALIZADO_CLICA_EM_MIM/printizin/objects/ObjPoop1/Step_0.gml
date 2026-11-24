if(place_meeting(x,y,ObjPlayer))
{
    if(!ralseiSound)
    {
        audio_play_sound(sfxRalseiSplat,0,false);
        ralseiSound = true; 
    }
}
else
{
    ralseiSound = false;
}