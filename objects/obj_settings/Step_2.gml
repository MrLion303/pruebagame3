if (
    variable_global_exists("gameover_death_freeze_active")
    &&
    global.gameover_death_freeze_active
)
{
    exit;
}


/// =========================================================
/// OBJ_SETTINGS
/// END STEP
/// =========================================================
//
// 1. Actualizar la party después de que Maya ya se movió.
// 2. Ordenar depths DESPUÉS de que también Silicio se movió.
//
// Así todos los personajes se ordenan usando su posición
// FINAL del frame.
// =========================================================

scr_party_update();

scr_depth_sort_update();
