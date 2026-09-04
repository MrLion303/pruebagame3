if (
    variable_global_exists("gameover_death_freeze_active")
    &&
    global.gameover_death_freeze_active
)
{
    exit;
}


// =========================================================
// OBJ_SAVE_MENU
// STEP
// =========================================================


// Bloquear pausa mientras este menú exista.
keyboard_clear(ord("C"));
keyboard_clear(vk_control);


// =========================================================
// PARTIDA SALVADA
// =========================================================

if (guardado_confirmado)
{
    // Después de guardar únicamente esperamos
    // Z o Enter para cerrar.

    if (
        keyboard_check_pressed(ord("Z"))
        ||
        keyboard_check_pressed(vk_enter)
    )
    {
        audio_play_sound(
            snd_menumove,
            10,
            false
        );

        // IMPORTANTE:
        // Consumimos la misma pulsación que cierra el menú.
        //
        // Si no hacemos esto, el objeto del punto de guardado puede
        // detectar este mismo Z/Enter después de destruir obj_save_menu
        // y volver a abrirlo inmediatamente, dando la impresión de que
        // regresamos al botón "Salvar".
        keyboard_clear(ord("Z"));
        keyboard_clear(vk_enter);

        instance_destroy();

        exit;
    }

    exit;
}


// =========================================================
// TRANSICIÓN ACTIVA
// =========================================================

if (transicion_activa)
{
    // -----------------------------------------------------
    // FASE 1
    // CUBRIR LA PANTALLA
    // -----------------------------------------------------

    if (transicion_fase == 1)
    {
        transicion_progreso += transicion_velocidad;

        if (transicion_progreso >= 1)
        {
            transicion_progreso = 1;


            // =============================================
            // AHORA QUE TODO ESTÁ CUBIERTO,
            // CARGAMOS LA PARTIDA
            // =============================================

            if (scr_cargar_juego(transicion_seccion))
            {
                ini_open("save.ini");


                transicion_room =
                    ini_read_real(
                        transicion_seccion,
                        "room",
                        global.rm1
                    );


                transicion_x =
                    ini_read_real(
                        transicion_seccion,
                        "x",
                        668
                    );


                transicion_y =
                    ini_read_real(
                        transicion_seccion,
                        "y",
                        194
                    );


                ini_close();


                global.new_game = false;

                global.start_room =
                    transicion_room;

                global.start_x =
                    transicion_x;

                global.start_y =
                    transicion_y;


                // -----------------------------------------
                // IMPORTANTE:
                // El propio menú sobrevivirá al cambio.
                // -----------------------------------------

                persistent = true;

                transicion_fase = 2;


                // Cambiar habitación únicamente cuando
                // la pantalla está totalmente cubierta.
                room_goto(
                    transicion_room
                );

                exit;
            }
            else
            {
                // Falló la carga:
                // retiramos el fade.
                transicion_fase = 3;
            }
        }
    }


    // -----------------------------------------------------
    // FASE 2
    // ESPERANDO ROOM START
    // -----------------------------------------------------

    else if (transicion_fase == 2)
    {
        // No hacer nada.
        //
        // Room Start continuará el proceso.
    }


    // -----------------------------------------------------
    // FASE 3
    // DESCUBRIR LA NUEVA ROOM
    // -----------------------------------------------------

    else if (transicion_fase == 3)
    {
        transicion_progreso -= transicion_velocidad;

        if (transicion_progreso <= 0)
        {
            transicion_progreso = 0;


            // ---------------------------------------------
            // DEVOLVER MOVIMIENTO
            // ---------------------------------------------

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


            // Ya no necesitamos persistencia.
            persistent = false;

            instance_destroy();

            exit;
        }
    }


    // Mientras haya transición no aceptamos
    // ningún control del menú.
    exit;
}


// =========================================================
// ESTADO 0
// MENÚ DE ACCIONES
// =========================================================

