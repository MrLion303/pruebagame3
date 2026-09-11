/// =========================================================
/// OBJ_PLAYER
/// END STEP COMPLETO
/// =========================================================
///
/// 1) Sistema actual de Sigilo / stamina.
/// 2) Si el Dash viejo no ocurrió, probar el Dash corregido:
///        habilidad O zapatos.
/// 3) Plataformero conserva la última palabra en el sprite.
/// =========================================================

scr_player_abilities_end_step(
    id
);


// =========================================================
// DASH CORREGIDO
// =========================================================
//
// Si el sistema viejo ya hizo Dash, dash_used_this_frame=true
// y no hacemos un segundo Dash.
//
// Si falló porque solo tienes una de las dos condiciones,
// o por el bloqueo antiguo de obj_pauser, entra este sistema.
// =========================================================

if (
    !variable_instance_exists(
        id,
        "dash_used_this_frame"
    )
    ||
    !dash_used_this_frame
)
{
    scr_player_try_dash_or_fix(
        id
    );
}


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
