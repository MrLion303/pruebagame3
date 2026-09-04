// =========================================================
// OBJ_GAME_OVER_TEXTO
// ROOM START
// =========================================================
//
// Solo ocurre durante DESPERTAR, porque obj_game_over_texto
// se vuelve persistente justo antes de room_goto().
// =========================================================

if (
    carga_iniciada
    &&
    estado == 3
)
{
    // =====================================================
    // CREAR / COLOCAR PLAYER
    // =====================================================

    if (!instance_exists(obj_player))
    {
        if (layer_get_id("Player") != -1)
        {
            instance_create_layer(
                carga_x,
                carga_y,
                "Player",
                obj_player
            );
        }
        else
        {
            instance_create_layer(
                carga_x,
                carga_y,
                "Instances",
                obj_player
            );
        }
    }


    if (instance_exists(obj_player))
    {
        var _p =
            instance_find(
                obj_player,
                0
            );


        _p.x =
            carga_x;

        _p.y =
            carga_y;


        // =================================================
        // APLICAR INVENTARIO, NIVEL, EQUIPO, HP Y DIRECCIÓN
        // =================================================
        //
        // Esta es la misma estructura de carga del sistema
        // de guardado: scr_cargar_juego() cargó los globals
        // y ahora se aplican al actor real.
        // =================================================

        scr_aplicar_datos_cargados(
            _p
        );


        // La room guardada YA está cargada.
        //
        // Maya debe existir y estar visible detrás del blanco
        // desde este instante, para que ambos se revelen juntos
        // durante el fade out.
        _p.visible =
            true;


        if (
            variable_instance_exists(
                _p,
                "puede_moverse"
            )
        )
        {
            _p.puede_moverse =
                false;
        }


        if (
            variable_instance_exists(
                _p,
                "can_move"
            )
        )
        {
            _p.can_move =
                false;
        }


        if (
            variable_instance_exists(
                _p,
                "movimiento"
            )
        )
        {
            _p.movimiento =
                false;
        }
    }


    // Seguimos en blanco total al entrar.
    fade_blanco =
        1;


    carga_room_lista =
        true;
}
