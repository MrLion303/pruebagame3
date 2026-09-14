/// =========================================================
/// OBJ_HOJA_PROBLEMA_UI - DRAW GUI
/// =========================================================

if (
    !sheet_initialized
    ||
    is_undefined(
        sheet_config
    )
)
{
    exit;
}


var _gui_w =
    display_get_gui_width();


var _gui_h =
    display_get_gui_height();


var _cx =
    _gui_w
    *
    0.5;


var _cy =
    _gui_h
    *
    0.5;


var _panel_w =
    340;


var _panel_h =
    230;


var _interface_sprite =
    -1;


if (
    variable_struct_exists(
        sheet_config,
        "interface_sprite"
    )
)
{
    _interface_sprite =
        sheet_config.interface_sprite;
}


if (
    _interface_sprite != -1
    &&
    sprite_exists(
        _interface_sprite
    )
)
{
    _panel_w =
        max(
            _panel_w,
            sprite_get_width(
                _interface_sprite
            )
        );


    _panel_h =
        max(
            _panel_h,
            sprite_get_height(
                _interface_sprite
            )
        );
}


var _left =
    _cx
    -
    (_panel_w * 0.5);


var _top =
    _cy
    -
    (_panel_h * 0.5);


var _right =
    _left
    +
    _panel_w;


var _bottom =
    _top
    +
    _panel_h;


// =========================================================
// FONDO / SPRITE DE INTERFAZ
// =========================================================

if (
    _interface_sprite != -1
    &&
    sprite_exists(
        _interface_sprite
    )
)
{
    var _draw_x =
        _left
        +
        sprite_get_xoffset(
            _interface_sprite
        );


    var _draw_y =
        _top
        +
        sprite_get_yoffset(
            _interface_sprite
        );


    draw_sprite(
        _interface_sprite,
        0,
        _draw_x,
        _draw_y
    );
}
else
{
    draw_set_alpha(
        0.95
    );


    draw_set_color(
        c_black
    );


    draw_rectangle(
        _left,
        _top,
        _right,
        _bottom,
        false
    );


    draw_set_color(
        c_white
    );


    draw_rectangle(
        _left + 2,
        _top + 2,
        _right - 2,
        _bottom - 2,
        true
    );


    draw_set_alpha(
        1
    );
}


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


draw_set_halign(
    fa_left
);


draw_set_valign(
    fa_middle
);


// =========================================================
// PROBLEMAS
// =========================================================

var _row_start_y =
    _top
    +
    52;


var _row_gap =
    52;


for (
    var _i = 0;
    _i < problem_count;
    _i++
)
{
    var _problem =
        sheet_config.problems[
            _i
        ];


    var _row_y =
        _row_start_y
        +
        (_i * _row_gap);


    // Selección.
    if (_i == selected_problem)
    {
        draw_set_color(
            c_white
        );


        draw_text(
            _left + 15,
            _row_y,
            ">"
        );
    }


    // Número.
    draw_set_color(
        c_white
    );


    draw_text(
        _left + 32,
        _row_y,
        string(_i + 1)
        +
        "."
    );


    var _problem_x =
        _left
        +
        56;


    var _answer_box_right =
        _right
        -
        52;


    var _answer_box_left =
        _answer_box_right
        -
        58;


    // =====================================================
    // MATEMÁTICAS DE TEXTO
    // =====================================================

    if (_problem.type == "math")
    {
        draw_set_color(
            c_white
        );


        draw_text(
            _problem_x,
            _row_y,
            string(
                _problem.text
            )
        );
    }

    // =====================================================
    // FIGURAS
    // =====================================================

    else if (
        _problem.type == "figures"
    )
    {
        var _figures =
            _problem.figures;


        var _operators =
            _problem.operators;


        var _figure_count =
            min(
                3,
                array_length(
                    _figures
                )
            );


        var _fx =
            _problem_x
            +
            15;


        var _show_values =
            false;


        if (
            variable_struct_exists(
                _problem,
                "show_values"
            )
        )
        {
            _show_values =
                _problem.show_values;
        }


        for (
            var _f = 0;
            _f < _figure_count;
            _f++
        )
        {
            var _figure =
                _figures[_f];


            if (
                !scr_problem_sheet_draw_sprite_fit(
                    _figure.sprite,
                    _fx,
                    _row_y - 3,
                    28
                )
            )
            {
                draw_set_color(
                    c_white
                );


                draw_text(
                    _fx - 7,
                    _row_y,
                    "?"
                );
            }


            if (_show_values)
            {
                draw_set_halign(
                    fa_center
                );


                draw_set_valign(
                    fa_top
                );


                draw_set_color(
                    c_white
                );


                draw_text(
                    _fx,
                    _row_y + 13,
                    string(
                        _figure.value
                    )
                );


                draw_set_halign(
                    fa_left
                );


                draw_set_valign(
                    fa_middle
                );
            }


            _fx +=
                34;


            if (
                _f
                <
                _figure_count - 1
                &&
                _f
                <
                array_length(
                    _operators
                )
            )
            {
                draw_set_color(
                    c_white
                );


                draw_text(
                    _fx - 4,
                    _row_y,
                    string(
                        _operators[_f]
                    )
                );


                _fx +=
                    23;
            }
        }


        draw_set_color(
            c_white
        );


        draw_text(
            _fx - 4,
            _row_y,
            "="
        );
    }


    // =====================================================
    // CUADRO DE RESPUESTA
    // =====================================================

    draw_set_color(
        c_black
    );


    draw_rectangle(
        _answer_box_left,
        _row_y - 13,
        _answer_box_right,
        _row_y + 13,
        false
    );


    draw_set_color(
        c_white
    );


    draw_rectangle(
        _answer_box_left,
        _row_y - 13,
        _answer_box_right,
        _row_y + 13,
        true
    );


    draw_set_halign(
        fa_center
    );


    draw_set_valign(
        fa_middle
    );


    draw_text(
        (
            _answer_box_left
            +
            _answer_box_right
        )
        *
        0.5,
        _row_y,
        answer_texts[_i]
    );


    draw_set_halign(
        fa_left
    );


    // =====================================================
    // X / CHECK
    // =====================================================

    var _status =
        problem_status[_i];


    if (_status != 0)
    {
        var _status_sprite =
            -1;


        if (
            _status == 1
            &&
            variable_struct_exists(
                sheet_config,
                "correct_sprite"
            )
        )
        {
            _status_sprite =
                sheet_config.correct_sprite;
        }
        else if (
            _status == -1
            &&
            variable_struct_exists(
                sheet_config,
                "wrong_sprite"
            )
        )
        {
            _status_sprite =
                sheet_config.wrong_sprite;
        }


        if (
            !scr_problem_sheet_draw_sprite_fit(
                _status_sprite,
                _right - 25,
                _row_y,
                24
            )
        )
        {
            draw_set_color(
                c_white
            );


            draw_text(
                _right - 36,
                _row_y,
                (
                    _status == 1
                    ?
                    "OK"
                    :
                    "X"
                )
            );
        }
    }
}


// =========================================================
// AYUDA
// =========================================================

draw_set_halign(
    fa_center
);


draw_set_valign(
    fa_bottom
);


draw_set_color(
    c_white
);


draw_text(
    _cx,
    _bottom - 10,
    "↑/↓  Seleccionar     Z/Enter  Responder     X  Cerrar"
);


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
