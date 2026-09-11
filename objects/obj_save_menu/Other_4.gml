/// =========================================================
/// OBJ_SAVE_MENU
/// ROOM START
/// =========================================================
///
/// Al cargar:
///
/// 1. Coloca a Maya EXACTAMENTE en x/y guardados.
/// 2. Restaura exactamente la dirección guardada.
/// 3. Fuerza inmediatamente el sprite correcto.
///
/// IMPORTANTE:
///
/// El save actual escribe `face` en la clave "facing".
///
/// Los macros reales del proyecto son:
///
///     DOWN  = 0
///     LEFT  = 1
///     RIGHT = 2
///     UP    = 3
///
/// Por eso aquí interpretamos esa clave con ESE convenio,
/// en vez de tratarla como facing_direction.
/// =========================================================


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

    mostrar_interfaz =
        false;


    // =====================================================
    // DIRECCIÓN GUARDADA
    // =====================================================

    var _saved_face =
        DOWN;


    if (
        transicion_seccion != ""
        &&
        transicion_seccion != "__NEW_GAME__"
        &&
        file_exists("save.ini")
    )
    {
        ini_open(
            "save.ini"
        );


        _saved_face =
            round(
                ini_read_real(
                    transicion_seccion,
                    "facing",
                    DOWN
                )
            );


        ini_close();
    }


    _saved_face =
        clamp(
            _saved_face,
            0,
            3
        );


    // =====================================================
    // POSICIONAR AL JUGADOR EXACTAMENTE
    // =====================================================

    var _p =
        noone;


    if (!instance_exists(obj_player))
    {
        _p =
            instance_create_layer(
                transicion_x,
                transicion_y,
                "Player",
                obj_player
            );
    }
    else
    {
        _p =
            instance_find(
                obj_player,
                0
            );


        _p.x =
            transicion_x;


        _p.y =
            transicion_y;
    }


    // También mantener sincronizado el destino global.
    global.start_x =
        transicion_x;


    global.start_y =
        transicion_y;


    global.start_room =
        room;


    // =====================================================
    // APLICAR DATOS DEL SAVE AL PLAYER PERSISTENTE
    // =====================================================
    //
    // scr_cargar_juego() ya cargó global.inventory_data y
    // global.level_data antes del room_goto.
    //
    // Ahora sí los aplicamos sobre la instancia real de Maya.
    // =====================================================

    if (
        _p != noone
        &&
        instance_exists(_p)
        &&
        transicion_seccion != "__NEW_GAME__"
    )
    {
        scr_save_runtime_apply_loaded_player(
            _p
        );
    }


    // =====================================================
    // ELIMINAR MOVIMIENTO RESIDUAL
    // =====================================================

    if (
        _p != noone
        &&
        instance_exists(_p)
    )
    {
        _p.x =
            transicion_x;


        _p.y =
            transicion_y;


        _p.hspeed =
            0;


        _p.vspeed =
            0;


        _p.speed =
            0;


        if (
            variable_instance_exists(
                _p,
                "ice_vx"
            )
        )
        {
            _p.ice_vx =
                0;
        }


        if (
            variable_instance_exists(
                _p,
                "ice_vy"
            )
        )
        {
            _p.ice_vy =
                0;
        }


        if (
            variable_instance_exists(
                _p,
                "ice_accum_x"
            )
        )
        {
            _p.ice_accum_x =
                0;
        }


        if (
            variable_instance_exists(
                _p,
                "ice_accum_y"
            )
        )
        {
            _p.ice_accum_y =
                0;
        }


        // =================================================
        // RESTAURAR DIRECCIÓN / SPRITE
        // =================================================

        switch (_saved_face)
        {
            // ---------------------------------------------
            // ABAJO
            // ---------------------------------------------
            case DOWN:

                _p.face =
                    DOWN;


                _p.facing_direction =
                    2;


                _p.direccion =
                    "abajo";


                _p.sprite_index =
                    pendejo_abajo;

                break;


            // ---------------------------------------------
            // IZQUIERDA
            // ---------------------------------------------
            case LEFT:

                _p.face =
                    LEFT;


                _p.facing_direction =
                    1;


                _p.direccion =
                    "izquierda";


                _p.sprite_index =
                    pendejo_izquierda;

                break;


            // ---------------------------------------------
            // DERECHA
            // ---------------------------------------------
            case RIGHT:

                _p.face =
                    RIGHT;


                _p.facing_direction =
                    0;


                _p.direccion =
                    "derecha";


                _p.sprite_index =
                    pendejo_derecha;

                break;


            // ---------------------------------------------
            // ARRIBA
            // ---------------------------------------------
            case UP:

                _p.face =
                    UP;


                _p.facing_direction =
                    3;


                _p.direccion =
                    "arriba";


                _p.sprite_index =
                    pendejo_arriba;

                break;
        }


        _p.image_index =
            0;


        _p.image_speed =
            0;


        // Mantenerlo bloqueado mientras desaparece
        // la transición.
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
    }


    // =====================================================
    // COMENZAR FADE OUT
    // =====================================================

    transicion_progreso =
        1;


    transicion_fase =
        3;
}
