/// =========================================================
/// OBJ_CONTROLS_MANAGER
/// DRAW GUI
/// =========================================================
///
/// Dibuja el contenido funcional de:
///
///     CONFIG -> Controles
///
/// sobre la antigua zona de "Proximamente...".
/// =========================================================


if (!instance_exists(obj_menu_manager))
{
    exit;
}


var _menu =
    instance_find(
        obj_menu_manager,
        0
    );


if (
    _menu.config_tab
    !=
    1
)
{
    exit;
}


if (
    _menu.state
    !=
    MENU_STATE.CONFIG_MENU

    &&

    _menu.state
    !=
    MENU_STATE.CONFIG_ACTION
)
{
    exit;
}


// =========================================================
// FUENTE
// =========================================================

if (variable_global_exists("font_main"))
{
    draw_set_font(
        global.font_main
    );
}


draw_set_alpha(
    1
);


draw_set_halign(
    fa_left
);


draw_set_valign(
    fa_top
);


// =========================================================
// MISMAS COORDENADAS DEL PANEL CONFIG ACTUAL
// =========================================================
//
// obj_menu_manager Draw GUI:
//
//     gui_x = 64
//     gui_y = 64
//
//     m_x = gui_x + 16
//     m_y = gui_y + 16
//     m_w = 130
//
//     cfg_box_x = m_x + m_w + 12
//     cfg_box_y = m_y
//     cfg_box_w = 346
//     cfg_box_h = 308
// =========================================================

var _cfg_x =
    222;


var _cfg_y =
    80;


var _cfg_w =
    346;


var _cfg_h =
    308;


// =========================================================
// TAPAR EL TEXTO ANTIGUO "PROXIMAMENTE..."
// =========================================================
//
// No tocamos los tabs General / Controles.
//
// Solo limpiamos el interior inferior de la ventana.
// =========================================================

draw_set_color(
    c_black
);


draw_rectangle(
    _cfg_x + 10,
    _cfg_y + 58,
    _cfg_x + _cfg_w - 10,
    _cfg_y + _cfg_h - 10,
    false
);


// =========================================================
// ENCABEZADOS
// =========================================================

var _left_x =
    _cfg_x + 24;


var _key_x =
    _cfg_x + 218;


var _header_y =
    _cfg_y + 67;


var _list_y =
    _cfg_y + 96;


var _line_h =
    31;


draw_set_color(
    c_ltgray
);


draw_text_transformed(
    _left_x,
    _header_y,
    "Funcion",
    0.72,
    0.72,
    0
);


draw_text_transformed(
    _key_x,
    _header_y,
    "Tecla",
    0.72,
    0.72,
    0
);


// =========================================================
// DATOS
// =========================================================

var _names =
[
    "Abajo",
    "Derecha",
    "Arriba",
    "Izquierda",
    "Confirmar",
    "Cancelar/Correr",
    "Menu",
    "Predeterminados"
];


var _total_rows =
    array_length(
        _names
    );


var _max_scroll =
    max(
        0,
        _total_rows
        -
        controls_visible_rows
    );


control_scroll =
    clamp(
        control_scroll,
        0,
        _max_scroll
    );


// =========================================================
// FILAS VISIBLES
// =========================================================

for (
    var _row = 0;
    _row < controls_visible_rows;
    _row++
)
{
    var _index =
        control_scroll
        +
        _row;


    if (_index >= _total_rows)
    {
        break;
    }


    var _y =
        _list_y
        +
        (
            _row
            *
            _line_h
        );


    var _selected =
    (
        _menu.state
        ==
        MENU_STATE.CONFIG_ACTION

        &&

        control_index
        ==
        _index
    );


    // -----------------------------------------------------
    // SELECTOR
    // -----------------------------------------------------

    if (_selected)
    {
        draw_set_color(
            c_yellow
        );


        draw_text_transformed(
            _left_x - 14,
            _y,
            ">",
            0.72,
            0.72,
            0
        );
    }


    // -----------------------------------------------------
    // NOMBRE DE FUNCION
    // -----------------------------------------------------

    draw_set_color(
        _selected
        ?
        c_yellow
        :
        c_white
    );


    draw_text_transformed(
        _left_x,
        _y,
        _names[_index],
        0.72,
        0.72,
        0
    );


    // -----------------------------------------------------
    // TECLA
    // -----------------------------------------------------

    var _key_text =
        "";


    if (_index < 7)
    {
        if (
            controls_listening
            &&
            control_index
            ==
            _index
        )
        {
            _key_text =
                "...";
        }
        else
        {
            _key_text =
                scr_controls_key_name(
                    scr_controls_get_key(
                        _index
                    )
                );
        }
    }
    else
    {
        _key_text =
            "Restaurar";
    }


    draw_set_color(
        _selected
        ?
        c_yellow
        :
        c_ltgray
    );


    draw_text_transformed(
        _key_x,
        _y,
        _key_text,
        0.72,
        0.72,
        0
    );
}


// =========================================================
// SCROLLBAR
// =========================================================

if (_max_scroll > 0)
{
    var _bar_x =
        _cfg_x
        +
        _cfg_w
        -
        22;


    var _bar_y =
        _list_y
        +
        2;


    var _bar_h =
        (
            controls_visible_rows
            *
            _line_h
        )
        -
        15;


    draw_set_color(
        c_dkgray
    );


    draw_line_width(
        _bar_x,
        _bar_y,
        _bar_x,
        _bar_y + _bar_h,
        2
    );


    var _thumb_y =
        _bar_y
        +
        (
            control_scroll
            /
            _max_scroll
        )
        *
        _bar_h;


    draw_set_color(
        c_white
    );


    draw_rectangle(
        _bar_x - 3,
        _thumb_y - 3,
        _bar_x + 3,
        _thumb_y + 3,
        false
    );
}


// =========================================================
// MENSAJE INFERIOR
// =========================================================

var _footer_y =
    _cfg_y
    +
    _cfg_h
    -
    28;


if (controls_listening)
{
    draw_set_color(
        c_yellow
    );


    draw_text_transformed(
        _left_x,
        _footer_y,
        "Pulsa una tecla...  ESC cancela",
        0.52,
        0.52,
        0
    );
}
else if (
    controls_message_timer > 0
    &&
    controls_message != ""
)
{
    draw_set_color(
        c_ltgray
    );


    draw_text_transformed(
        _left_x,
        _footer_y,
        controls_message,
        0.52,
        0.52,
        0
    );
}


draw_set_halign(
    fa_left
);


draw_set_valign(
    fa_top
);


draw_set_color(
    c_white
);


draw_set_alpha(
    1
);
