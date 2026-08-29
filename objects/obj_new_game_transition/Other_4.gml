/// =========================================================
/// OBJ_NEW_GAME_TRANSITION
/// ROOM START
/// =========================================================


// Solo actuar cuando acabamos de cambiar
// hacia la habitación de Nueva Partida.
if (fase == 1)
{
    // =====================================================
    // CREAR PLAYER
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
    // COLOCAR PLAYER
    // =====================================================

    if (instance_exists(obj_player))
    {
        obj_player.x =
            destino_x;


        obj_player.y =
            destino_y;


        // Bloqueado mientras se retira
        // la pantalla negra.
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


        if (
            variable_instance_exists(
                obj_player,
                "can_move"
            )
        )
        {
            obj_player.can_move =
                false;
        }
    }


    // La pantalla sigue totalmente cubierta.
    transicion_progreso =
        1;


    // Ahora comenzar a descubrir.
    fase =
        2;
}