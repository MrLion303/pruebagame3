/// =========================================================
/// OBJ_TEXTBOX
/// DRAW END COMPLETO - NUEVO EVENTO
/// =========================================================
///
/// RETRATOS DE DIÁLOGOS NORMALES:
///
///     ANTES: izquierda
///     AHORA: derecha
///
/// IMPORTANTE:
///
/// - NO afecta la batalla BBS.
/// - No cambia la lógica del typewriter.
/// - No modifica permanentemente speaker_sprite.
/// - Redibuja la caja encima del Draw normal únicamente
///   cuando la página actual tiene retrato.
/// - Conserva colores y efectos de texto.
/// =========================================================


// =========================================================
// NO INTERVENIR EN BATALLA
// =========================================================

if (room == bbs)
{
    exit;
}


// =========================================================
// VALIDAR PÁGINA / RETRATO
// =========================================================

if (
    !variable_instance_exists(
        id,
        "speaker_sprite"
    )
    ||
    !is_array(
        speaker_sprite
    )
    ||
    page < 0
    ||
    page >= array_length(
        speaker_sprite
    )
)
{
    exit;
}


var _speaker =
    speaker_sprite[
        page
    ];


if (
    _speaker == noone
    ||
    _speaker < 0
    ||
    !sprite_exists(
        _speaker
    )
)
{
    exit;
}


// =========================================================
// REDIBUJAR FONDO DEL TEXTBOX
// =========================================================

draw_set_alpha(
    1
);


draw_set_color(
    c_black
);


draw_rectangle(
    textbox_x,
    textbox_y,
    textbox_x + textbox_width,
    textbox_y + textbox_height,
    false
);


var _current_txtb_spr =
    (
        page
        <
        array_length(
            txtb_spr
        )
        &&
        txtb_spr[
            page
        ]
        !=
        undefined
    )
    ?
    txtb_spr[
        page
    ]
    :
    spr_textbox;


var _txtb_w =
    max(
        1,
        sprite_get_width(
            _current_txtb_spr
        )
    );


var _txtb_h =
    max(
        1,
        sprite_get_height(
            _current_txtb_spr
        )
    );


draw_sprite_ext(
    _current_txtb_spr,
    scr_ui_box_frame(
        _current_txtb_spr
    ),
    textbox_x,
    textbox_y,
    textbox_width
    /
    _txtb_w,
    textbox_height
    /
    _txtb_h,
    0,
    c_white,
    1
);


// =========================================================
// RETRATO A LA DERECHA
// =========================================================

var _speaker_w =
    sprite_get_width(
        _speaker
    );


var _speaker_xoff =
    sprite_get_xoffset(
        _speaker
    );


var _speaker_right =
    textbox_x
    +
    textbox_width
    -
    border
    -
    4;


var _speaker_draw_x =
    _speaker_right
    -
    _speaker_w
    +
    _speaker_xoff;


var _speaker_draw_y =
    textbox_y
    +
    border
    +
    4;


draw_sprite(
    _speaker,
    0,
    _speaker_draw_x,
    _speaker_draw_y
);


// =========================================================
// TEXTO - ÁREA A LA IZQUIERDA DEL RETRATO
// =========================================================

draw_set_font(
    global.font_main
);


draw_set_valign(
    fa_top
);


draw_set_halign(
    fa_left
);


var _txt_scale =
    0.55;


var _text_left =
    textbox_x
    +
    border
    +
    10;


var _right_reserved =
    border
    +
    75;


var _text_width =
    max(
        20,
        textbox_width
        -
        (
            border
            +
            10
        )
        -
        _right_reserved
    );


var _page_text =
    text[
        page
    ];


var _len =
    string_length(
        _page_text
    );


var _breaks =
    [];


var _last_space =
    -1;


var _line_start_char =
    1;


// =========================================================
// CALCULAR WRAP
// =========================================================

for (
    var _c = 1;
    _c <= _len;
    _c++
)
{
    var _ch =
        string_char_at(
            _page_text,
            _c
        );


    if (_ch == "\n")
    {
        array_push(
            _breaks,
            _c + 1
        );


        _line_start_char =
            _c + 1;


        _last_space =
            -1;


        continue;
    }


    if (
        _ch == "*"
        &&
        _c > 1
    )
    {
        var _prev =
            string_char_at(
                _page_text,
                _c - 1
            );


        if (_prev != "\n")
        {
            array_push(
                _breaks,
                _c
            );


            _line_start_char =
                _c;


            _last_space =
                -1;
        }
    }


    if (_ch == " ")
    {
        _last_space =
            _c;
    }


    var _sub =
        string_copy(
            _page_text,
            _line_start_char,
            _c
            -
            _line_start_char
            +
            1
        );


    var _sub_w =
        string_width(
            _sub
        )
        *
        _txt_scale;


    if (_sub_w > _text_width)
    {
        if (
            _last_space != -1
            &&
            _last_space
            >=
            _line_start_char
        )
        {
            array_push(
                _breaks,
                _last_space + 1
            );


            _line_start_char =
                _last_space + 1;


            _last_space =
                -1;
        }
        else
        {
            array_push(
                _breaks,
                _c
            );


            _line_start_char =
                _c;


            _last_space =
                -1;
        }
    }
}


