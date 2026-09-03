// =========================================================
// CONSOLA ABIERTA: NO RECIBIR INPUT DE GAMEPLAY
// =========================================================

if (
    variable_global_exists("dev_console_open")
    &&
    global.dev_console_open
)
{
    exit;
}



/// =========================================================
/// OBJ_SHOP_CONTROLLER
/// STEP COMPLETO
/// =========================================================


// =========================================================
// BLOQUEAR PLAYER TODO EL TIEMPO
// =========================================================

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


// Evitar abrir pausa dentro de la tienda.
if (instance_exists(obj_menu_manager))
{
    if (
        variable_instance_exists(
            obj_menu_manager,
            "state"
        )
    )
    {
        obj_menu_manager.state =
            0;
    }
}


keyboard_clear(
    ord("C")
);


// =========================================================
// MENSAJE TEMPORAL
// =========================================================

if (shop_message_timer > 0)
{
    shop_message_timer--;


    if (shop_message_timer <= 0)
    {
        shop_message =
            "";
    }
}


// =========================================================
// INPUT GENERAL
// =========================================================

var _confirm =
    keyboard_check_pressed(ord("Z"))
    ||
    keyboard_check_pressed(vk_enter);


var _back =
    keyboard_check_pressed(ord("X"))
    ||
    keyboard_check_pressed(vk_shift);


var _up =
    keyboard_check_pressed(vk_up)
    ||
    keyboard_check_pressed(ord("W"));


var _down =
    keyboard_check_pressed(vk_down)
    ||
    keyboard_check_pressed(ord("S"));


var _left =
    keyboard_check_pressed(vk_left)
    ||
    keyboard_check_pressed(ord("A"));


var _right =
    keyboard_check_pressed(vk_right)
    ||
    keyboard_check_pressed(ord("D"));

var _fast_skip =
    keyboard_check(
        talk_fast_skip_key
    );


// Durante cualquier transición normal de habitación, la tienda
// no procesa entradas. obj_warp se encarga de todo.
if (instance_exists(obj_warp))
{
    exit;
}


// =========================================================
// TOP
// =========================================================

if (state == SHOP_TOP)
{
    var _moved =
        false;


    if (_left)
    {
        top_index =
            (
                top_index
                -
                1
                +
                array_length(top_options)
            )
            mod
            array_length(top_options);

        _moved =
            true;
    }


    if (_right)
    {
        top_index =
            (
                top_index
                +
                1
            )
            mod
            array_length(top_options);

        _moved =
            true;
    }


    if (_moved)
    {
        // SALIR solo cambia el resaltado superior.
        // No cambia el contenido que ya estaba visible.
        if (top_index != 3)
        {
            top_preview_index =
                top_index;
        }


        // Al cambiar de pestaña se limpia el último mensaje
        // persistente de compra/venta.
        shop_message =
            "";

        shop_message_timer =
            0;

        audio_play_sound(
            snd_menumove,
            10,
            false
        );
    }


    if (_confirm)
    {
        switch (top_index)
        {
            // =============================================
            // COMPRAR
            // =============================================

            case 0:

                state =
                    SHOP_BUY;

                buy_index =
                    0;

                buy_scroll =
                    0;

                audio_play_sound(
                    snd_menumove,
                    10,
                    false
                );

                break;


            // =============================================
            // VENDER
            // =============================================

            case 1:

                // Primero elegimos qué clase de objeto vender.
                sell_type_index =
                    0;

                sell_index =
                    0;

                sell_scroll =
                    0;

                sell_list =
                    [];

                state =
                    SHOP_SELL_TYPE;

                audio_play_sound(
                    snd_menumove,
                    10,
                    false
                );

                break;


            // =============================================
            // HABLAR
            // =============================================

            case 2:

                talk_index =
                    0;

                state =
                    SHOP_TALK;

                audio_play_sound(
                    snd_menumove,
                    10,
                    false
                );

                break;


            // =============================================
            // SALIR
            // =============================================

            case 3:

                exit_dialogues =
                    shop_data.despedida_dialogos;

                exit_line_index =
                    0;

                exit_char =
                    0;

                exit_sound_timer =
                    0;


                if (
                    array_length(exit_dialogues)
                    <=
                    0
                )
                {
                    // Sin diálogo: volver directamente al
                    // punto EXACTO desde el que entramos.
                    if (!shop_return_to_entry())
                    {
                        // Fallback para una tienda abierta sin
                        // pasar por un obj_warp_block.
                        if (
                            shop_data.salida_room
                            !=
                            noone
                        )
                        {
                            var _p =
                                instance_find(
                                    obj_player,
                                    0
                                );


                            room_goto(
                                shop_data.salida_room
                            );


                            if (
                                _p != noone
                                &&
                                instance_exists(_p)
                            )
                            {
                                _p.x =
                                    shop_data.salida_x;

                                _p.y =
                                    shop_data.salida_y;


                                if (
                                    variable_instance_exists(
                                        _p,
                                        "face"
                                    )
                                )
                                {
                                    _p.face =
                                        shop_data.salida_face;
                                }
                            }
                        }

                        instance_destroy();
                    }

                    // Si había retorno universal, obj_warp ya está
                    // ejecutando la transición normal de salida.
                    exit;
                }


                state =
                    SHOP_EXIT_DIALOG;

                audio_play_sound(
                    snd_menumove,
                    10,
                    false
                );

                break;
        }
    }


    exit;
}


