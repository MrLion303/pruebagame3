/// =========================================================
/// OBJ_ENEMIGO_BATALLA_MAPA_PARENT
/// END STEP - NUEVO EVENTO
/// =========================================================
///
/// Reproduce snd_tensionhorn exactamente cuando comienza el
/// segundo de congelación tras tocar a Maya y antes de BBS.
///
/// Se busca por nombre para que el proyecto no falle al
/// compilar si el recurso todavía no fue importado.
/// =========================================================

if (
    !variable_instance_exists(
        id,
        "_tension_pause_prev"
    )
)
{
    _tension_pause_prev =
        false;
}


var _pause_now =
    (
        variable_instance_exists(
            id,
            "pausa_contacto_activa"
        )
        &&
        pausa_contacto_activa
    );


if (
    _pause_now
    &&
    !_tension_pause_prev
)
{
    var _snd_tension =
        asset_get_index(
            "snd_tensionhorn"
        );


    if (
        _snd_tension != -1
        &&
        audio_exists(
            _snd_tension
        )
    )
    {
        if (
            audio_is_playing(
                _snd_tension
            )
        )
        {
            audio_stop_sound(
                _snd_tension
            );
        }


        audio_play_sound(
            _snd_tension,
            15,
            false
        );
    }
}


_tension_pause_prev =
    _pause_now;
