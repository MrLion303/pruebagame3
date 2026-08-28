// =========================================================
// OBJ_SAVE_MENU
// DESTROY
// =========================================================


// Si todavía estamos en mitad de una transición,
// no devolver movimiento prematuramente.

if (!transicion_activa)
{
    if (instance_exists(obj_player))
    {
        if (
            variable_instance_exists(
                obj_player,
                "puede_moverse"
            )
        )
        {
            obj_player.puede_moverse = true;
        }

        if (
            variable_instance_exists(
                obj_player,
                "can_move"
            )
        )
        {
            obj_player.can_move = true;
        }
    }
}