// ============================================
// OBJ_GAME_OVER_TEXTO
// STEP
// ============================================


// ============================================
// BLOQUEAR C / CTRL
// ============================================
//
// También existe un bloqueo en obj_menu_manager.
// Este segundo bloqueo consume las teclas desde el propio
// flujo de Game Over.
//
keyboard_clear(ord("C"));
keyboard_clear(vk_control);


// ============================================
// MANTENER AL JUGADOR BLOQUEADO
// ============================================
//
// IMPORTANTE:
//
// En game_over permanece invisible.
//
// Cuando Despertar ya cambió a la room guardada:
//     estado == 3
//     carga_room_lista == true
//
// Maya vuelve a ser VISIBLE inmediatamente.
//
// Sigue sin poder moverse hasta terminar el fade blanco.
// Así Maya aparece al mismo tiempo que aparece la room.
//
var _player_visible =
    (
        estado == 3
        &&
        carga_room_lista
    );


with (obj_player)
{
    visible =
        _player_visible;


    if (variable_instance_exists(id, "puede_moverse"))
        puede_moverse = false;

    if (variable_instance_exists(id, "can_move"))
        can_move = false;

    if (variable_instance_exists(id, "movimiento"))
        movimiento = false;

    if (variable_instance_exists(id, "walk_anim_hold"))
        walk_anim_hold = 0;

    hspeed = 0;
    vspeed = 0;
    speed = 0;
}


// ============================================
// INPUT
// ============================================

var _confirmar =
    keyboard_check_pressed(ord("Z"))
    || keyboard_check_pressed(vk_enter);


var _rapido =
    keyboard_check(ord("X"))
    || keyboard_check(vk_shift);


// X / Shift = velocidad x2
var _multiplicador =
    _rapido ? 2 : 1;



// ============================================================
// ESTADO 0
// DIÁLOGO PRINCIPAL
// ============================================================

if (estado == 0)
{
    // Resolver la traducción de la página actual.
    // El typewriter trabaja sobre el texto YA traducido,
    // por lo que su longitud y caracteres coinciden con
    // lo que realmente se dibuja.
    var _texto =
        scr_loc(
            textos[pagina]
        );

    var _largo =
        string_length(
            _texto
        );


    // ========================================
    // TYPEWRITER
    // ========================================

    if (caracteres < _largo)
    {
        acumulador_texto +=
            velocidad_texto * _multiplicador;


        var _hacer_sonido = false;


        while (acumulador_texto >= 1)
        {
            caracteres++;
            acumulador_texto--;


            if (caracteres > _largo)
            {
                caracteres = _largo;
                break;
            }


            var _char =
                string_char_at(
                    _texto,
                    caracteres
                );


            // No sonar en espacios ni saltos
            if (
                _char != " "
                && _char != "\n"
            )
            {
                _hacer_sonido = true;
            }


            if (caracteres >= _largo)
            {
                caracteres = _largo;
                break;
            }
        }


        // ====================================
        // SONIDO DE TEXTO
        // ====================================

        if (_hacer_sonido)
        {
            audio_stop_sound(snd_text);

            audio_play_sound(
                snd_text,
                0,
                false
            );
        }
    }



    // ========================================================
    // PRIMEROS 3 TEXTOS
    // ========================================================

    if (pagina < 3)
    {
        // Solo puede avanzar cuando
        // terminó de escribirse.
        if (
            _confirmar
            && caracteres >= _largo
        )
        {
            pagina++;

            caracteres = 0;
            acumulador_texto = 0;


            // Cuando llegamos a la pregunta final,
            // aseguramos que las opciones comiencen
            // totalmente invisibles.
            if (pagina == 3)
            {
                opciones_alpha = 0;
            }
        }
    }


    // ========================================================
    // PREGUNTA FINAL
    // ========================================================

    else
    {
        if (caracteres >= _largo)
        {
            // ====================================
            // FADE IN DE DESPERTAR / OLVIDAR
            // ====================================

            if (opciones_alpha < 1)
            {
                opciones_alpha +=
                    opciones_fade_vel;


                if (opciones_alpha > 1)
                {
                    opciones_alpha = 1;
                }
            }


            // ====================================
            // CONTROL SOLO CUANDO YA APARECIERON
            // ====================================

            if (opciones_alpha >= 1)
            {
                // --------------------------------
                // SELECCIÓN IZQUIERDA
                // --------------------------------

                if (
                    keyboard_check_pressed(vk_left)
                    || keyboard_check_pressed(vk_up)
                )
                {
                    seleccion = 0;
                }


                // --------------------------------
                // SELECCIÓN DERECHA
                // --------------------------------

                if (
                    keyboard_check_pressed(vk_right)
                    || keyboard_check_pressed(vk_down)
                )
                {
                    seleccion = 1;
                }


                // --------------------------------
                // CONFIRMAR
                // --------------------------------

                if (_confirmar)
                {
                    // ============================
                    // DESPERTAR
                    // ============================

                    if (seleccion == 0)
                    {
                        estado = 2;

                        fade_blanco = 0;
                        timer_blanco = 0;

                        audio_stop_sound(snd_text);
                    }


                    // ============================
                    // OLVIDAR
                    // ============================

                    else
                    {
                        estado = 1;

                        caracteres_olvidar = 0;
                        acumulador_olvidar = 0;

                        timer_cerrar = -1;

                        audio_stop_sound(snd_text);
                    }
                }
            }
        }
    }
}



// ============================================================
// ESTADO 1
// OLVIDAR
// ============================================================

