/// =========================================================
/// OBJ_BATALLA_CONTROLLER
/// DESTROY
/// =========================================================

// Restaurar siempre la ganancia del asset musical base.
// Evita que una canción quede permanentemente con volumen reducido.
if (
    variable_instance_exists(id, "musica_batalla_asset_base")
    &&
    musica_batalla_asset_base != noone
    &&
    audio_exists(musica_batalla_asset_base)
)
{
    audio_sound_gain(
        musica_batalla_asset_base,
        1.0,
        0
    );
}

// Si una cinemática cambió la música y la referencia actual
// es una instancia todavía activa, también la restauramos.
if (
    variable_instance_exists(id, "musica_batalla_actual")
    &&
    musica_batalla_actual != noone
    &&
    audio_is_playing(musica_batalla_actual)
)
{
    audio_sound_gain(
        musica_batalla_actual,
        1.0,
        0
    );
}