// =========================================================
// BACK / VOLVER
// =========================================================
//
// VENDER lista -> selector de categoría.
// Selector de categoría -> pestañas.
// El resto de submenús -> pestañas.
// No se cancela un diálogo ya iniciado.
// =========================================================

if (_back)
{
    if (state == SHOP_SELL)
    {
        state =
            SHOP_SELL_TYPE;

        sell_index =
            0;

        sell_scroll =
            0;

        audio_play_sound(
            snd_menumove,
            10,
            false
        );

        exit;
    }


    if (state == SHOP_SELL_TYPE)
    {
        state =
            SHOP_TOP;

        audio_play_sound(
            snd_menumove,
            10,
            false
        );

        exit;
    }


    if (
        state != SHOP_TALK_DIALOG
        &&
        state != SHOP_EXIT_DIALOG
    )
    {
        state =
            SHOP_TOP;

        audio_play_sound(
            snd_menumove,
            10,
            false
        );

        exit;
    }
}


// =========================================================
// COMPRAR
// =========================================================

if (state == SHOP_BUY)
{
    var _stock =
        shop_data.items_venta;

    var _count =
        array_length(_stock);


    if (_count <= 0)
    {
        if (_confirm)
        {
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
        }

        exit;
    }


    // -----------------------------------------------------
    // NAVEGACIÓN
    // -----------------------------------------------------

    if (_up)
    {
        buy_index =
            max(
                0,
                buy_index - 1
            );

        audio_play_sound(
            snd_menumove,
            10,
            false
        );
    }


    if (_down)
    {
        buy_index =
            min(
                _count - 1,
                buy_index + 1
            );

        audio_play_sound(
            snd_menumove,
            10,
            false
        );
    }


    if (buy_index < buy_scroll)
    {
        buy_scroll =
            buy_index;
    }


    if (
        buy_index
        >=
        buy_scroll + visible_rows
    )
    {
        buy_scroll =
            buy_index
            -
            visible_rows
            +
            1;
    }


    // -----------------------------------------------------
    // COMPRAR
    // -----------------------------------------------------

    if (_confirm)
    {
        var _entry =
            _stock[
                buy_index
            ];


        var _data =
            scr_shop_get_object_data(
                _entry.tipo,
                _entry.id
            );


        if (is_undefined(_data))
        {
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

            exit;
        }


        var _price =
            scr_shop_get_buy_price(
                _entry.tipo,
                _entry.id
            );


        // ---------------------------------------------
        // DINERO INSUFICIENTE
        // ---------------------------------------------

        if (
            scr_shop_get_money()
            <
            _price
        )
        {
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


            shop_message =
                scr_loc(
                    scr_loc_src(
                        "* No tienes suficientes Sueños."
                    )
                );

            shop_message_timer =
                120;

            exit;
        }


        // ---------------------------------------------
        // INTENTAR AÑADIR
        // ---------------------------------------------

        if (
            !scr_shop_inventory_add(
                _entry.tipo,
                _entry.id
            )
        )
        {
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


            shop_message =
                scr_loc(
                    scr_loc_src(
                        "* No tienes espacio en el inventario."
                    )
                );

            shop_message_timer =
                120;

            exit;
        }


        // ---------------------------------------------
        // COBRAR
        // ---------------------------------------------

        scr_shop_spend_money(
            _price
        );


        audio_play_sound(
            snd_shineselect,
            10,
            false
        );


        shop_message =
            scr_locf(
                scr_loc_src(
                    "* Compraste {item}."
                ),
                {
                    item:
                        scr_loc(_data.nombre)
                }
            );

        // 30 frames = 1 segundo a 30 FPS.
        shop_message_timer =
            30;
    }


    exit;
}


