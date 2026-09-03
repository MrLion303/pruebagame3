

// =========================================================
// OBJ_SAVE_MENU
// ROOM START
// =========================================================


// Solo nos interesa si este objeto sobrevivió
// porque está cargando una partida.
if (
    transicion_activa
    &&
    transicion_fase == 2
)
{
    // =====================================================
    // YA NO MOSTRAR EL MENÚ DE GUARDADO
    // =====================================================

    mostrar_interfaz = false;


    // =====================================================
    // POSICIONAR AL JUGADOR
    // =====================================================

    if (!instance_exists(obj_player))
    {
        instance_create_layer(
            transicion_x,
            transicion_y,
            "Player",
            obj_player
        );
    }
    else
    {
        obj_player.x =
            transicion_x;

        obj_player.y =
            transicion_y;
    }


    // Mantenerlo bloqueado mientras desaparece
    // la transición.
    if (instance_exists(obj_player))
    {
        if (
            variable_instance_exists(
                obj_player,
                "puede_moverse"
            )
        )
        {
            obj_player.puede_moverse = false;
        }

        if (
            variable_instance_exists(
                obj_player,
                "can_move"
            )
        )
        {
            obj_player.can_move = false;
        }
    }


    // =====================================================
    // COMENZAR FADE OUT
    // =====================================================

    transicion_progreso = 1;

    transicion_fase = 3;
}
