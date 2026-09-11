/// =========================================================
/// OBJ_MENU_HABILIDADES_EXT
/// DRAW GUI - NUEVO
/// =========================================================

if (
    !instance_exists(obj_menu_manager)
    ||
    obj_menu_manager.state
    !=
    MENU_STATE.INFO_MENU
)
{
    exit;
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


// =========================================================
// MISMAS MEDIDAS DEL STAD ACTUAL
// =========================================================

var _gui_x =
    64;

var _gui_y =
    64;

var _m_x =
    _gui_x + 16;

var _m_y =
    _gui_y + 16;

var _m_w =
    130;

var _m_h =
    308;


var _panel_x =
    _m_x
    +
    _m_w
    +
    12;

var _panel_y =
    _m_y;

var _panel_w =
    346;

var _panel_h =
    _m_h
    +
    55;


// =========================================================
// PESTAÑAS STAD / HABIL
// =========================================================

var _tab_x =
    _panel_x;

var _tab_y =
    _panel_y
    -
    52;

var _tab_w =
    _panel_w;

var _tab_h =
    44;


draw_sprite_stretched(
    spr_textbox,
    scr_ui_box_frame(spr_textbox),
    _tab_x,
    _tab_y,
    _tab_w,
    _tab_h
);


var _tab_names =
[
    scr_loc_src("STAD"),
    scr_loc_src("HABIL")
];


var _slot_w =
    _tab_w
    /
    2;


for (
    var _i = 0;
    _i < 2;
    _i++
)
{
    var _left =
        _tab_x
        +
        (_i * _slot_w);


    var _right =
        _left
        +
        _slot_w;


    if (_i == stad_tab)
    {
        draw_set_color(
            c_yellow
        );


        draw_rectangle(
            _left + 6,
            _tab_y + 7,
            _right - 6,
            _tab_y + 36,
            true
        );
    }


    draw_set_halign(
        fa_center
    );


    draw_set_color(
        (_i == stad_tab)
        ?
        c_yellow
        :
        c_orange
    );


    draw_text(
        (_left + _right) * 0.5,
        _tab_y + 11,
        scr_loc(
            _tab_names[_i]
        )
    );
}


draw_set_halign(
    fa_left
);


draw_set_color(
    c_white
);


// =========================================================
// STAD
// =========================================================
//
// El panel STAD original ya lo dibuja obj_menu_manager.
// Solo añadimos las pestañas arriba.
// =========================================================

if (stad_tab == 0)
{
    exit;
}


// =========================================================
// HABIL
// =========================================================
//
// Cubrir el STAD original con la misma caja y dibujar encima
// la lista de habilidades obtenidas.
// =========================================================

draw_sprite_stretched(
    spr_textbox,
    scr_ui_box_frame(spr_textbox),
    _panel_x,
    _panel_y,
    _panel_w,
    _panel_h
);


var _lista =
    scr_habilidades_lista_obtenidas();


var _total =
    array_length(
        _lista
    );


var _start_x =
    _panel_x
    +
    18;

var _start_y =
    _panel_y
    +
    22;

var _row_h =
    56;

var _icon_size =
    36;


if (_total <= 0)
{
    draw_set_color(
        c_gray
    );


    draw_text(
        _start_x,
        _start_y,
        scr_loc(
            "Todavía no tienes habilidades."
        )
    );
}
else
{
    var _last =
        min(
            _total,
            habil_scroll
            +
            habil_visible_rows
        );


    for (
        var _idx = habil_scroll;
        _idx < _last;
        _idx++
    )
    {
        var _row =
            _idx
            -
            habil_scroll;


        var _row_y =
            _start_y
            +
            (_row * _row_h);


        var _selected =
            (_idx == habil_index);


        var _id =
            _lista[
                _idx
            ];


        var _data =
            scr_habilidad_data(
                _id
            );


        // ---------------------------------------------
        // SELECCIÓN
        // ---------------------------------------------

        if (_selected)
        {
            draw_set_color(
                c_yellow
            );


            draw_rectangle(
                _start_x - 6,
                _row_y - 5,
                _panel_x + _panel_w - 18,
                _row_y + 43,
                true
            );
        }


        // ---------------------------------------------
        // ESPACIO PARA SPRITE
        // ---------------------------------------------

        draw_set_color(
            _selected
            ?
            c_yellow
            :
            c_gray
        );


        draw_rectangle(
            _start_x,
            _row_y,
            _start_x + _icon_size,
            _row_y + _icon_size,
            true
        );


        if (
            variable_struct_exists(
                _data,
                "icono"
            )
            &&
            _data.icono != -1
            &&
            sprite_exists(
                _data.icono
            )
        )
        {
            var _sw =
                max(
                    1,
                    sprite_get_width(
                        _data.icono
                    )
                );


            var _sh =
                max(
                    1,
                    sprite_get_height(
                        _data.icono
                    )
                );


            var _fit =
                min(
                    (_icon_size - 6) / _sw,
                    (_icon_size - 6) / _sh
                );


            var _cx =
                _start_x
                +
                (_icon_size * 0.5);


            var _cy =
                _row_y
                +
                (_icon_size * 0.5);


            var _draw_x =
                _cx
                +
                (
                    sprite_get_xoffset(
                        _data.icono
                    )
                    -
                    (_sw * 0.5)
                )
                *
                _fit;


            var _draw_y =
                _cy
                +
                (
                    sprite_get_yoffset(
                        _data.icono
                    )
                    -
                    (_sh * 0.5)
                )
                *
                _fit;


            draw_sprite_ext(
                _data.icono,
                0,
                _draw_x,
                _draw_y,
                _fit,
                _fit,
                0,
                c_white,
                1
            );
        }


        // ---------------------------------------------
        // NOMBRE
        // ---------------------------------------------

        draw_set_color(
            _selected
            ?
            c_yellow
            :
            c_white
        );


        draw_text(
            _start_x
            +
            _icon_size
            +
            16,
            _row_y
            +
            7,
            scr_loc(
                _data.nombre
            )
        );
    }
}


// =========================================================
// CUADRO DE INFORMACIÓN
// =========================================================

if (
    habil_info_open
    &&
    habil_info_id != ""
)
{
    var _data_info =
        scr_habilidad_data(
            habil_info_id
        );


    var _box_w =
        _panel_w
        -
        28;


    var _box_h =
        150;


    var _box_x =
        _panel_x
        +
        14;


    var _box_y =
        _panel_y
        +
        (_panel_h * 0.5)
        -
        (_box_h * 0.5);


    // Sombra negra detrás para separar el diálogo de la lista.
    draw_set_alpha(
        0.72
    );


    draw_set_color(
        c_black
    );


    draw_rectangle(
        _panel_x,
        _panel_y,
        _panel_x + _panel_w,
        _panel_y + _panel_h,
        false
    );


    draw_set_alpha(
        1
    );


    draw_sprite_stretched(
        spr_textbox,
        scr_ui_box_frame(spr_textbox),
        _box_x,
        _box_y,
        _box_w,
        _box_h
    );


    draw_set_color(
        c_yellow
    );


    draw_text(
        _box_x + 18,
        _box_y + 16,
        scr_loc(
            _data_info.nombre
        )
    );


    draw_set_color(
        c_white
    );


    draw_text_ext(
        _box_x + 18,
        _box_y + 50,
        scr_loc(
            _data_info.descripcion
        ),
        20,
        _box_w - 36
    );


    draw_set_color(
        c_gray
    );


    draw_set_halign(
        fa_center
    );


    draw_text(
        _box_x + (_box_w * 0.5),
        _box_y + _box_h - 27,
        scr_loc(
            "Z / X - Cerrar"
        )
    );


    draw_set_halign(
        fa_left
    );
}


draw_set_color(
    c_white
);


draw_set_alpha(
    1
);
