/// =========================================================
/// SCR_CUTSCENE_DATA
/// =========================================================
///
/// BASE DE DATOS DE CINEMÁTICAS.
///
/// MOVIMIENTO RECOMENDADO:
///
/// cs_move_to(
///     "actor",
///     x_destino,
///     y_destino,
///     velocidad,
///     esperar
/// );
///
/// EJEMPLOS:
///
/// cs_move_to("player", 700, 194);
///
/// cs_move_to("player", 700, 194, 1); // lento
/// cs_move_to("player", 700, 194, 2); // normal/default
/// cs_move_to("player", 700, 194, 4); // rápido
///
/// El sistema detecta automáticamente hacia qué
/// dirección debe mirar el actor.
///
/// =========================================================


function scr_cutscene_data(_id)
{
    switch (_id)
    {
        // =================================================
        // PRUEBA GENERAL
        // =================================================
        //
        // Pensada para probar:
        //
        // - movimiento
        // - dirección automática
        // - diálogos
        // - sonidos
        // - esperas
        //
        // =================================================

        case "prueba_cinematica":

            return [
                // -----------------------------------------
                // CALLAR MÚSICA
                // -----------------------------------------

                cs_music_stop(),


                // -----------------------------------------
                // ESPERA
                // -----------------------------------------

                cs_wait(
                    20
                ),


                // -----------------------------------------
                // MOVER PLAYER A COORDENADA
                // -----------------------------------------
                //
                // Si empieza aproximadamente en:
                //
                // X = 668
                // Y = 194
                //
                // caminará hacia la derecha.
                //
                // -----------------------------------------

                cs_move_to(
                    "player",
                    700,
                    194
                ),


                // -----------------------------------------
                // DIÁLOGO
                // -----------------------------------------

                cs_dialog(
                    scr_loc_src(
                        "* Escuchaste algo extraño."
                    ),
                    noone,
                    snd_text
                ),


                cs_wait(
                    20
                ),


                // -----------------------------------------
                // SONIDO
                // -----------------------------------------

                cs_sound(
                    snd_menumove
                ),


                // -----------------------------------------
                // MOVER HACIA ARRIBA
                // -----------------------------------------

                cs_move_to(
                    "player",
                    700,
                    162
                ),


                cs_wait(
                    15
                ),


                cs_dialog(
                    scr_loc_src(
                        "* No parece haber nadie."
                    ),
                    noone,
                    snd_text
                ),


                // -----------------------------------------
                // REGRESAR HACIA ABAJO
                // -----------------------------------------

                cs_move_to(
                    "player",
                    700,
                    194
                ),


                // -----------------------------------------
                // TERMINAR MIRANDO ABAJO
                // -----------------------------------------

                cs_face(
                    "player",
                    "abajo"
                ),

                cs_end()
            ];



        // =================================================
        // PRUEBA DE DOS PERSONAJES
        // =================================================
        //
        // Ambos actores comienzan a caminar.
        //
        // false significa:
        //
        // "No esperes a que termine este movimiento antes
        // de ejecutar la siguiente acción".
        //
        // Luego cs_wait_moves() espera a los dos.
        //
        // =================================================

        case "prueba_dos_personajes":

            return [
                // -----------------------------------------
                // PLAYER
                // -----------------------------------------

                cs_move_to(
                    "player",
                    732,
                    194,
                    2,
                    false
                ),


                // -----------------------------------------
                // NOELLE
                // -----------------------------------------
                //
                // Estas son coordenadas de ejemplo.
                // Cámbialas según la habitación donde
                // hagas esta prueba.
                //
                // -----------------------------------------

                cs_move_to(
                    "noelle",
                    604,
                    194,
                    2,
                    false
                ),


                // -----------------------------------------
                // ESPERAR A AMBOS
                // -----------------------------------------

                cs_wait_moves(),


                cs_dialog(
                    scr_loc_src(
                        "* Ambos se detuvieron."
                    ),
                    noone,
                    snd_text
                ),

                cs_end()
            ];



        // =================================================
        // PRUEBA DE BATALLA
        // =================================================

        case "prueba_batalla":

            return [
                // -----------------------------------------
                // CALLAR MÚSICA DEL MAPA
                // -----------------------------------------

                cs_music_stop(),


                // -----------------------------------------
                // DIÁLOGO
                // -----------------------------------------

                cs_dialog(
                    scr_loc_src(
                        "* Algo se acerca..."
                    ),
                    noone,
                    snd_text
                ),


                // -----------------------------------------
                // PEQUEÑA ESPERA
                // -----------------------------------------

                cs_wait(
                    30
                ),


                // -----------------------------------------
                // BATALLA
                // -----------------------------------------

                cs_battle(
                    "toby"
                ),

                cs_end()
            ];



        // =================================================
        // PRUEBA DE DIÁLOGOS + MÚSICA
        // =================================================

        case "prueba_dialogos_musica":

            return [
                // -----------------------------------------
                // DIÁLOGO 1
                // -----------------------------------------

                cs_dialog(
                    scr_loc_src(
                        "* Esta es una prueba de diálogo."
                    ),
                    noone,
                    snd_text
                ),


                // -----------------------------------------
                // DIÁLOGO 2
                // -----------------------------------------

                cs_dialog(
                    scr_loc_src(
                        "* La música está a punto de cambiar."
                    ),
                    noone,
                    snd_text
                ),


                // -----------------------------------------
                // DETENER MÚSICA
                // -----------------------------------------

                cs_music_stop(),


                cs_wait(
                    30
                ),


                // -----------------------------------------
                // MUS_JEVIL
                // -----------------------------------------

                cs_music_play(
                    mus_jevil,
                    true,
                    true
                ),


                // -----------------------------------------
                // DIÁLOGO 3
                // -----------------------------------------

                cs_dialog(
                    scr_loc_src(
                        "* Ahora está sonando una música diferente."
                    ),
                    noone,
                    snd_text
                ),


                cs_wait(
                    20
                ),


                // -----------------------------------------
                // DIÁLOGO FINAL
                // -----------------------------------------

                cs_dialog(
                    scr_loc_src(
                        "* La cinemática terminará, pero la música continuará."
                    ),
                    noone,
                    snd_text
                ),

                cs_end()
            ];


        case "encuentro_joker":

            return [
                // -----------------------------------------
                // CALLAR MÚSICA ACTUAL
                // -----------------------------------------

                cs_music_stop(),


                // -----------------------------------------
                // PLAYER CAMINA HACIA LA DERECHA
                // -----------------------------------------
                //
                // IMPORTANTE:
                //
                // Cambia 700,194 por las coordenadas
                // exactas donde quieres que termine.
                //
                // La velocidad no está escrita,
                // por lo tanto utiliza la default:
                //
                // velocidad = 2
                //
                // -----------------------------------------

                cs_move_to(
                    "player",
                    248,
                    438
                ),


                // -----------------------------------------
                // DIÁLOGO
                // -----------------------------------------

                cs_dialog(
                    scr_loc_src(
                        "* Hay algo de malas vibras por aquí..."
                    ),
                    spr_noelle_normal,
                    snd_noelle
                ),


                // -----------------------------------------
                // MUS_PREJOKER
                // -----------------------------------------

                cs_music_play(
                    mus_prejoker,
                    true,
                    true
                ),


                // -----------------------------------------
                // JOKER
                // -----------------------------------------

                cs_dialog(
                    scr_loc_src(
                        "* VAYA, VAYA... ¿QUÉ TENEMOS AQUÍ?"
                    ),
                    noone,
                    snd_text
                ),


                cs_dialog(
                    scr_loc_src(
                        "* PARECE QUE LOS JUEGOS ESTÁN A PUNTO DE COMENZAR"
                    ),
                    noone,
                    snd_text
                ),


                // -----------------------------------------
                // RISA
                // -----------------------------------------
                //
                // true:
                // esperar a que termine el sonido.
                //
                // -----------------------------------------

                cs_sound(
                    snd_joker_risa,
                    true
                ),


                // -----------------------------------------
                // DIÁLOGO DEL PLAYER
                // -----------------------------------------

                cs_dialog(
                    scr_loc_src(
                        "* Esto se va a poner muy feo..."
                    ),
                    spr_noelle_normal,
                    snd_noelle
                ),


                // -----------------------------------------
                // SHINE
                // -----------------------------------------

                cs_sound(
                    snd_shine,
                    true
                ),


                // -----------------------------------------
                // BATALLA
                // -----------------------------------------

                cs_battle(
                    "boss_1"
                ),
				
				cs_music_stop(),
				
				cs_dialog(
                    scr_loc_src(
                        "* Bueno... sí estuvo feo. Fahaha."
                    ),
                    spr_noelle_normal,
                    snd_noelle
                ),
				
				cs_music_play(
                    mus_noelle_ferriswheel,
                    true,
                    true
                ),

                cs_end()
            ];



        // =================================================
        // DEFAULT
        // =================================================

        default:

            show_debug_message(
                "[CUTSCENE] Cinemática desconocida: "
                +
                string(_id)
            );


            return [];
    }
}