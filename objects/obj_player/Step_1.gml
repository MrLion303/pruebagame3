/// =========================================================
/// OBJ_PLAYER
/// BEGIN STEP COMPLETO
/// =========================================================
/// Modo plataformero actual + habilidades de mundo.
/// =========================================================

// Registra posición previa, activa Sigilo y ajusta rangos
// antes de los Step normales de los enemigos.
scr_player_abilities_begin_step(id);


scr_platformer_init();


// Aplicar entrada/salida pendiente DESPUÉS del room_goto.
scr_platformer_apply_pending_mode();


if (global.platformer_active)
{
    if (
        !variable_instance_exists(id, "platformer_mode_applied")
        ||
        !platformer_mode_applied
    )
    {
        scr_platformer_player_enter();
    }


    // Pogo = misma física vertical que un salto normal.
    if (
        variable_instance_exists(id, "platform_jump_speed")
        &&
        variable_instance_exists(id, "platform_pogo_bounce_speed")
    )
    {
        platform_pogo_bounce_speed =
            platform_jump_speed;
    }


    scr_platformer_player_update();
}
else
{
    if (
        variable_instance_exists(id, "platformer_mode_applied")
        &&
        platformer_mode_applied
    )
    {
        scr_platformer_player_leave();
    }
}
