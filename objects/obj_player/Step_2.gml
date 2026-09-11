/// =========================================================
/// OBJ_PLAYER
/// END STEP COMPLETO
/// =========================================================
/// 1) Sigilo / dash / stamina.
/// 2) El plataformero conserva la última palabra en su sprite.
/// =========================================================

scr_player_abilities_end_step(id);


if (
    variable_global_exists("platformer_active")
    &&
    global.platformer_active
)
{
    scr_platformer_player_apply_sprite();
}