else if (estado == 1)
{
    var _texto_olvidar_actual =
        scr_loc(
            texto_olvidar
        );


    var _largo =
        string_length(
            _texto_olvidar_actual
        );


    // ========================================
    // TYPEWRITER
    // ========================================

    if (caracteres_olvidar < _largo)
    {
        acumulador_olvidar +=
            velocidad_texto * _multiplicador;


        var _hacer_sonido = false;


        while (acumulador_olvidar >= 1)
        {
            caracteres_olvidar++;
            acumulador_olvidar--;


            if (caracteres_olvidar > _largo)
            {
                caracteres_olvidar = _largo;
                break;
            }


            var _char =
                string_char_at(
                    _texto_olvidar_actual,
                    caracteres_olvidar
                );


            if (
                _char != " "
                && _char != "\n"
            )
            {
                _hacer_sonido = true;
            }


            if (caracteres_olvidar >= _largo)
            {
                caracteres_olvidar = _largo;
                break;
            }
        }


        // ====================================
        // SONIDO
        // ====================================

        if (_hacer_sonido)
        {
            audio_stop_sound(snd_text);

            audio_play_sound(
                snd_text,
                0,
                false
            );
        }
    }


    // ========================================
    // ESPERAR Y CERRAR
    // ========================================

    if (
        caracteres_olvidar
        >= _largo
    )
    {
        if (timer_cerrar == -1)
        {
            timer_cerrar = 0;
        }
        else
        {
            timer_cerrar++;


            // 60 frames a 30 FPS
            // = 2 segundos
            if (timer_cerrar >= 60)
            {
                game_end();
            }
        }
    }
}



// ============================================================
// ESTADO 2
// DESPERTAR
// ============================================================

else if (estado == 2)
{
    // ========================================
    // FADE HACIA BLANCO
    // ========================================

    if (fade_blanco < 1)
    {
        fade_blanco +=
            velocidad_fade;


        if (fade_blanco >= 1)
        {
            fade_blanco = 1;

            // Aquí comienza el segundo COMPLETO
            // de pantalla blanca.
            timer_blanco = 0;
        }
    }


    // ========================================
    // PANTALLA COMPLETAMENTE BLANCA
    // ========================================

    else
    {
        timer_blanco++;


        // 30 frames a 30 FPS
        // = 1 segundo COMPLETO.
        if (
            timer_blanco >= 30
            &&
            !carga_iniciada
        )
        {
            // ==============================================
            // IDENTIFICAR ÚLTIMO SAVE
            // ==============================================

            carga_seccion =
                obtener_ultimo_save();


            if (carga_seccion == "")
            {
                show_debug_message(
                    "[GAME OVER] ERROR: No existe una partida guardada válida."
                );

                // No repetir el intento 30 veces por segundo.
                carga_iniciada = true;

                exit;
            }


            // Mantener también la referencia global.
            global.save_actual =
                carga_seccion;


            // ==============================================
            // MISMA FUNCIÓN QUE USA CARGAR
            // ==============================================

            if (scr_cargar_juego(carga_seccion))
            {
                // ==========================================
                // LEER POSICIÓN / ROOM DEL MISMO SLOT
                // ==========================================

                ini_open("save.ini");


                carga_room =
                    ini_read_real(
                        carga_seccion,
                        "room",
                        global.rm1
                    );


                carga_x =
                    ini_read_real(
                        carga_seccion,
                        "x",
                        668
                    );


                carga_y =
                    ini_read_real(
                        carga_seccion,
                        "y",
                        194
                    );


                ini_close();


                // ==========================================
                // IGUAL QUE obj_save_menu AL CARGAR
                // ==========================================

                global.new_game =
                    false;


                global.start_room =
                    carga_room;


                global.start_x =
                    carga_x;


                global.start_y =
                    carga_y;


                // El objeto debe sobrevivir al room_goto
                // para mantener TODO blanco.
                persistent =
                    true;


                carga_iniciada =
                    true;


                // Estado 3:
                // esperamos Room Start y luego retiramos
                // el blanco.
                estado =
                    3;


                fade_blanco =
                    1;


                room_goto(
                    carga_room
                );


                exit;
            }
            else
            {
                show_debug_message(
                    "[GAME OVER] ERROR: scr_cargar_juego falló para "
                    +
                    string(carga_seccion)
                );


                carga_iniciada =
                    true;
            }
        }
    }
}


// ============================================================
// ESTADO 3
// PARTIDA CARGADA - RETIRAR BLANCO
// ============================================================

else if (estado == 3)
{
    // Room Start debe haber colocado y restaurado al player.
    if (!carga_room_lista)
    {
        exit;
    }


    // Seguimos bloqueándolo hasta que la pantalla
    // vuelva a estar completamente visible.
    if (instance_exists(obj_player))
    {
        with (obj_player)
        {
            // La room ya está cargada.
            // Maya debe revelarse JUNTO con la room.
            visible = true;

            if (variable_instance_exists(id, "puede_moverse"))
                puede_moverse = false;

            if (variable_instance_exists(id, "can_move"))
                can_move = false;

            if (variable_instance_exists(id, "movimiento"))
                movimiento = false;

            hspeed = 0;
            vspeed = 0;
            speed = 0;
        }
    }


    // ========================================
    // QUITAR EL BLANCO
    // ========================================

    fade_blanco -=
        velocidad_fade;


    if (fade_blanco <= 0)
    {
        fade_blanco =
            0;


        // ====================================
        // DEVOLVER AL PLAYER
        // ====================================

        if (instance_exists(obj_player))
        {
            var _p =
                instance_find(
                    obj_player,
                    0
                );


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
                    true;
            }


            if (
                variable_instance_exists(
                    _p,
                    "can_move"
                )
            )
            {
                _p.can_move =
                    true;
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


        // Ya estamos completamente de vuelta
        // en la partida guardada.
        persistent =
            false;


        instance_destroy();


        exit;
    }
}