if (state == 0)
{
    var min_idx =
        from_title ? 1 : 0;


    // -----------------------------------------------------
    // ABAJO
    // -----------------------------------------------------

    if (keyboard_check_pressed(vk_down))
    {
        action_index++;

        if (action_index > 2)
        {
            action_index = min_idx;
        }

        audio_play_sound(
            snd_menumove,
            10,
            false
        );
    }


    // -----------------------------------------------------
    // ARRIBA
    // -----------------------------------------------------

    if (keyboard_check_pressed(vk_up))
    {
        action_index--;

        if (action_index < min_idx)
        {
            action_index = 2;
        }

        audio_play_sound(
            snd_menumove,
            10,
            false
        );
    }


    // -----------------------------------------------------
    // CONFIRMAR
    // -----------------------------------------------------

    if (
        keyboard_check_pressed(ord("Z"))
        ||
        keyboard_check_pressed(vk_enter)
    )
    {
        audio_play_sound(
            snd_menumove,
            10,
            false
        );

        state = 1;
    }


    // -----------------------------------------------------
    // CERRAR
    // -----------------------------------------------------

    if (keyboard_check_pressed(ord("X")))
    {
        audio_play_sound(
            snd_menumove,
            10,
            false
        );

        instance_destroy();
    }
}


// =========================================================
// ESTADO 1
// SLOTS
// =========================================================

else if (state == 1)
{
    // -----------------------------------------------------
    // ABAJO
    // -----------------------------------------------------

    if (keyboard_check_pressed(vk_down))
    {
        slot_index =
            (slot_index + 1) % 3;

        audio_play_sound(
            snd_menumove,
            10,
            false
        );
    }


    // -----------------------------------------------------
    // ARRIBA
    // -----------------------------------------------------

    if (keyboard_check_pressed(vk_up))
    {
        slot_index =
            (slot_index - 1 + 3) % 3;

        audio_play_sound(
            snd_menumove,
            10,
            false
        );
    }


    // -----------------------------------------------------
    // VOLVER
    // -----------------------------------------------------

    if (keyboard_check_pressed(ord("X")))
    {
        audio_play_sound(
            snd_menumove,
            10,
            false
        );

        state = 0;

        exit;
    }


    // =====================================================
    // CONFIRMAR SLOT
    // =====================================================

    if (
        keyboard_check_pressed(ord("Z"))
        ||
        keyboard_check_pressed(vk_enter)
    )
    {
        var _accion =
            action_options[action_index];

        var _seccion_actual =
            "Save" + string(slot_index + 1);


        // =================================================
        // SALVAR
        // =================================================

        if (_accion == "Salvar")
        {
            if (instance_exists(obj_player))
            {
                audio_play_sound(
                    snd_save,
                    10,
                    false
                );


                scr_guardar_juego(
                    _seccion_actual
                );


                slots_data[slot_index].lugar =
                    scr_save_room_name(room);


                slots_data[slot_index].tiempo =
                    scr_format_playtime(
                        global.playtime_frames
                    );


                // NO cerrar.
                //
                // Cambiamos visualmente el nombre del
                // archivo a "Partida Salvada".
                guardado_slot =
                    slot_index;

                guardado_confirmado =
                    true;
            }
        }


        // =================================================
        // CARGAR
        // =================================================

        else if (_accion == "Cargar")
        {
            // IMPORTANTE:
            //
            // NO se ejecuta scr_cargar_juego aquí.
            //
            // Primero iniciamos el fade.

            audio_play_sound(
                snd_shineselect,
                10,
                false
            );


            transicion_seccion =
                _seccion_actual;

            transicion_progreso =
                0;

            transicion_fase =
                1;

            transicion_activa =
                true;


            // Bloquear jugador mientras cargamos.
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
        }


        // =================================================
        // BORRAR
        // =================================================

        else if (_accion == "Borrar")
        {
            audio_play_sound(
                snd_trashsave,
                10,
                false
            );


            ini_open("save.ini");

            ini_section_delete(
                _seccion_actual
            );

            ini_close();


            slots_data[slot_index].lugar =
                scr_loc_src(
                    "Datos vacios"
                );


            slots_data[slot_index].tiempo =
                "--:--:--";
        }
    }
}
