/// =========================================================
/// OBJ_SILICIO
/// END STEP
/// =========================================================
///
/// En modo normal:
///     scr_party_update() sigue haciendo todo.
///
/// En modo plataformero:
///     Silicio suspende temporalmente "follow the leader"
///     y usa física lateral propia.
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