// =========================================================
// DIBUJAR CARACTERES VISIBLES
// =========================================================

var _visible_chars =
    clamp(
        floor(
            draw_char
        ),
        0,
        _len
    );


var _time =
    get_timer()
    /
    100000;


for (
    var _i = 0;
    _i < _visible_chars;
    _i++
)
{
    var _char_pos =
        _i + 1;


    var _char =
        string_char_at(
            _page_text,
            _char_pos
        );


    if (_char == "\n")
    {
        continue;
    }


    var _line =
        0;


    var _line_start =
        1;


    for (
        var _b = 0;
        _b < array_length(
            _breaks
        );
        _b++
    )
    {
        if (
            _char_pos
            >=
            _breaks[
                _b
            ]
        )
        {
            _line =
                _b + 1;


            _line_start =
                _breaks[
                    _b
                ];
        }
    }


    if (
        _line_start
        ==
        _char_pos
        &&
        _char
        ==
        " "
    )
    {
        continue;
    }


    var _line_text =
        string_copy(
            _page_text,
            _line_start,
            _char_pos
            -
            _line_start
            +
            1
        );


    var _draw_x =
        _text_left
        +
        (
            string_width(
                _line_text
            )
            *
            _txt_scale
        )
        -
        (
            string_width(
                _char
            )
            *
            _txt_scale
        );


    var _draw_y =
        textbox_y
        +
        border
        +
        (_line * 17);


    var _c1 =
        c_white;


    var _c2 =
        c_white;


    var _c3 =
        c_white;


    var _c4 =
        c_white;


    if (
        variable_instance_exists(
            id,
            "col_1"
        )
    )
    {
        try
        {
            _c1 =
                col_1[
                    _i,
                    page
                ];


            _c2 =
                col_2[
                    _i,
                    page
                ];


            _c3 =
                col_3[
                    _i,
                    page
                ];


            _c4 =
                col_4[
                    _i,
                    page
                ];
        }
        catch (_color_error)
        {
            _c1 =
                c_white;


            _c2 =
                c_white;


            _c3 =
                c_white;


            _c4 =
                c_white;
        }
    }


    var _effect =
        "none";


    if (
        variable_instance_exists(
            id,
            "text_effect"
        )
    )
    {
        try
        {
            _effect =
                text_effect[
                    _i,
                    page
                ];
        }
        catch (_effect_error)
        {
            _effect =
                "none";
        }
    }


    if (_effect == "shake")
    {
        _draw_x +=
            random_range(
                -1,
                1
            );


        _draw_y +=
            random_range(
                -1,
                1
            );
    }
    else if (_effect == "wave")
    {
        _draw_y +=
            sin(
                (_time + _i)
                *
                0.5
            )
            *
            3;
    }
    else if (_effect == "bounce")
    {
        _draw_y -=
            abs(
                sin(
                    (_time + _i)
                    *
                    0.8
                )
            )
            *
            4;
    }


    draw_text_transformed_color(
        _draw_x,
        _draw_y,
        _char,
        _txt_scale,
        _txt_scale,
        0,
        _c1,
        _c2,
        _c3,
        _c4,
        1
    );
}


// =========================================================
// OPCIONES
// =========================================================

if (
    variable_instance_exists(
        id,
        "option_number"
    )
    &&
    option_number > 0
    &&
    draw_char
    >=
    _len
    &&
    page
    ==
    page_number - 1
)
{
    var _op_scale =
        0.45;


    var _op_spacing =
        10;


    var _total_options_width =
        0;


    for (
        var _op_i = 0;
        _op_i < option_number;
        _op_i++
    )
    {
        _total_options_width +=
            (
                string_width(
                    option[
                        _op_i
                    ]
                )
                *
                _op_scale
            );


        if (
            _op_i
            <
            option_number - 1
        )
        {
            _total_options_width +=
                _op_spacing;
        }
    }


    var _start_x =
        textbox_x
        +
        (
            textbox_width
            -
            _total_options_width
        )
        /
        2;


    var _start_y =
        textbox_y
        +
        textbox_height
        -
        border
        -
        18;


    var _current_x =
        _start_x;


    for (
        var _op_i = 0;
        _op_i < option_number;
        _op_i++
    )
    {
        var _op_w =
            string_width(
                option[
                    _op_i
                ]
            )
            *
            _op_scale;


        if (
            option_pos
            ==
            _op_i
        )
        {
            draw_sprite_ext(
                spr_textbox_arrow,
                0,
                _current_x - 7,
                _start_y + 1,
                0.4,
                0.4,
                0,
                c_white,
                1
            );
        }


        draw_text_transformed(
            _current_x,
            _start_y,
            option[
                _op_i
            ],
            _op_scale,
            _op_scale,
            0
        );


        _current_x +=
            _op_w
            +
            _op_spacing;
    }
}


draw_set_alpha(
    1
);


draw_set_color(
    c_white
);


draw_set_halign(
    fa_left
);


draw_set_valign(
    fa_top
);
