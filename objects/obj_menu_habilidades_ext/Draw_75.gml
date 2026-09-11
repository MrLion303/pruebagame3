/// =========================================================
/// OBJ_MENU_HABILIDADES_EXT
/// DRAW GUI END - NUEVO
/// =========================================================
///
/// STAD / HABIL utiliza:
///
///     - la MISMA posición de pestañas que INV/EQUIP/CLAVE;
///     - el MISMO spr_textbox;
///     - el MISMO tamaño 346 x 44;
///     - la MISMA animación de subida;
///     - dos zonas simétricas.
///
/// STAD original lo sigue dibujando obj_menu_manager.
/// Cuando HABIL está activo, este evento cubre ese panel con
/// el panel de habilidades.
/// =========================================================

if (
    !instance_exists(
        obj_menu_manager
    )
)
{
    exit;
}


var _menu =
    instance_find(
        obj_menu_manager,
        0
    );


if (
    _menu == noone
    ||
    _menu.state
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
// POSICIÓN BASE
// =========================================================
//
// Valores EXACTOS del menú actual:
//
// m_x = 80
// m_y = 80
// m_w = 130
//
// panel:
// x = 222
// y = 80
//
// pestañas:
// x = 222
// y final = 28
// y oculta = 88
// w = 346
// h = 44
// =========================================================

var _platform_shift =
    0;


// En plataformero el menú normal se mueve 80 px a la izquierda.
// Al llegar aquí la matriz del manager ya fue restaurada,
// así que aplicamos el mismo desplazamiento directamente.
if (
    variable_global_exists(
        "platformer_active"
    )
    &&
    global.platformer_active
)
{
    _platform_shift =
        -80;
}


var _panel_x =
    222
    +
    _platform_shift;

var _panel_y =
    80;

var _panel_w =
    346;

var _panel_h =
    363;


// =========================================================
// PESTAÑAS: MISMA ANIMACIÓN QUE INVENTARIO
// =========================================================

var _tab_t =
    1
    -
    power(
        1 - stad_tab_slide,
        3
    );


var _tab_x =
    _panel_x;

var _tab_final_y =
    28;

var _tab_hidden_y =
    88;

var _tab_y =
    lerp(
        _tab_hidden_y,
        _tab_final_y,
        _tab_t
    );

var _tab_w =
    346;

var _tab_h =
    44;


draw_sprite_stretched(
    spr_textbox,
    scr_ui_box_frame(
        spr_textbox
    ),
    _tab_x,
    _tab_y,
    _tab_w,
    _tab_h
);


var _tab_names =
[
    scr_loc_src(
        "STAD"
    ),

    scr_loc_src(
        "HABIL"
    )
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


    // Igual que el foco amarillo de las pestañas del inventario.
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


    draw_set_color(
        (_i == stad_tab)
        ?
        c_yellow
        :
        c_orange
    );


    draw_set_halign(
        fa_center
    );


    // +8: mismo ajuste vertical que tus pestañas actuales.
    draw_text(
        (_left + _right)
        *
        0.5,
        _tab_y + 8,
        scr_loc(
            _tab_names[
                _i
            ]
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
// El panel original ya está dibujado debajo.
// =========================================================

if (stad_tab == 0)
{
    exit;
}


// =========================================================
// HABIL - PANEL
// =========================================================

draw_sprite_stretched(
    spr_textbox,
    scr_ui_box_frame(
        spr_textbox
    ),
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


        var _ability_id =
            _lista[
                _idx
            ];


        var _data =
            scr_habilidad_data(
                _ability_id
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
            _data.icono
            !=
            -1
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
    habil_info_id
    !=
    ""
)
{
    var _data_info =
        scr_habilidad_data(
            habil_info_id
        );


    var _info_name =
        scr_loc(
            _data_info.nombre
        );


    var _info_desc =
        scr_loc(
            _data_info.descripcion
        );


    // La descripción original de Dash todavía decía que
    // necesitaba los zapatos. Con la corrección OR, mostrar
    // información correcta aunque no reescribamos el script.
    if (
        habil_info_id
        ==
        "dash"
    )
    {
        _info_desc =
            scr_loc(
                "Permite hacer dash dentro del rango de peligro. Funciona si tienes la habilidad Dash o si llevas los Zapatos Rápidos."
            );
    }


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


    // Oscurecer solo el contenido del panel detrás.
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
        scr_ui_box_frame(
            spr_textbox
        ),
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
        _info_name
    );


    draw_set_color(
        c_white
    );


    draw_text_ext(
        _box_x + 18,
        _box_y + 50,
        _info_desc,
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
