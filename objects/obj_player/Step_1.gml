/// =========================================================
/// OBJ_PLAYER
/// BEGIN STEP
/// =========================================================
///
/// MODO PLATAFORMERO V2
///
/// El cambio de sprite/física se aplica solo cuando Maya ya
/// está dentro de la room destino.
/// =========================================================

scr_platformer_init();


// Aplicar entrada/salida pendiente DESPUÉS del room_goto.
scr_platformer_apply_pending_mode();


if (global.platformer_active)
{
    if (
        !variable_instance_exists(
            id,
            "platformer_mode_applied"
        )
        ||
        !platformer_mode_applied
    )
    {
        scr_platformer_player_enter();
    }


    scr_platformer_player_update();
}
else
{
    if (
        variable_instance_exists(
            id,
            "platformer_mode_applied"
        )
        &&
        platformer_mode_applied
    )
    {
        scr_platformer_player_leave();
    }
}
