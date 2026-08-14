if (place_meeting(x, y, obj_player))
{
    if (!triggered && my_music != -1)
    {
        // Detenemos la música anterior de golpe
        audio_stop_all();
        
        // Reproducimos la nueva música comenzando con volumen 0
        var _new_audio = audio_play_sound(my_music, 1, true);
        audio_sound_gain(_new_audio, 0, 0); 
        
        // Hacemos el Fade In: subimos el volumen gradualmente a 1 durante 1 segundo (1000 ms)
        audio_sound_gain(_new_audio, 1, 1000); 
        
        triggered = true;
    }
}
else
{
    triggered = false;
}