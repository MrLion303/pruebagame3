/// =========================================================
/// SCR_CUTSCENE_DATA
/// =========================================================
///
/// BASE DE DATOS DE CINEMÁTICAS.
///
/// CADA CINEMÁTICA DEBE ESPECIFICAR SI EL JUGADOR
/// PUEDE MOVERSE LIBREMENTE:
///
///     return cs_scene(false, [  // jugador bloqueado
///         ...
///         cs_end()
///     ]);
///
///     return cs_scene(true, [   // jugador puede caminar
///         ...
///         cs_end()
///     ]);
///
/// true/false NO afecta a los movimientos programados con
/// cs_move_to(). Durante un cs_move_to del player, el control
/// manual se bloquea temporalmente y después se restaura.
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

            return cs_scene(false, [
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
            ]);



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

            return cs_scene(false, [
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
                // MAYA
                // -----------------------------------------
                //
                // Estas son coordenadas de ejemplo.
                // Cámbialas según la habitación donde
                // hagas esta prueba.
                //
                // -----------------------------------------

                cs_move_to(
                    "maya",
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
            ]);



        // =================================================
        // PRUEBA DE BATALLA
        // =================================================

        case "prueba_batalla":

            return cs_scene(false, [
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
            ]);



        // =================================================
        // PRUEBA DE DIÁLOGOS + MÚSICA
        // =================================================

        case "prueba_dialogos_musica":

            return cs_scene(false, [
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
            ]);



        // =================================================
        // ENCUENTRO JOKER
        // =================================================
        //
        // Secuencia:
        //
        // música se calla
        // ↓
        // jugador camina
        // ↓
        // diálogo
        // ↓
        // mus_prejoker
        // ↓
        // diálogos
        // ↓
        // risa
        // ↓
        // diálogo
        // ↓
        // shine
        // ↓
        // boss_1
        //
        // =================================================

        case "encuentro_joker":

            return cs_scene(false, [
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
            ]);

// =========================================================
// ENCUENTRO JOKER 2
// =========================================================

case "encuentro_joker_2":

    return cs_scene(false, [

        // =================================================
        // INICIO - IGUAL A ENCUENTRO_JOKER
        // =================================================

        cs_music_stop(),


        // Player va a la misma posición del encuentro 1
        cs_move_to(
            "player",
            248,
            438
        ),


        cs_dialog(
            scr_loc_src(
                "* Hay algo de malas vibras por aquí..."
            ),
            spr_noelle_normal,
            snd_noelle
        ),


        cs_music_play(
            mus_prejoker,
            true,
            true
        ),


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


        cs_sound(
            snd_joker_risa,
            true
        ),


        cs_dialog(
            scr_loc_src(
                "* Esto se va a poner muy feo..."
            ),
            spr_noelle_normal,
            snd_noelle
        ),


        cs_sound(
            snd_shine,
            true
        ),


        // =================================================
        // BATALLA
        // =================================================

        cs_battle(
            "boss_1"
        ),


        // =================================================
        // REGRESO DE LA BATALLA
        // =================================================

        cs_music_stop(),


        cs_dialog(
            scr_loc_src(
                "* Bueno... sí estuvo feo. Fahaha."
            ),
            spr_noelle_normal,
            snd_noelle
        ),


        // =================================================
        // CÁMARA 100 PX A LA DERECHA
        //
        // X = +100 -> derecha
        // Y = 0    -> no cambia verticalmente
        // =================================================

        cs_camera_move(
            100,
            0
        ),


        cs_dialog(
            scr_loc_src(
                "* BUENO, ESO NO FUE COMO LO PENSÉ"
            ),
            noone,
            snd_text
        ),


        cs_dialog(
            scr_loc_src(
                "* YA NO FUE TAN DIVERTIDO"
            ),
            noone,
            snd_text
        ),


        // Cámara vuelve exactamente a donde estaba
        cs_camera_reset(),


        // =================================================
        // APARECER OBJ_NPC_4
        // =================================================
        //
        // Player está en:
        //
        // X = 248
        // Y = 438
        //
        // 20 píxeles a su derecha:
        //
        // X = 268
        // Y = 438
        //
        // =================================================

        cs_npc_appear(
            "joker_2",
            obj_npc_4,
            268,
            438
        ),


        cs_dialog(
            scr_loc_src(
                "* BUENO, ESO FUE TODO AMIGOS, PERO ANTES..."
            ),
            noone,
            snd_text
        ),


        // =================================================
        // MOSTRAR IMAGEN
        // =================================================

        cs_image_show(
            spr_imagen_cinematica_1
        ),


        // La imagen permanece en pantalla mientras
        // ocurren estos diálogos.

        cs_dialog(
            scr_loc_src(
                "* ¿Eso qué es?..."
            ),
            spr_noelle_normal,
            snd_noelle
        ),


        // =================================================
        // DIÁLOGO + SND_JOKER_RISA
        // =================================================
        //
        // snd_text:
        // sonido normal por letras
        //
        // snd_joker_risa:
        // sonido largo que empieza junto al textbox
        //
        // false:
        // NO cortar la risa aunque el diálogo termine
        // antes que el audio.
        // =================================================

        cs_dialog(
            scr_loc_src(
                "* NI SIQUIERA YO LO SÉ, SOLO ME PARECIÓ INTERESANTE"
            ),
            noone,
            snd_text,
            c_white,
            snd_joker_risa,
            false
        ),


        cs_dialog(
            scr_loc_src(
                "* Ya..."
            ),
            spr_noelle_normal,
            snd_noelle
        ),


        // =================================================
        // QUITAR IMAGEN
        // =================================================

        cs_image_hide(),


        // =================================================
        // MUS_MAN
        // =================================================

        cs_music_play(
            mus_man,
            true,
            true
        ),


        cs_dialog(
            scr_loc_src(
                "* BUENO BAI HEHE"
            ),
            noone,
            snd_text
        ),


        // =================================================
        // DESAPARECER JOKER + SHINE
        // =================================================
        //
        // false hace que no esperemos a que snd_shine
        // termine.
        //
        // Por eso el sonido comienza y acto seguido
        // desaparece el NPC mientras el sonido sigue.
        // =================================================

        cs_sound(
            snd_shine,
            false
        ),


        cs_npc_disappear(
            "joker_2"
        ),


        // =================================================
        // MAYA
        // =================================================

        cs_dialog(
            scr_loc_src(
                "* Ok?..."
            ),
            spr_noelle_normal,
            snd_noelle
        ),


        // =================================================
        // FIN REAL
        // =================================================

        cs_end()
    ]);

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