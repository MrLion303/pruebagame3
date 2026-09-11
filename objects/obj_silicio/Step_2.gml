/// =========================================================
/// OBJ_SILICIO
/// END STEP
/// =========================================================
///
/// V4:
///
/// Silicio ya NO usa física independiente en plataformero.
///
/// Aquí únicamente aseguramos que siga unido al party.
/// Su posición final la calcula scr_party_update() y después
/// obj_settings aplica sus sprites de plataforma.
/// =========================================================

scr_platformer_init();


if (global.platformer_active)
{
    scr_platformer_silicio_update();
}
else
{
    if (
        variable_instance_exists(
            id,
            "platformer_silicio_applied"
        )
        &&
        platformer_silicio_applied
    )
    {
        scr_platformer_silicio_leave();
    }
}