// =========================================================
// VENDER - ELEGIR TIPO
// =========================================================

if (state == SHOP_SELL_TYPE)
{
    var _count =
        array_length(sell_type_options);


    if (_up)
    {
        sell_type_index =
            max(
                0,
                sell_type_index - 1
            );

        audio_play_sound(
            snd_menumove,
            10,
            false
        );
    }


    if (_down)
    {
        sell_type_index =
            min(
                _count - 1,
                sell_type_index + 1
            );

        audio_play_sound(
            snd_menumove,
            10,
            false
        );
    }


    if (_confirm)
    {
        var _candidate_category =
            sell_type_keys[
                sell_type_index
            ];


        var _candidate_list =
            scr_shop_build_sell_list(
                _candidate_category
            );


        // -------------------------------------------------
        // CATEGORÍA VACÍA
        // -------------------------------------------------
        //
        // No entramos a una lista vacía.
        // Permanecemos en el selector y suena snd_error.
        // -------------------------------------------------

        if (
            array_length(
                _candidate_list
            )
            <=
            0
        )
        {
            if (
                audio_is_playing(
                    snd_error
                )
            )
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


            exit;
        }


        sell_category =
            _candidate_category;

        sell_list =
            _candidate_list;

        sell_index =
            0;

        sell_scroll =
            0;

        state =
            SHOP_SELL;

        audio_play_sound(
            snd_menumove,
            10,
            false
        );
    }


    exit;
}


// =========================================================
// VENDER
// =========================================================

if (state == SHOP_SELL)
{
    // =====================================================
    // VALIDAR CATEGORÍA ACTUAL
    // =====================================================

    if (
        sell_category != "item"
        &&
        sell_category != "toy"
        &&
        sell_category != "arma"
        &&
        sell_category != "armadura"
    )
    {
        sell_category =
            "item";

        sell_type_index =
            0;

        sell_index =
            0;

        sell_scroll =
            0;

        state =
            SHOP_SELL_TYPE;

        exit;
    }


    // Reconstruimos SOLAMENTE la categoría seleccionada.
    sell_list =
        scr_shop_build_sell_list(
            sell_category
        );


    var _count =
        array_length(sell_list);


    if (_count <= 0)
    {
        sell_index =
            0;

        sell_scroll =
            0;


        if (_confirm)
        {
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
        }

        exit;
    }


    sell_index =
        clamp(
            sell_index,
            0,
            _count - 1
        );


    // -----------------------------------------------------
    // NAVEGACIÓN
    // -----------------------------------------------------

    if (_up)
    {
        sell_index =
            max(
                0,
                sell_index - 1
            );

        audio_play_sound(
            snd_menumove,
            10,
            false
        );
    }


    if (_down)
    {
        sell_index =
            min(
                _count - 1,
                sell_index + 1
            );

        audio_play_sound(
            snd_menumove,
            10,
            false
        );
    }


    if (sell_index < sell_scroll)
    {
        sell_scroll =
            sell_index;
    }


    if (
        sell_index
        >=
        sell_scroll + visible_rows
    )
    {
        sell_scroll =
            sell_index
            -
            visible_rows
            +
            1;
    }


    // -----------------------------------------------------
    // VENDER UNA UNIDAD
    // -----------------------------------------------------

    if (_confirm)
    {
        var _entry =
            sell_list[
                sell_index
            ];


        var _data =
            scr_shop_get_object_data(
                _entry.tipo,
                _entry.id
            );


        if (is_undefined(_data))
        {
            exit;
        }


        var _price =
            scr_shop_get_sell_price(
                _entry.tipo,
                _entry.id
            );


        if (
            scr_shop_inventory_remove(
                _entry.tipo,
                _entry.id,
                _entry.slot
            )
        )
        {
            scr_shop_add_money(
                _price
            );


            audio_play_sound(
                snd_trashsave,
                10,
                false
            );


            shop_message =
                scr_locf(
                    scr_loc_src(
                        "* Vendiste {item}."
                    ),
                    {
                        item:
                            scr_loc(_data.nombre)
                    }
                );

            // -1 = persistente. Solo cambia al vender otra cosa
            // o al moverse a otra pestaña.
            shop_message_timer =
                -1;


            sell_list =
                scr_shop_build_sell_list(
                    sell_category
                );


            if (
                array_length(sell_list)
                > 0
            )
            {
                sell_index =
                    clamp(
                        sell_index,
                        0,
                        array_length(sell_list) - 1
                    );
            }
            else
            {
                sell_index =
                    0;

                sell_scroll =
                    0;
            }
        }
    }


    exit;
}


