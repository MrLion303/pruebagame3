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


    // =====================================================
    // POGO = MISMA FÍSICA VERTICAL QUE UN SALTO NORMAL
    // =====================================================
    //
    // El pogo ya usa la gravedad normal del plataformero.
    // Lo que hacía que se sintiera mucho más "flotante" era
    // que su impulso era -18.0 mientras el salto normal usa
    // platform_jump_speed (-10.5 actualmente).
    //
    // Desde ahora el rebote del pogo toma SIEMPRE el mismo
    // impulso vertical del salto normal. Si en el futuro
    // cambias platform_jump_speed, el pogo se actualizará
    // automáticamente también.
    // =====================================================

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
