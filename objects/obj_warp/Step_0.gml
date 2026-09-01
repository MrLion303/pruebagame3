/// =========================================================
/// OBJ_WARP
/// STEP COMPLETO
/// =========================================================
//
// obj_player además comprueba instance_exists(obj_pauser),
// y obj_warp hereda de ese objeto. Por eso el jugador sigue
// bloqueado durante toda la transición.
//
// Solo devolvemos el movimiento cuando la animación de
// apertura ya llegó realmente al principio.
// =========================================================

if (
    warp_room_changed
    &&
    image_speed < 0
    &&
    image_index <= 0.05
)
{
    warp_finish();
    exit;
}
