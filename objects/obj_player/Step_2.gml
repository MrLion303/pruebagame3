/// =========================================================
/// OBJ_PLAYER
/// END STEP
/// =========================================================
///
/// Aplicar los sprites del plataformero DESPUÉS del Step RPG.
///
/// Así el Step RPG puede conservarse intacto.
/// =========================================================

if (
    variable_global_exists(
        "platformer_active"
    )
    &&
    global.platformer_active
)
{
    scr_platformer_player_apply_sprite();
}
