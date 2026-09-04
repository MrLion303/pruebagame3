/// =========================================================
/// OBJ_MUSIC_TRIGGER
/// STEP
/// =========================================================


// =========================================================
// BLOQUEO DURANTE CINEMÁTICAS
// =========================================================

if (scr_cutscene_world_locked())
{
    exit;
}


// =========================================================
// LÓGICA NORMAL
// =========================================================

if (
    place_meeting(
        x,
        y,
        obj_player
    )
)
{
    if (
        !triggered
        &&
        my_music != -1
    )
    {
        // Detener música anterior.
        audio_stop_all();


        var _new_audio =
            audio_play_sound(
                my_music,
                1,
                true
            );


        audio_sound_gain(
            _new_audio,
            0,
            0
        );


        audio_sound_gain(
            _new_audio,
            1,
            1000
        );


        triggered =
            true;
    }
}
else
{
    triggered =
        false;
}
