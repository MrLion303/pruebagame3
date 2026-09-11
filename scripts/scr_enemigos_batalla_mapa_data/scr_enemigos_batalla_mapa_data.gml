/// =========================================================
/// SCR_ENEMIGOS_BATALLA_MAPA_DATA
/// =========================================================
///
/// CONFIGURACIÓN DE ENEMIGOS DE MAPA QUE INICIAN BBS.
///
/// Este script SOLO contiene los datos que normalmente vas a
/// personalizar al crear enemigos nuevos.
///
/// La lógica está en:
///
///     obj_enemigo_batalla_mapa_parent
///
/// =========================================================
/// MODOS DE ACTIVACIÓN
/// =========================================================
///
/// "contacto"
/// ---------------------------------------------------------
/// El enemigo recorre su patrulla y NO persigue a Maya.
///
/// Cuando Maya y el enemigo se tocan:
///
///     1. cambia a sprite_alerta;
///     2. el mundo se paraliza durante
///        alerta_contacto_segundos;
///     3. después inicia batalla.
///
/// Recomendado:
///
///     alerta_contacto_segundos: 1.0
///
///
/// "persecucion"
/// ---------------------------------------------------------
/// El enemigo recorre su patrulla.
///
/// Cuando Maya entra en rango_persecucion:
///
///     1. cambia a sprite_alerta;
///     2. se queda QUIETO durante
///        alerta_persecucion_segundos;
///     3. después persigue a Maya;
///     4. cuando la toca entra a batalla INMEDIATAMENTE.
///
/// NO vuelve a patrullar aunque Maya salga del rango.
/// Solo se reinicia al abandonar y volver a entrar a la room.
///
/// Recomendado:
///
///     alerta_persecucion_segundos: 0.5
///
/// =========================================================
/// PATRULLA
/// =========================================================
///
/// patrulla_x1 / patrulla_y1:
///     punto A.
///
/// patrulla_x2 / patrulla_y2:
///     punto B.
///
/// patrulla_velocidad:
///     píxeles por frame.
///
/// patrulla_iniciar_en_a:
///     true  = aparece en A.
///     false = aparece en B.
///
/// =========================================================
/// PERSECUCIÓN
/// =========================================================
///
/// rango_persecucion:
///     distancia en píxeles a la que detecta a Maya.
///
/// persecucion_velocidad:
///     velocidad mientras la persigue.
///
/// =========================================================
/// BATALLA
/// =========================================================
///
/// batalla_id:
///     ID que DEBE existir en scr_enemigos_data().
///
/// radio_contacto:
///     distancia entre el centro del enemigo y Maya a partir
///     de la cual se considera que se tocaron.
///
/// =========================================================
/// SPRITES
/// =========================================================
///
/// sprite_default:
///     sprite normal.
///
/// sprite_arriba / abajo / izquierda / derecha:
///     opcionales.
///     Si valen -1, se utiliza sprite_default.
///
/// sprite_alerta:
///     aparece:
///
///         CONTACTO:
///             al tocar a Maya, antes de la batalla.
///
///         PERSECUCIÓN:
///             desde que detecta a Maya y durante toda la
///             persecución.
///
/// image_speed_caminando:
///     velocidad de animación normal.
///
/// image_speed_alerta:
///     velocidad de animación del sprite de alerta.
///
/// =========================================================


