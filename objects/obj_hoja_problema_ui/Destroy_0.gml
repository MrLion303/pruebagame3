/// =========================================================
/// OBJ_HOJA_PROBLEMA_UI - DESTROY
/// =========================================================

if (
    saved_player != noone
    &&
    instance_exists(saved_player)
)
{
    saved_player.puede_moverse =
        saved_player_can_move;


    saved_player.movimiento =
        false;
}
