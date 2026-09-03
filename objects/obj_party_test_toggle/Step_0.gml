/// =========================================================
/// OBJ_PARTY_TEST_TOGGLE
/// STEP
/// =========================================================
//
// Se desbloquea EN CUANTO Maya deja de tocar la máscara.
// No hay timer.
// =========================================================

if (
    trigger_locked
    &&
    !place_meeting(
        x,
        y,
        obj_player
    )
)
{
    trigger_locked =
        false;
}
