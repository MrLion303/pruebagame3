// =========================================================
// OBJ_GAME
// DRAW GUI
// =========================================================



// =========================================================
// DEBUG F3
// =========================================================

if (mostrar_info)
{
    draw_set_alpha(1);
    draw_set_color(c_white);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);

    var jugador = instance_find(obj_player, 0);

    if (jugador != noone)
    {
        var _escala = 0.6;

        var _y = 20;
        var _espacio = 20;


        // =================================================
        // COORDENADAS
        // =================================================

        draw_text_transformed(
            20,
            _y,
            scr_loc("Jugador X: ") + string(jugador.x),
            _escala,
            _escala,
            0
        );

        _y += _espacio;


        draw_text_transformed(
            20,
            _y,
            scr_loc("Jugador Y: ") + string(jugador.y),
            _escala,
            _escala,
            0
        );

        _y += _espacio;


        // =================================================
        // ROOM
        // =================================================

        draw_text_transformed(
            20,
            _y,
            scr_loc("Room: ") + string(room_get_name(room)),
            _escala,
            _escala,
            0
        );

        _y += _espacio;


        // =================================================
        // FPS
        // =================================================

        draw_text_transformed(
            20,
            _y,
            scr_loc("FPS: ")
            +
            string(fps)
            +
            " / "
            +
            string(game_get_speed(gamespeed_fps)),
            _escala,
            _escala,
            0
        );

        _y += _espacio;


        // =================================================
        // IDIOMA
        // =================================================

        var _idioma_actual;

        if (scr_language_is_english())
        {
            _idioma_actual = "English";
        }
        else
        {
            _idioma_actual = "Español";
        }


        draw_text_transformed(
            20,
            _y,
            scr_loc("Idioma: ") + _idioma_actual,
            _escala,
            _escala,
            0
        );

        _y += _espacio;


        // =================================================
        // MÚSICA
        // =================================================

        var _musica_actual =
            scr_loc_src("Ninguna");


        for (var _i = 0; _i < 1000; _i++)
        {
            if (audio_exists(_i))
            {
                if (audio_is_playing(_i))
                {
                    var _nombre_audio =
                        audio_get_name(_i);


                    if (
                        string_starts_with(
                            _nombre_audio,
                            "mus_"
                        )
                    )
                    {
                        _musica_actual =
                            _nombre_audio;

                        break;
                    }
                }
            }
        }


        draw_text_transformed(
            20,
            _y,
            scr_loc("Musica: ")
            +
            scr_loc(_musica_actual),
            _escala,
            _escala,
            0
        );
    }
}



// =========================================================
// =========================================================
// INTERFAZ DEL COFRE
// =========================================================
// =========================================================

