/// =========================================================
/// SCR_ENEMIGOS_BATALLA_MAPA_DATA
/// =========================================================
///
/// DATOS DE LOS ENEMIGOS DEL MAPA QUE INICIAN BBS.
///
/// REGLAS QUE NO SE PERSONALIZAN:
///
///     - sprite normal:
///         viene del objeto.
///
///     - al tocar a Maya:
///         TODOS paralizan el mundo 1 segundo.
///
///     - persecución:
///         TODOS esperan quietos 0.5 segundos al detectar.
///
///     - perseguidor después de BBS:
///         desaparece al regresar de la batalla y reaparece
///         únicamente después de salir y volver a entrar a
///         la habitación.
///
/// =========================================================
/// MODOS
/// =========================================================
///
/// "contacto"
///     No persigue.
///     Hace su preset y batalla al tocar.
///
/// "persecucion"
///     Hace su preset.
///     Entra Maya en rango -> alerta -> espera -> persigue.
///     Al tocar -> pausa universal -> BBS.
///
/// =========================================================
/// MOVIMIENTO
/// =========================================================
///
/// El origen es DONDE COLOCAS LA INSTANCIA EN LA ROOM.
///
/// PRESETS:
///
///     "ninguno"
///     "izquierda_derecha"
///     "arriba_abajo"
///     "diagonal"
///     "circulo"
///     "continuo"
///
/// Los presets de ida/vuelta usan smootherstep para frenar,
/// cambiar de dirección y volver a acelerar suavemente.
///
/// =========================================================


function scr_enemigos_batalla_mapa_data(_id)
{
    switch (_id)
    {
        // =================================================
        // CAMINANTE 01
        // =================================================

        case "caminante_01":
            return
            {
                // -----------------------------------------
                // BBS
                // -----------------------------------------

                batalla_id:
                    "variante 1",


                // -----------------------------------------
                // ACTIVACIÓN
                // -----------------------------------------

                modo_activacion:
                    "persecucion",

                rango_persecucion:
                    120,

                radio_contacto:
                    18,


                // -----------------------------------------
                // ALERTA
                // -----------------------------------------
                //
                // El sprite normal está en el OBJETO.
                // -----------------------------------------

                sprite_alerta:
                    -1,


                // -----------------------------------------
                // PERSECUCIÓN
                // -----------------------------------------

                persecucion_velocidad:
                    4.0,


                // -----------------------------------------
                // MOVIMIENTO NORMAL
                // -----------------------------------------

                puede_moverse:
                    true,

                movimiento_preset:
                    "izquierda_derecha",

                movimiento_velocidad:
                    2.0,

                movimiento_distancia:
                    64,

                movimiento_radio:
                    64,

                movimiento_direccion:
                    "derecha",

                movimiento_angulo:
                    0,

                movimiento_sentido:
                    1,

                movimiento_diagonal_angulo:
                    45
            };


        // =================================================
        // PERSEGUIDOR TOBY
        // =================================================
        //
        // OBJETO:
        //
        //     obj_enemigo_batalla_mapa_perseguidor_toby
        //
        // NORMAL:
        //     el sprite asignado directamente al objeto.
        //
        // ALERTA:
        //     spr_volador_alarma_2
        //
        // MOVIMIENTO:
        //     izquierda <-> derecha smooth.
        //
        // =================================================

        case "perseguidor_toby":
            return
            {
                // -----------------------------------------
                // BBS
                // -----------------------------------------

                batalla_id:
                    "toby",


                // -----------------------------------------
                // ACTIVACIÓN
                // -----------------------------------------

                modo_activacion:
                    "persecucion",

                rango_persecucion:
                    160,

                radio_contacto:
                    18,


                // -----------------------------------------
                // ALERTA
                // -----------------------------------------

                sprite_alerta:
                    spr_volador_alarma_2,


                // -----------------------------------------
                // PERSECUCIÓN
                // -----------------------------------------

                persecucion_velocidad:
                    5.5,


                // -----------------------------------------
                // MOVIMIENTO NORMAL
                // -----------------------------------------

                puede_moverse:
                    true,

                movimiento_preset:
                    "izquierda_derecha",

                movimiento_velocidad:
                    3.0,

                movimiento_distancia:
                    80,

                movimiento_radio:
                    64,

                movimiento_direccion:
                    "derecha",

                movimiento_angulo:
                    0,

                movimiento_sentido:
                    1,

                movimiento_diagonal_angulo:
                    45
            };
    }


    // =====================================================
    // FALLBACK
    // =====================================================

    show_debug_message(
        "[ENEMIGO BATALLA MAPA] ID desconocido: "
        +
        string(
            _id
        )
    );


    return
    {
        batalla_id:
            "variante 1",

        modo_activacion:
            "contacto",

        rango_persecucion:
            100,

        radio_contacto:
            18,

        sprite_alerta:
            -1,

        persecucion_velocidad:
            4.0,

        puede_moverse:
            false,

        movimiento_preset:
            "ninguno",

        movimiento_velocidad:
            0,

        movimiento_distancia:
            64,

        movimiento_radio:
            64,

        movimiento_direccion:
            "derecha",

        movimiento_angulo:
            0,

        movimiento_sentido:
            1,

        movimiento_diagonal_angulo:
            45
    };
}
