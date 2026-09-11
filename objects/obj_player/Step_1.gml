/// =========================================================
/// OBJ_PLAYER
/// BEGIN STEP
/// =========================================================
///
/// MODO PLATAFORMERO
///
/// NO reemplaza el Step RPG actual.
///
/// Begin Step mueve a Maya primero y deja:
//
//     puede_moverse = false
//
// para que el Step RPG normal no aplique su movimiento.
/// =========================================================

scr_platformer_init();


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
