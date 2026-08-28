// =========================================================
// OBJ_NEW_GAME_TRANSITION
// ROOM START
// =========================================================


// Solo al llegar a la nueva room.
if (fase == 1)
{
    // =====================================================
    // CREAR JUGADOR
    // =====================================================

    if (!instance_exists(obj_player))
    {
        instance_create_layer(
            destino_x,
            destino_y,
            "Player",
            obj_player
        );
    }


    // =====================================================
    // FORZAR POSICIÓN INICIAL
    // =====================================================

    if (instance_exists(obj_player))
    {
        obj_player.x =
            destino_x;

        obj_player.y =
            destino_y;


        // Bloquearlo mientras desaparece el fade.
        if (
            variable_instance_exists(
                obj_player,
                "puede_moverse"
            )
        )
        {
            obj_player.puede_moverse =
                false;
        }
    }


    progreso = 1;
}