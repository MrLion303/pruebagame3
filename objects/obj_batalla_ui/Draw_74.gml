/// =========================================================
/// OBJ_BATALLA_UI
/// DRAW GUI BEGIN - NUEVO
/// =========================================================
///
/// Hace que `*` tenga el mismo comportamiento que en el
/// textbox normal:
///
///     * Primera línea * Segunda línea
///
/// se muestra como:
///
///     * Primera línea
///     * Segunda línea
///
/// El primer `*` NO provoca salto.
///
/// Este evento prepara line_break_pos / char_x / char_y ANTES
/// del Draw GUI actual. Como deja setup = true, el Draw GUI
/// existente usa estas posiciones sin recalcularlas.
/// =========================================================


// Solo intervenir cuando el Draw GUI necesita recalcular texto.
if (setup == false)
{
    var _s_star =
        2;


    if (
        variable_global_exists(
            "font_main"
        )
    )
    {
        draw_set_font(
            global.font_main
        );
    }


    // =====================================================
    // MISMA LÓGICA DE MARGEN QUE EL DRAW GUI ACTUAL
    // =====================================================

    var _star_tiene_cabeza =
        false;


    if (
        head_visible
        &&
        head_sprite != noone
        &&
        sprite_exists(
            head_sprite
        )
        &&
        string_length(
            text_to_draw
        ) > 0
        &&
        draw_char > 0
        &&
        !en_seleccion_enemigo
        &&
        !en_menu_fight
        &&
        !en_modo_info
        &&
        !en_menu_inventario
    )
    {
        _star_tiene_cabeza =
            true;
    }


    var _star_left_margin =
        _star_tiene_cabeza
        ?
        (65 * _s_star)
        :
        (24 * _s_star);


    var _star_avail_width =
        _star_tiene_cabeza
        ?
        (200 * _s_star)
        :
        (250 * _s_star);


    // =====================================================
    // SETUP DEL TEXTO
    // =====================================================

    setup =
        true;


    text_length =
        string_length(
            text_to_draw
        );


    var _star_last_space =
        -1;


    var _star_line_start_char =
        1;


    line_break_num =
        0;


    // =====================================================
    // CALCULAR SALTOS
    // =====================================================

    for (
        var _star_c = 1;
        _star_c <= text_length;
        _star_c++
    )
    {
        var _star_char_current =
            string_char_at(
                text_to_draw,
                _star_c
            );


        // =================================================
        // ASTERISCO = NUEVO RENGLÓN AUTOMÁTICO
        // =================================================
        //
        // Igual que obj_textbox:
        //
        // - El primer carácter puede ser `*`.
        // - Cualquier `*` posterior empieza otro renglón.
        // - Si ya está justo después de un salto manual,
        //   no se agrega un salto duplicado.
        // =================================================

        if (
            _star_char_current == "*"
            &&
            _star_c > 1
        )
        {
            var _star_previous_char =
                string_char_at(
                    text_to_draw,
                    _star_c - 1
                );


            if (
                _star_previous_char
                !=
                "\n"
            )
            {
                line_break_pos[
                    line_break_num
                ] =
                    _star_c;


                line_break_num++;


                _star_line_start_char =
                    _star_c;


                _star_last_space =
                    -1;
            }
        }


        if (
            _star_char_current
            ==
            " "
        )
        {
            _star_last_space =
                _star_c;
        }


        var _star_sub_str =
            string_copy(
                text_to_draw,
                _star_line_start_char,
                _star_c
                -
                _star_line_start_char
                +
                1
            );


        var _star_str_w =
            string_width(
                _star_sub_str
            );


        // =================================================
        // WRAP NORMAL POR ANCHO
        // =================================================

        if (
            _star_str_w
            >
            _star_avail_width
        )
        {
            if (
                _star_last_space
                !=
                -1
                &&
                _star_last_space
                >=
                _star_line_start_char
            )
            {
                line_break_pos[
                    line_break_num
                ] =
                    _star_last_space
                    +
                    1;


                line_break_num++;


                _star_line_start_char =
                    _star_last_space
                    +
                    1;


                _star_last_space =
                    -1;
            }
            else
            {
                line_break_pos[
                    line_break_num
                ] =
                    _star_c;


                line_break_num++;


                _star_line_start_char =
                    _star_c;


                _star_last_space =
                    -1;
            }
        }
    }


    // =====================================================
    // POSICIÓN DE CADA CARÁCTER
    // =====================================================

    for (
        var _star_c2 = 0;
        _star_c2 < text_length;
        _star_c2++
    )
    {
        var _star_char_pos =
            _star_c2
            +
            1;


        char_array[
            _star_c2
        ] =
            string_char_at(
                text_to_draw,
                _star_char_pos
            );


        var _star_txt_x =
            (14 * _s_star)
            +
            _star_left_margin;


        var _star_txt_y =
            (125 * _s_star)
            +
            (8 * _s_star)
            +
            (1 * _s_star);


        var _star_txt_line =
            0;


        var _star_line_start_pos =
            1;


        for (
            var _star_lb = 0;
            _star_lb < line_break_num;
            _star_lb++
        )
        {
            if (
                _star_char_pos
                >=
                line_break_pos[
                    _star_lb
                ]
            )
            {
                _star_txt_line =
                    _star_lb
                    +
                    1;


                _star_line_start_pos =
                    line_break_pos[
                        _star_lb
                    ];
            }
        }


        // Igual que el sistema actual:
        // ocultar el espacio que cae justo al inicio de línea.
        if (
            _star_line_start_pos
            ==
            _star_char_pos
            &&
            char_array[
                _star_c2
            ]
            ==
            " "
        )
        {
            char_x[
                _star_c2
            ] =
                -9999;


            char_y[
                _star_c2
            ] =
                -9999;


            continue;
        }


        var _star_str_copy =
            string_copy(
                text_to_draw,
                _star_line_start_pos,
                _star_char_pos
                -
                _star_line_start_pos
                +
                1
            );


        var _star_current_txt_w =
            string_width(
                _star_str_copy
            );


        char_x[
            _star_c2
        ] =
            _star_txt_x
            +
            _star_current_txt_w
            -
            string_width(
                char_array[
                    _star_c2
                ]
            );


        char_y[
            _star_c2
        ] =
            _star_txt_y
            +
            (
                _star_txt_line
                *
                (18 * _s_star)
            );
    }
}