// =========================================================
// HABLAR - LISTA DE TEMAS
// =========================================================

if (state == SHOP_TALK)
{
    var _options =
        shop_data.talk_options;

    var _count =
        array_length(_options);


    if (_count <= 0)
    {
        exit;
    }


    if (_up)
    {
        talk_index =
            max(
                0,
                talk_index - 1
            );

        audio_play_sound(
            snd_menumove,
            10,
            false
        );
    }


    if (_down)
    {
        talk_index =
            min(
                _count - 1,
                talk_index + 1
            );

        audio_play_sound(
            snd_menumove,
            10,
            false
        );
    }


    if (_confirm)
    {
        talk_dialogues =
            _options[
                talk_index
            ].dialogos;


        talk_line_index =
            0;

        talk_char =
            0;

        talk_sound_timer =
            0;


        if (
            array_length(talk_dialogues)
            > 0
        )
        {
            state =
                SHOP_TALK_DIALOG;

            audio_play_sound(
                snd_menumove,
                10,
                false
            );
        }
    }


    exit;
}


// =========================================================
// TALK - DIÁLOGO
// =========================================================
//
// IMPORTANTE:
// ESTE DIÁLOGO SE DIBUJA EN LA MISMA CAJA DERECHA
// DONDE ESTABAN LAS OPCIONES DE HABLAR.
// =========================================================

if (state == SHOP_TALK_DIALOG)
{
    if (
        array_length(talk_dialogues)
        <= 0
    )
    {
        state =
            SHOP_TALK;

        exit;
    }


    talk_line_index =
        clamp(
            talk_line_index,
            0,
            array_length(talk_dialogues) - 1
        );


    var _line =
        talk_dialogues[
            talk_line_index
        ];


    var _text =
        scr_loc(
            _line.texto
        );


    var _len =
        string_length(
            _text
        );

    if (_fast_skip)
    {
        talk_char =
            _len;
    }


    // -----------------------------------------------------
    // TYPEWRITER
    // -----------------------------------------------------

    if (talk_char < _len)
    {
        talk_char =
            min(
                _len,
                talk_char + 1
            );


        if (talk_char > 0)
        {
            var _char =
                string_char_at(
                    _text,
                    talk_char
                );


            if (_char != " ")
            {
                talk_sound_timer++;


                if (
                    talk_sound_timer
                    >=
                    talk_sound_delay
                )
                {
                    talk_sound_timer =
                        0;


                    var _snd =
                        _line.sonido;


                    if (
                        _snd == noone
                        ||
                        is_undefined(_snd)
                    )
                    {
                        _snd =
                            shop_data.vendedor_sonido_default;
                    }


                    if (audio_exists(_snd))
                    {
                        audio_play_sound(
                            _snd,
                            1,
                            false
                        );
                    }
                }
            }
        }
    }


    // -----------------------------------------------------
    // CONFIRMAR
    // -----------------------------------------------------

    if (_confirm)
    {
        // Z / ENTER NUNCA completa la animación del texto.
        // Mientras la línea siga escribiéndose, se ignora.
        if (talk_char < _len)
        {
            exit;
        }


        if (
            talk_line_index
            <
            array_length(talk_dialogues) - 1
        )
        {
            talk_line_index++;

            talk_char =
                0;

            talk_sound_timer =
                0;

            exit;
        }


        state =
            SHOP_TALK;

        talk_char =
            0;

        exit;
    }


    // -----------------------------------------------------
    // X / SHIFT: SOLO COMPLETAR LA LÍNEA ACTUAL
    // -----------------------------------------------------
    //
    // Nunca avanza al siguiente diálogo ni sale de TALK.
    // Z / ENTER es el único input que avanza la cadena.
    // -----------------------------------------------------

    if (_back)
    {
        if (talk_char < _len)
        {
            talk_char =
                _len;

            talk_sound_timer =
                0;
        }

        exit;
    }
}


