// =========================================================
// OBJ_SAVE_MENU
// DRAW GUI
// =========================================================


if (variable_global_exists("font_main"))
{
    draw_set_font(
        global.font_main
    );
}


draw_set_halign(
    fa_left
);

draw_set_alpha(1);

draw_set_color(
    c_white
);


// =========================================================
// DIBUJAR INTERFAZ
// =========================================================

if (mostrar_interfaz)
{
    var left_x = 64;
    var left_y = 64;
    var left_w = 140;
    var left_h = 160;


    var right_x =
        left_x + left_w + 16;

    var right_y = 64;

    var right_w = 340;
    var right_h = 80;

    var spacing = 10;


    // =====================================================
    // FONDO PRINCIPAL
    // =====================================================

    var bg_padding = 24;

    var bg_x =
        left_x - bg_padding;

    var bg_y =
        left_y - bg_padding;

    var bg_w =
        (right_x + right_w + bg_padding)
        - bg_x;

    var bg_h =
        (
            right_y
            + (3 * right_h)
            + (2 * spacing)
            + bg_padding
        )
        - bg_y;


    draw_sprite_stretched(
        spr_textbox_save_fondo,
        0,
        bg_x,
        bg_y,
        bg_w,
        bg_h
    );


    // =====================================================
    // CAJA DE ACCIONES
    // =====================================================

    draw_sprite_stretched(
        spr_textbox_save,
        0,
        left_x,
        left_y,
        left_w,
        left_h
    );


    for (var i = 0; i < 3; i++)
    {
        var _col =
            c_white;


        if (from_title && i == 0)
        {
            _col =
                c_dkgray;
        }
        else if (
            !guardado_confirmado
            &&
            state == 0
            &&
            action_index == i
        )
        {
            _col =
                c_yellow;
        }


        draw_set_color(
            _col
        );


        draw_text(
            left_x + 20,
            left_y + 20 + (i * 45),
            scr_loc(
                action_options[i]
            )
        );
    }


    // =====================================================
    // SLOTS
    // =====================================================

    for (var j = 0; j < 3; j++)
    {
        var _box_y =
            right_y
            +
            (
                j
                *
                (right_h + spacing)
            );


        draw_sprite_stretched(
            spr_textbox_save,
            0,
            right_x,
            _box_y,
            right_w,
            right_h
        );


        var _slot_seleccionado =
            (
                state == 1
                &&
                slot_index == j
            );


        var _slot_guardado =
            (
                guardado_confirmado
                &&
                guardado_slot == j
            );


        var _col_slot =
            _slot_seleccionado
            ?
            c_yellow
            :
            c_white;


        var _datos =
            slots_data[j];


        // =================================================
        // NOMBRE
        // =================================================

        draw_set_halign(
            fa_left
        );


        if (_slot_guardado)
        {
            draw_set_color(
                c_yellow
            );


            draw_text(
                right_x + 16,
                _box_y + 10,
                scr_loc(
                    "Partida salvada"
                )
            );
        }
        else
        {
            draw_set_color(
                _col_slot
            );


            draw_text(
                right_x + 16,
                _box_y + 10,
                _datos.nombre
            );
        }


        // =================================================
        // TIEMPO
        // =================================================

        draw_set_halign(
            fa_right
        );


        draw_set_color(
            _col_slot
        );


        draw_text(
            right_x + right_w - 16,
            _box_y + 10,
            _datos.tiempo
        );


        // =================================================
        // LÍNEA
        // =================================================

        draw_set_color(
            c_dkgray
        );


        draw_line_width(
            right_x + 16,
            _box_y + 40,
            right_x + right_w - 16,
            _box_y + 40,
            2
        );


        // =================================================
        // LUGAR
        // =================================================

        draw_set_halign(
            fa_left
        );


        draw_set_color(
            _col_slot
        );


        draw_text(
            right_x + 16,
            _box_y + 45,
            scr_loc(
                _datos.lugar
            )
        );
    }
}


// =========================================================
// TRANSICIÓN
// =========================================================
//
// ESTA ES LA ÚLTIMA COSA QUE SE DIBUJA.
//
// Como sabemos que Draw GUI de obj_save_menu funciona,
// spr_transition obligatoriamente se dibuja por encima
// de su propio menú.
// =========================================================

if (transicion_activa)
{
    draw_set_color(
        c_white
    );

    draw_set_alpha(
        1
    );


    var _gui_w =
        display_get_gui_width();

    var _gui_h =
        display_get_gui_height();


    var _frames =
        sprite_get_number(
            spr_transition
        );


    var _frame = 0;

    var _alpha_transition = 1;


    // =====================================================
    // SPRITE CON VARIOS FRAMES
    // =====================================================

    if (_frames > 1)
    {
        _frame =
            floor(
                transicion_progreso
                *
                (_frames - 1)
            );


        _frame =
            clamp(
                _frame,
                0,
                _frames - 1
            );
    }


    // =====================================================
    // SPRITE DE UN SOLO FRAME
    // =====================================================
    //
    // Si spr_transition resulta ser una sola imagen,
    // hacemos el fade mediante alpha.
    //
    // Así también funciona.
    // =====================================================

    else
    {
        _frame = 0;

        _alpha_transition =
            transicion_progreso;
    }


    draw_sprite_stretched_ext(
        spr_transition,
        _frame,
        0,
        0,
        _gui_w,
        _gui_h,
        c_white,
        _alpha_transition
    );


    draw_set_alpha(
        1
    );
}


// =========================================================
// RESTAURAR
// =========================================================

draw_set_halign(
    fa_left
);

draw_set_color(
    c_white
);

draw_set_alpha(
    1
);