function scr_enemigos_batalla_mapa_data(_id)
{
    switch (_id)
    {
        // =================================================
        // CAMINANTE 01 - EJEMPLO BASE
        // =================================================
        //
        // Sigue siendo una plantilla editable.
        // Pon sprite_alerta si quieres que visualmente cambie
        // al detectar al jugador.
        // =================================================

        case "caminante_01":
            return
            {
                // -----------------------------------------
                // BATALLA
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
                // TIEMPOS DE ALERTA
                // -----------------------------------------

                alerta_contacto_segundos:
                    1.0,

                alerta_persecucion_segundos:
                    0.5,


                // -----------------------------------------
                // PATRULLA A <-> B
                // -----------------------------------------

                patrulla_x1:
                    320,

                patrulla_y1:
                    240,

                patrulla_x2:
                    480,

                patrulla_y2:
                    240,

                patrulla_velocidad:
                    2,

                patrulla_iniciar_en_a:
                    true,


                // -----------------------------------------
                // PERSECUCIÓN
                // -----------------------------------------

                persecucion_velocidad:
                    3.5,


                // -----------------------------------------
                // SPRITES NORMALES
                // -----------------------------------------

                sprite_default:
                    -1,

                sprite_arriba:
                    -1,

                sprite_abajo:
                    -1,

                sprite_izquierda:
                    -1,

                sprite_derecha:
                    -1,


                // -----------------------------------------
                // SPRITE DE ALERTA
                // -----------------------------------------

                sprite_alerta:
                    -1,


                // -----------------------------------------
                // VELOCIDAD DE ANIMACIÓN
                // -----------------------------------------

                image_speed_caminando:
                    0.18,

                image_speed_alerta:
                    0.18
            };


        // =================================================
        // PERSEGUIDOR TOBY
        // =================================================
        //
        // NUEVO ENEMIGO SOLICITADO.
        //
        // Normal:
        //     spr_volador_idle_1
        //
        // Alerta:
        //     spr_volador_idle_2
        //
        // Batalla:
        //     "toby"
        //
        // COMPORTAMIENTO:
        //     - patrulla;
        //     - detecta a Maya;
        //     - muestra alarma;
        //     - espera 0.5 s quieto;
        //     - la persigue;
        //     - al tocarla entra inmediatamente a Toby.
        //
        // IMPORTANTE:
        // Cambia las coordenadas de patrulla de abajo según
        // la habitación donde lo vayas a colocar.
        // =================================================

        case "perseguidor_toby":
            return
            {
                // -----------------------------------------
                // BATALLA
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
                // TIEMPOS DE ALERTA
                // -----------------------------------------

                alerta_contacto_segundos:
                    1.0,

                alerta_persecucion_segundos:
                    0.5,


                // -----------------------------------------
                // PATRULLA A <-> B
                // -----------------------------------------
                //
                // AJUSTA ESTAS COORDENADAS A TU ROOM.
                // -----------------------------------------

                patrulla_x1:
                    320,

                patrulla_y1:
                    240,

                patrulla_x2:
                    480,

                patrulla_y2:
                    240,

                patrulla_velocidad:
                    2,

                patrulla_iniciar_en_a:
                    true,


                // -----------------------------------------
                // PERSECUCIÓN
                // -----------------------------------------

                persecucion_velocidad:
                    3.5,


                // -----------------------------------------
                // SPRITES NORMALES
                // -----------------------------------------
                //
                // Como este enemigo utiliza un único sprite
                // normal, los direccionales quedan en -1.
                // -----------------------------------------

                sprite_default:
                    spr_volador_idle_1,

                sprite_arriba:
                    -1,

                sprite_abajo:
                    -1,

                sprite_izquierda:
                    -1,

                sprite_derecha:
                    -1,


                // -----------------------------------------
                // SPRITE DE ALERTA
                // -----------------------------------------

                sprite_alerta:
                    spr_volador_idle_2,


                // -----------------------------------------
                // VELOCIDAD DE ANIMACIÓN
                // -----------------------------------------

                image_speed_caminando:
                    0.18,

                image_speed_alerta:
                    0.18
            };
    }


    // =====================================================
    // FALLBACK
    // =====================================================
    //
    // Evita romper el juego si escribes mal un ID.
    // =====================================================

    show_debug_message(
        "[ENEMIGO BATALLA MAPA] ID desconocido: "
        +
        string(_id)
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

        alerta_contacto_segundos:
            1.0,

        alerta_persecucion_segundos:
            0.5,

        patrulla_x1:
            0,

        patrulla_y1:
            0,

        patrulla_x2:
            0,

        patrulla_y2:
            0,

        patrulla_velocidad:
            0,

        patrulla_iniciar_en_a:
            true,

        persecucion_velocidad:
            3,

        sprite_default:
            -1,

        sprite_arriba:
            -1,

        sprite_abajo:
            -1,

        sprite_izquierda:
            -1,

        sprite_derecha:
            -1,

        sprite_alerta:
            -1,

        image_speed_caminando:
            0.18,

        image_speed_alerta:
            0.18
    };
}