// =========================================================
// SALIR - DIÁLOGO DE DESPEDIDA
// =========================================================
//
// ESTE DIÁLOGO SE DIBUJA EN LA CAJA IZQUIERDA NORMAL.
// =========================================================

if (state == SHOP_EXIT_DIALOG)
{
    if (
        array_length(exit_dialogues)
        <= 0
    )
    {
        instance_destroy();
        exit;
    }


    exit_line_index =
        clamp(
            exit_line_index,
            0,
            array_length(exit_dialogues) - 1
        );


    var _line =
        exit_dialogues[
            exit_line_index
        ];


    var _text =
        scr_loc(
            _line.texto
        );


    var _len =
        string_length(
            _text
        );

    if (_fast_skip)
    {
        exit_char =
            _len;
    }


    // -----------------------------------------------------
    // TYPEWRITER
    // -----------------------------------------------------

    if (exit_char < _len)
    {
        exit_char =
            min(
                _len,
                exit_char + 1
            );


        if (exit_char > 0)
        {
            var _char =
                string_char_at(
                    _text,
                    exit_char
                );


            if (_char != " ")
            {
                exit_sound_timer++;


                if (
                    exit_sound_timer
                    >=
                    talk_sound_delay
                )
                {
                    exit_sound_timer =
                        0;


                    var _snd =
                        _line.sonido;


                    if (
                        _snd == noone
                        ||
                        is_undefined(_snd)
                    )
                    {
                        _snd =
                            shop_data.vendedor_sonido_default;
                    }


                    if (audio_exists(_snd))
                    {
                        audio_play_sound(
                            _snd,
                            1,
                            false
                        );
                    }
                }
            }
        }
    }


    // -----------------------------------------------------
    // X / SHIFT: SOLO COMPLETAR LA LÍNEA ACTUAL
    // -----------------------------------------------------

    if (_back)
    {
        if (exit_char < _len)
        {
            exit_char =
                _len;

            exit_sound_timer =
                0;
        }

        exit;
    }


    // -----------------------------------------------------
    // AVANZAR / SALIR - SOLO Z / ENTER
    // -----------------------------------------------------

    if (_confirm)
    {
        // Z / ENTER NUNCA completa la animación del texto.
        // Mientras la línea siga escribiéndose, se ignora.
        if (exit_char < _len)
        {
            exit;
        }


        // Siguiente línea de despedida.
        if (
            exit_line_index
            <
            array_length(exit_dialogues) - 1
        )
        {
            exit_line_index++;

            exit_char =
                0;

            exit_sound_timer =
                0;

            exit;
        }


        // =================================================
        // TERMINÓ LA DESPEDIDA
        // =================================================

        keyboard_clear(
            ord("Z")
        );

        keyboard_clear(
            vk_enter
        );


        // =================================================
        // RETORNO UNIVERSAL A LA HABITACIÓN ANTERIOR
        // =================================================

        if (!shop_return_to_entry())
        {
            // Fallback si la tienda se abrió sin entrar por
            // un obj_warp_block.
            if (
                shop_data.salida_room
                !=
                noone
            )
            {
                var _p =
                    instance_find(
                        obj_player,
                        0
                    );


                room_goto(
                    shop_data.salida_room
                );


                if (
                    _p != noone
                    &&
                    instance_exists(_p)
                )
                {
                    _p.x =
                        shop_data.salida_x;

                    _p.y =
                        shop_data.salida_y;


                    if (
                        variable_instance_exists(
                            _p,
                            "face"
                        )
                    )
                    {
                        _p.face =
                            shop_data.salida_face;
                    }
                }
            }

            instance_destroy();
        }


        // Con retorno universal dejamos vivo el controller hasta
        // el room_goto para que su Draw GUI pueda desvanecerse.
        exit;
    }
}