if (instance_exists(obj_cofre_ui))
{
    var _ui =
        instance_find(
            obj_cofre_ui,
            0
        );


    // =====================================================
    // CONFIGURACIÓN DE DIBUJO
    // =====================================================

    draw_set_alpha(1);
    draw_set_color(c_white);

    draw_set_halign(fa_left);
    draw_set_valign(fa_top);


    if (variable_global_exists("font_main"))
    {
        draw_set_font(
            global.font_main
        );
    }


    // =====================================================
    // TAMAÑO GUI
    // =====================================================

    var _gw =
        display_get_gui_width();

    var _gh =
        display_get_gui_height();


    // =====================================================
    // OSCURECER EL JUEGO
    // =====================================================

    draw_set_alpha(0.55);
    draw_set_color(c_black);


    draw_rectangle(
        0,
        0,
        _gw,
        _gh,
        false
    );


    draw_set_alpha(1);


    // =====================================================
    // MEDIDAS GENERALES
    // =====================================================

    var _margen = 16;
    var _separacion = 6;

    var _box_y = 14;

    var _box_h =
        _gh - 52;


    var _box_w =
        (
            _gw
            -
            (_margen * 2)
            -
            _separacion
        )
        /
        2;


    // =====================================================
    // INVENTARIO IZQUIERDO
    // =====================================================

    var _inv_x =
        _margen;


    // =====================================================
    // COFRE DERECHO
    // =====================================================

    var _cofre_x =
        _margen
        +
        _box_w
        +
        _separacion;


    // =====================================================
    // TEXTBOX INVENTARIO
    // =====================================================

    draw_set_color(c_white);


    draw_sprite_stretched(
        spr_textbox,
        0,
        _inv_x,
        _box_y,
        _box_w,
        _box_h
    );


    // =====================================================
    // TEXTBOX COFRE
    // =====================================================

    draw_sprite_stretched(
        spr_textbox,
        0,
        _cofre_x,
        _box_y,
        _box_w,
        _box_h
    );


    // =====================================================
    // TÍTULOS
    // =====================================================

    var _titulo_y =
        _box_y + 17;


    draw_set_halign(
        fa_center
    );


    // -----------------------------------------------------
    // INVENTARIO
    // -----------------------------------------------------

    var _color_titulo_inv =
        c_white;


    if (
        _ui.panel_actual == 0
        &&
        !_ui.transferencia_activa
    )
    {
        _color_titulo_inv =
            c_yellow;
    }


    draw_set_color(
        _color_titulo_inv
    );


    draw_text(
        _inv_x
        +
        (_box_w / 2),
        _titulo_y,
        scr_loc("Inventario")
    );


    // -----------------------------------------------------
    // COFRE / ELIGE UN ESPACIO
    // -----------------------------------------------------

    var _titulo_cofre =
        scr_loc("Cofre");


    if (_ui.transferencia_activa)
    {
        _titulo_cofre =
            scr_loc("Elige un espacio");
    }


    var _color_titulo_cofre =
        c_white;


    if (_ui.panel_actual == 1)
    {
        _color_titulo_cofre =
            c_yellow;
    }


    draw_set_color(
        _color_titulo_cofre
    );


    draw_text(
        _cofre_x
        +
        (_box_w / 2),
        _titulo_y,
        _titulo_cofre
    );


    draw_set_halign(
        fa_left
    );


    // =====================================================
    // LÍNEAS DE TÍTULO
    // =====================================================

    var _line_y =
        _box_y + 49;


    draw_set_color(
        c_white
    );


    draw_line(
        _inv_x + 22,
        _line_y,
        _inv_x + _box_w - 22,
        _line_y
    );


    draw_line(
        _cofre_x + 22,
        _line_y,
        _cofre_x + _box_w - 22,
        _line_y
    );


    // =====================================================
    // INVENTARIO ACTUAL
    // =====================================================

    var _inventario =
        scr_cofre_inventario_lista();


    var _total_inv =
        array_length(
            _inventario
        );


    // =====================================================
    // POSICIONES DE LISTAS
    // =====================================================

    var _lista_y =
        _box_y + 68;


    var _fila_h = 39;


    // =====================================================
    // =====================================================
    // INVENTARIO
    // =====================================================
    // =====================================================

    if (_total_inv <= 0)
    {
        draw_set_color(
            c_dkgray
        );


        draw_text_transformed(
            _inv_x + 25,
            _lista_y,
            scr_loc("Inventario vacío"),
            0.65,
            0.65,
            0
        );
    }
    else
    {
        var _fin_inv =
            min(
                _total_inv,
                _ui.inventario_scroll
                +
                _ui.filas_visibles
            );


        for (
            var i = _ui.inventario_scroll;
            i < _fin_inv;
            i++
        )
        {
            // -------------------------------------------------
            // FILA
            // -------------------------------------------------

            var _fila =
                i
                -
                _ui.inventario_scroll;


            var _fy =
                _lista_y
                +
                (_fila * _fila_h);


            var _entrada_inv =
                _inventario[i];


            // -------------------------------------------------
            // ENTRADA VISUAL
            // -------------------------------------------------

            var _entrada_visual =
            {
                tipo:
                    _entrada_inv.tipo,

                key:
                    _entrada_inv.key
            };


            // -------------------------------------------------
            // SELECCIÓN
            // -------------------------------------------------

            var _seleccionado_inv =
                false;


            // Navegación normal.
            if (
                !_ui.transferencia_activa
                &&
                _ui.panel_actual == 0
                &&
                _ui.inventario_index == i
            )
            {
                _seleccionado_inv =
                    true;
            }


            // Mientras elegimos slot en el cofre,
            // el objeto seleccionado permanece amarillo.
            if (
                _ui.transferencia_activa
                &&
                _ui.transfer_inv_index == i
            )
            {
                _seleccionado_inv =
                    true;
            }


            // =================================================
            // NOMBRE
            // =================================================
            //
            // Ya NO dibujamos ">" al lado.
            // La selección se indica únicamente en amarillo.
            // =================================================

            draw_set_color(
                _seleccionado_inv
                ?
                c_yellow
                :
                c_white
            );


            var _nombre_inv =
                scr_cofre_item_nombre(
                    _entrada_visual
                );


            draw_text_transformed(
                _inv_x + 25,
                _fy,
                _nombre_inv,
                0.65,
                0.65,
                0
            );


            // =================================================
            // TIPO
            // =================================================

            draw_set_halign(
                fa_right
            );


            draw_set_color(
                _seleccionado_inv
                ?
                c_yellow
                :
                c_gray
            );


            draw_text_transformed(
                _inv_x + _box_w - 25,
                _fy + 2,
                scr_cofre_tipo_nombre(
                    _entrada_inv.tipo
                ),
                0.45,
                0.45,
                0
            );


            draw_set_halign(
                fa_left
            );


            // =================================================
            // SEPARADOR
            // =================================================

            draw_set_color(
                c_dkgray
            );


            draw_line(
                _inv_x + 25,
                _fy + 26,
                _inv_x + _box_w - 25,
                _fy + 26
            );
        }
    }


    // =====================================================
    // SCROLL INVENTARIO
    // =====================================================

    if (_total_inv > _ui.filas_visibles)
    {
        var _barra_inv_x =
            _inv_x
            +
            _box_w
            -
            12;


        var _barra_inv_y =
            _lista_y;


        var _barra_inv_h =
            (_ui.filas_visibles * _fila_h)
            -
            14;


        draw_set_color(
            c_dkgray
        );


        draw_line(
            _barra_inv_x,
            _barra_inv_y,
            _barra_inv_x,
            _barra_inv_y + _barra_inv_h
        );


        var _max_scroll_inv =
            max(
                1,
                _total_inv
                -
                _ui.filas_visibles
            );


        var _ratio_inv =
            _ui.inventario_scroll
            /
            _max_scroll_inv;


        var _punto_inv_y =
            _barra_inv_y
            +
            (_ratio_inv * _barra_inv_h);


        draw_set_color(
            c_white
        );


        draw_rectangle(
            _barra_inv_x - 2,
            _punto_inv_y - 3,
            _barra_inv_x + 2,
            _punto_inv_y + 3,
            false
        );
    }


    // =====================================================
    // =====================================================
    // COFRE
    // =====================================================
    // =====================================================

    var _inicio_cofre =
        _ui.cofre_scroll;


    var _fin_cofre =
        min(
            50,
            _inicio_cofre
            +
            _ui.filas_visibles
        );


    for (
        var i = _inicio_cofre;
        i < _fin_cofre;
        i++
    )
    {
        // -------------------------------------------------
        // FILA
        // -------------------------------------------------

        var _fila =
            i
            -
            _inicio_cofre;


        var _fy =
            _lista_y
            +
            (_fila * _fila_h);


        var _entrada_cofre =
            global.chest_data[i];


        // -------------------------------------------------
        // SELECCIONADO
        // -------------------------------------------------

        var _seleccionado_cofre =
            (
                _ui.panel_actual == 1
                &&
                _ui.cofre_index == i
            );


        // =================================================
        // CURSOR DEL COFRE
        // =================================================
        //
        // Este sí se mantiene porque indica claramente
        // qué slot estamos seleccionando.
        // =================================================

        if (_seleccionado_cofre)
        {
            draw_set_color(
                c_yellow
            );


            draw_text_transformed(
                _cofre_x + 18,
                _fy,
                ">",
                0.65,
                0.65,
                0
            );
        }


        // =================================================
        // NÚMERO DE SLOT
        // =================================================

        var _numero =
            string(i + 1);


        if (i + 1 < 10)
        {
            _numero =
                "0"
                +
                _numero;
        }


        draw_set_color(
            _seleccionado_cofre
            ?
            c_yellow
            :
            c_gray
        );


        draw_text_transformed(
            _cofre_x + 38,
            _fy + 2,
            _numero + ".",
            0.5,
            0.5,
            0
        );


        // =================================================
        // NOMBRE
        // =================================================

        var _nombre_cofre =
            "-----";


        if (is_struct(_entrada_cofre))
        {
            _nombre_cofre =
                scr_cofre_item_nombre(
                    _entrada_cofre
                );
        }


        var _color_item_cofre =
            c_dkgray;


        if (is_struct(_entrada_cofre))
        {
            _color_item_cofre =
                c_white;
        }


        if (_seleccionado_cofre)
        {
            _color_item_cofre =
                c_yellow;
        }


        draw_set_color(
            _color_item_cofre
        );


        draw_text_transformed(
            _cofre_x + 69,
            _fy,
            _nombre_cofre,
            0.65,
            0.65,
            0
        );


        // =================================================
        // INTERCAMBIAR
        // =================================================

        if (
            _ui.transferencia_activa
            &&
            _seleccionado_cofre
            &&
            is_struct(_entrada_cofre)
        )
        {
            draw_set_halign(
                fa_right
            );


            draw_set_color(
                c_yellow
            );


            draw_text_transformed(
                _cofre_x + _box_w - 25,
                _fy + 3,
                scr_loc("Intercambiar"),
                0.42,
                0.42,
                0
            );


            draw_set_halign(
                fa_left
            );
        }


        // =================================================
        // SEPARADOR
        // =================================================

        draw_set_color(
            c_dkgray
        );


        draw_line(
            _cofre_x + 25,
            _fy + 26,
            _cofre_x + _box_w - 25,
            _fy + 26
        );
    }


    // =====================================================
    // SCROLL COFRE
    // =====================================================

    var _barra_cofre_x =
        _cofre_x
        +
        _box_w
        -
        12;


    var _barra_cofre_y =
        _lista_y;


    var _barra_cofre_h =
        (_ui.filas_visibles * _fila_h)
        -
        14;


    draw_set_color(
        c_dkgray
    );


    draw_line(
        _barra_cofre_x,
        _barra_cofre_y,
        _barra_cofre_x,
        _barra_cofre_y + _barra_cofre_h
    );


    var _max_scroll_cofre =
        max(
            1,
            50
            -
            _ui.filas_visibles
        );


    var _ratio_cofre =
        _ui.cofre_scroll
        /
        _max_scroll_cofre;


    var _punto_cofre_y =
        _barra_cofre_y
        +
        (_ratio_cofre * _barra_cofre_h);


    draw_set_color(
        c_white
    );


    draw_rectangle(
        _barra_cofre_x - 2,
        _punto_cofre_y - 3,
        _barra_cofre_x + 2,
        _punto_cofre_y + 3,
        false
    );


    // =====================================================
    // CONTROLES INFERIORES
    // =====================================================
    //
    // Se eliminó completamente:
    //
    // "Guardando: Brillitos"
    // "Guardando: Manzana"
    // etc.
    //
    // =====================================================

    var _controles = "";


    // -----------------------------------------------------
    // ELIGIENDO SLOT
    // -----------------------------------------------------

    if (_ui.transferencia_activa)
    {
        _controles =
            scr_loc(
                "↑ ↓ Elegir espacio   Z Guardar / Intercambiar   X Cancelar"
            );
    }


    // -----------------------------------------------------
    // INVENTARIO
    // -----------------------------------------------------

    else if (_ui.panel_actual == 0)
    {
        _controles =
            scr_loc(
                "↑ ↓ Elegir objeto   Z Seleccionar   → Cofre   X Cerrar"
            );
    }


    // -----------------------------------------------------
    // COFRE
    // -----------------------------------------------------

    else
    {
        _controles =
            scr_loc(
                "↑ ↓ Elegir espacio   Z Sacar   ← Inventario   X Cerrar"
            );
    }


    draw_set_halign(
        fa_center
    );


    draw_set_color(
        c_ltgray
    );


    draw_text_transformed(
        _gw / 2,
        _gh - 27,
        _controles,
        0.48,
        0.48,
        0
    );


    // =====================================================
    // RESTAURAR
    // =====================================================

    draw_set_halign(
        fa_left
    );

    draw_set_valign(
        fa_top
    );

    draw_set_alpha(
        1
    );

    draw_set_color(
        c_white
    );
}