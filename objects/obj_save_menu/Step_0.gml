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
    // =====================================================
    // FASE 1
    // CUBRIR LA PANTALLA
    // =====================================================

    if (transicion_fase == 1)
    {
        transicion_progreso +=
            transicion_velocidad;


        if (transicion_progreso >= 1)
        {
            transicion_progreso =
                1;


            // =================================================
            // CARGAR PARTIDA CUANDO TODO ESTÁ CUBIERTO
            // =================================================

            if (
                scr_cargar_juego(
                    transicion_seccion
                )
            )
            {
                ini_open(
                    "save.ini"
                );


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


                global.new_game =
                    false;


                global.start_room =
                    transicion_room;


                global.start_x =
                    transicion_x;


                global.start_y =
                    transicion_y;


                // El menú sobrevivirá al cambio.
                persistent =
                    true;


                transicion_fase =
                    2;


                room_goto(
                    transicion_room
                );


                exit;
            }
            else
            {
                // =================================================
                // CARGA FALLIDA
                // =================================================
                //
                // Esto ya no debería ocurrir normalmente porque
                // comprobamos el slot ANTES de empezar el fade.
                // =================================================

                if (audio_is_playing(snd_error))
                {
                    audio_stop_sound(
                        snd_error
                    );
                }


                audio_play_sound(
                    snd_error,
                    10,
                    false
                );


                transicion_fase =
                    3;
            }
        }
    }


    // =====================================================
    // FASE 2
    // ESPERANDO ROOM START
    // =====================================================

    else if (transicion_fase == 2)
    {
        // Room Start continuará.
    }


    // =====================================================
    // FASE 3
    // DESCUBRIR NUEVA ROOM
    // =====================================================

    else if (transicion_fase == 3)
    {
        transicion_progreso -=
            transicion_velocidad;


        if (transicion_progreso <= 0)
        {
            transicion_progreso =
                0;


            if (instance_exists(obj_player))
            {
                if (
                    variable_instance_exists(
                        obj_player,
                        "puede_moverse"
                    )
                )
                {
                    obj_player.puede_moverse =
                        true;
                }


                if (
                    variable_instance_exists(
                        obj_player,
                        "can_move"
                    )
                )
                {
                    obj_player.can_move =
                        true;
                }
            }


            persistent =
                false;


            instance_destroy();


            exit;
        }
    }


    exit;
}


// =========================================================
// ESTADO 0
// MENÚ DE ACCIONES
// =========================================================

if (state == 0)
{
    var min_idx =
        from_title
        ?
        1
        :
        0;


    // =====================================================
    // ABAJO
    // =====================================================

    if (keyboard_check_pressed(vk_down))
    {
        action_index++;


        if (action_index > 2)
        {
            action_index =
                min_idx;
        }


        audio_play_sound(
            snd_menumove,
            10,
            false
        );
    }


    // =====================================================
    // ARRIBA
    // =====================================================

    if (keyboard_check_pressed(vk_up))
    {
        action_index--;


        if (action_index < min_idx)
        {
            action_index =
                2;
        }


        audio_play_sound(
            snd_menumove,
            10,
            false
        );
    }


    // =====================================================
    // CONFIRMAR
    // =====================================================

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


        state =
            1;
    }


    // =====================================================
    // CERRAR
    // =====================================================

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
    // =====================================================
    // ABAJO
    // =====================================================

    if (keyboard_check_pressed(vk_down))
    {
        slot_index =
            (slot_index + 1)
            %
            3;


        audio_play_sound(
            snd_menumove,
            10,
            false
        );
    }


    // =====================================================
    // ARRIBA
    // =====================================================

    if (keyboard_check_pressed(vk_up))
    {
        slot_index =
            (slot_index - 1 + 3)
            %
            3;


        audio_play_sound(
            snd_menumove,
            10,
            false
        );
    }


    // =====================================================
    // VOLVER
    // =====================================================

    if (keyboard_check_pressed(ord("X"))
    )
    {
        audio_play_sound(
            snd_menumove,
            10,
            false
        );


        state =
            0;


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
            action_options[
                action_index
            ];


        var _seccion_actual =
            "Save"
            +
            string(
                slot_index + 1
            );


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


                slots_data[
                    slot_index
                ].lugar =
                    get_room_name(
                        room
                    );


                slots_data[
                    slot_index
                ].tiempo =
                    scr_format_playtime(
                        global.playtime_frames
                    );


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
            // =================================================
            // COMPROBAR SI EL SLOT TIENE GUARDADO
            // =================================================

            var _slot_tiene_guardado =
                false;


            // ---------------------------------------------
            // Primero comprobamos que save.ini exista.
            // ---------------------------------------------

            if (file_exists("save.ini"))
            {
                ini_open(
                    "save.ini"
                );


                // -----------------------------------------
                // Debe tener al menos:
                //
                // - room
                // - extra_data
                //
                // extra_data es donde está realmente
                // toda la información del guardado.
                // -----------------------------------------

                var _tiene_room =
                    ini_key_exists(
                        _seccion_actual,
                        "room"
                    );


                var _extra_guardado =
                    ini_read_string(
                        _seccion_actual,
                        "extra_data",
                        ""
                    );


                ini_close();


                _slot_tiene_guardado =
                    _tiene_room
                    &&
                    (_extra_guardado != "");
            }


            // =================================================
            // SLOT VACÍO
            // =================================================

            if (!_slot_tiene_guardado)
            {
                // Cortar el error anterior para evitar
                // que se acumulen sonidos al spamear Z.
                if (audio_is_playing(snd_error))
                {
                    audio_stop_sound(
                        snd_error
                    );
                }


                audio_play_sound(
                    snd_error,
                    10,
                    false
                );


                // No iniciar transición.
                // No salir del menú.
                exit;
            }


            // =================================================
            // SLOT VÁLIDO
            // =================================================

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


            ini_open(
                "save.ini"
            );


            ini_section_delete(
                _seccion_actual
            );


            ini_close();


            slots_data[
                slot_index
            ].lugar =
                scr_loc_src(
                    "Datos vacios"
                );


            slots_data[
                slot_index
            ].tiempo =
                "--:--:--";
        }
    }
}
