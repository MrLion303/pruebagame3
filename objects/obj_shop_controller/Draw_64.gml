/// =========================================================
/// OBJ_SHOP_CONTROLLER
/// DRAW GUI COMPLETO
/// =========================================================
//
// DISEÑO:
//
// - vendedor grande a la izquierda
// - caja de diálogo normal debajo del vendedor
// - Sueños debajo
// - tabs a la derecha
// - lista/opciones TALK en caja derecha
// - los DIÁLOGOS DE TALK también usan esa misma caja derecha
// - despedida de SALIR usa la caja izquierda normal
//
// Todas las cajas usan shop_data.caja_sprite.
// El sprite puede cambiarse por tienda.
//
// Si el sprite tiene Nine Slice activado, GameMaker conserva
// correctamente los bordes al estirarlo.
// =========================================================

draw_set_font(
    global.font_main
);

draw_set_halign(
    fa_left
);

draw_set_valign(
    fa_top
);


// =========================================================
// TRANSICIÓN
// =========================================================
//
// La interfaz NO hace fade ni se oculta.
// obj_warp dibuja su mismo frame también en Draw GUI para
// quedar por encima de la tienda durante la transición.
// =========================================================

var _ui_alpha =
    1;

draw_set_alpha(
    1
);


// =========================================================
// TAMAÑO GUI
// =========================================================
//
// Sin fondo negro: el room queda visible por detrás.
// =========================================================

var _gw =
    display_get_gui_width();

var _gh =
    display_get_gui_height();


// =========================================================
// ESCALA GENERAL DE TEXTO DE LA TIENDA
// =========================================================
// 2 = el doble del tamaño anterior.
var _text_mul = 2;


// =========================================================
// COLORES
// =========================================================

var _divider =
    make_color_rgb(
        80,
        40,
        110
    );

var _selected =
    c_yellow;

var _normal =
    c_white;

var _muted =
    c_ltgray;


// =========================================================
// LAYOUT
// =========================================================

// Izquierda.
var _left_x =
    18;

var _left_w =
    210;


// Vendedor.
var _seller_y =
    18;

var _seller_h =
    205;


// Diálogo izquierdo.
var _dialog_y =
    232;

var _dialog_h =
    155;


// Dinero.
var _money_y =
    396;

var _money_h =
    65;


// Derecha.
var _right_x =
    238;

var _right_w =
    384;


// Menú superior.
var _tabs_y =
    18;

var _tabs_h =
    66;


// Lista / TALK.
var _list_y =
    94;

var _list_h =
    278;


// Info.
var _info_y =
    382;

var _info_h =
    79;


// =========================================================
// FONDO NEGRO EN TODO EXCEPTO LA CAJA DEL VENDEDOR
// =========================================================
//
// Toda la interfaz queda respaldada por negro, incluyendo
// las cajas de diálogo, dinero, tabs, lista e información.
//
// La ÚNICA zona donde dejamos ver el room por detrás es el
// rectángulo completo de la caja grande del vendedor.
// Así, si el Nine Slice de las demás cajas tiene partes
// transparentes, detrás de ellas se verá negro.
// =========================================================

draw_set_alpha(_ui_alpha);
draw_set_color(c_black);


// Arriba de la caja del vendedor.
draw_rectangle(
    0,
    0,
    _gw - 1,
    _seller_y - 1,
    false
);


// Debajo de la caja del vendedor.
draw_rectangle(
    0,
    _seller_y + _seller_h,
    _gw - 1,
    _gh - 1,
    false
);


// Franja izquierda, a la altura del vendedor.
draw_rectangle(
    0,
    _seller_y,
    _left_x - 1,
    _seller_y + _seller_h - 1,
    false
);


// Todo lo que está a la derecha de la caja del vendedor,
// también a esa misma altura.
draw_rectangle(
    _left_x + _left_w,
    _seller_y,
    _gw - 1,
    _seller_y + _seller_h - 1,
    false
);


// =========================================================
// CAJAS NINE SLICE
// =========================================================

var _box_sprite =
    shop_data.caja_sprite;


var _panels =
[
    {
        x:
            _left_x,

        y:
            _seller_y,

        w:
            _left_w,

        h:
            _seller_h
    },

    {
        x:
            _left_x,

        y:
            _dialog_y,

        w:
            _left_w,

        h:
            _dialog_h
    },

    {
        x:
            _left_x,

        y:
            _money_y,

        w:
            _left_w,

        h:
            _money_h
    },

    {
        x:
            _right_x,

        y:
            _tabs_y,

        w:
            _right_w,

        h:
            _tabs_h
    },

    {
        x:
            _right_x,

        y:
            _list_y,

        w:
            _right_w,

        h:
            _list_h
    },

    {
        x:
            _right_x,

        y:
            _info_y,

        w:
            _right_w,

        h:
            _info_h
    }
];


for (
    var _p = 0;
    _p < array_length(_panels);
    _p++
)
{
    var _panel =
        _panels[_p];


    if (
        _box_sprite != noone
        &&
        sprite_exists(_box_sprite)
    )
    {
        draw_sprite_stretched_ext(
            _box_sprite,
            scr_ui_box_frame(_box_sprite),
            _panel.x,
            _panel.y,
            _panel.w,
            _panel.h,
            c_white,
            _ui_alpha
        );
    }
    else
    {
        draw_set_color(
            c_white
        );

        draw_rectangle(
            _panel.x,
            _panel.y,
            _panel.x + _panel.w,
            _panel.y + _panel.h,
            true
        );
    }
}


// =========================================================
// VENDEDOR GRANDE
// =========================================================

if (
    shop_data.vendedor_sprite != noone
    &&
    sprite_exists(
        shop_data.vendedor_sprite
    )
)
{
    draw_sprite_stretched_ext(
        shop_data.vendedor_sprite,
        0,
        _left_x + 8,
        _seller_y + 8,
        _left_w - 16,
        _seller_h - 16,
        c_white,
        _ui_alpha
    );
}
else
{
    draw_set_color(
        _muted
    );

    draw_text_transformed(
        _left_x + 20,
        _seller_y + _seller_h - 46,
        scr_loc(
            scr_loc_src(
                "VENDEDOR\nSIN SPRITE"
            )
        ),
        0.225 * _text_mul,
        0.225 * _text_mul,
        0
    );
}


// =========================================================
// TABS SUPERIORES
// =========================================================

var _tab_w =
    _right_w / 4;

// Ajuste horizontal individual de cada texto:
// COMPRAR un poco, VENDER un poco más, HABLAR y SALIR también.
var _tab_text_offset_x =
[
    3,
    7,
    5,
    5
];


for (
    var _i = 0;
    _i < 4;
    _i++
)
{
    var _tx =
        _right_x
        +
        (_i * _tab_w);


    if (_i > 0)
    {
        draw_set_color(
            _divider
        );

        draw_line(
            _tx,
            _tabs_y + 12,
            _tx,
            _tabs_y + _tabs_h - 12
        );
    }


    var _active_tab =
        top_index;


    if (state == SHOP_BUY)
    {
        _active_tab =
            0;
    }
    else if (
        state == SHOP_SELL
        ||
        state == SHOP_SELL_TYPE
    )
    {
        _active_tab =
            1;
    }
    else if (
        state == SHOP_TALK
        ||
        state == SHOP_TALK_DIALOG
    )
    {
        _active_tab =
            2;
    }
    else if (state == SHOP_EXIT_DIALOG)
    {
        _active_tab =
            3;
    }


    draw_set_color(
        (_active_tab == _i)
        ?
        _selected
        :
        _normal
    );


    draw_text_transformed(
        _tx + 13 + _tab_text_offset_x[_i],
        _tabs_y + 20,
        scr_loc(
            top_options[_i]
        ),
        0.31 * _text_mul,
        0.31 * _text_mul,
        0
    );
}


// =========================================================
// DINERO + ESPACIOS
// =========================================================
//
// El dinero queda a la izquierda.
// Cuando hay un objeto REALMENTE seleccionado en COMPRAR o
// VENDER, la capacidad del inventario correspondiente aparece
// a la derecha de esta misma caja.
// =========================================================

var _money_space_text =
    "";

var _money_space_entry =
    undefined;

if (
    state == SHOP_BUY
    &&
    array_length(shop_data.items_venta) > 0
)
{
    _money_space_entry =
        shop_data.items_venta[buy_index];
}
else if (
    state == SHOP_SELL
    &&
    array_length(sell_list) > 0
)
{
    _money_space_entry =
        sell_list[sell_index];
}


if (!is_undefined(_money_space_entry))
{
    var _space_used =
        0;

    var _space_max =
        0;


    if (_money_space_entry.tipo == "item")
    {
        var _space_inv =
            global.inventory_data.consumibles;

        if (
            instance_exists(obj_player)
            &&
            variable_instance_exists(obj_player, "inventory")
        )
        {
            _space_inv =
                obj_player.inventory;
        }

        _space_max =
            array_length(_space_inv);

        for (var _si = 0; _si < _space_max; _si++)
        {
            if (
                _space_inv[_si] != -1
                &&
                !is_undefined(_space_inv[_si])
            )
            {
                _space_used++;
            }
        }
    }
    else if (_money_space_entry.tipo == "toy")
    {
        _space_max =
            array_length(global.toy_inventory);

        for (var _si = 0; _si < _space_max; _si++)
        {
            if (
                global.toy_inventory[_si] != -1
                &&
                !is_undefined(global.toy_inventory[_si])
            )
            {
                _space_used++;
            }
        }
    }
    else if (_money_space_entry.tipo == "equip")
    {
        _space_max =
            array_length(global.equipment_inventory);

        for (var _si = 0; _si < _space_max; _si++)
        {
            if (
                global.equipment_inventory[_si] != -1
                &&
                !is_undefined(global.equipment_inventory[_si])
            )
            {
                _space_used++;
            }
        }
    }


    _money_space_text =
        string(_space_used)
        +
        "/"
        +
        string(_space_max);
}


draw_set_color(
    c_white
);

draw_set_halign(
    fa_left
);


draw_text_transformed(
    _left_x + 16,
    _money_y + 20,
    "SO: $"
    +
    string(
        scr_shop_get_money()
    ),
    0.36 * _text_mul,
    0.36 * _text_mul,
    0
);


if (_money_space_text != "")
{
    draw_set_halign(
        fa_right
    );

    // Etiqueta y cantidad se dibujan por separado para garantizar
    // que la cantidad quede realmente en el renglón inferior.
    draw_text_transformed(
        _left_x + _left_w - 16,
        _money_y + 8,
        scr_loc(
            scr_loc_src("Espacio")
        ),
        0.25 * _text_mul,
        0.25 * _text_mul,
        0
    );

    draw_text_transformed(
        _left_x + _left_w - 16,
        _money_y + 34,
        _money_space_text,
        0.25 * _text_mul,
        0.25 * _text_mul,
        0
    );

    draw_set_halign(
        fa_left
    );
}


// =========================================================
// CAJA DE DIÁLOGO IZQUIERDA
// =========================================================
//
// Aquí aparecen:
//
// - mensaje_idle
// - mensajes de comprar/vender/error
// - despedida de SALIR
//
// Los diálogos de HABLAR NO aparecen aquí.
// =========================================================

var _left_dialog_head =
    shop_data.vendedor_cabeza_default;

var _left_dialog_color =
    shop_data.vendedor_color_default;

var _left_dialog_text =
    scr_loc(
        shop_data.mensaje_idle
    );

// Mientras HABLAR está reproduciendo una conversación,
// la caja izquierda queda vacía.
if (state == SHOP_TALK_DIALOG)
{
    _left_dialog_text =
        "";
}


// ---------------------------------------------------------
// MENSAJE TEMPORAL
// ---------------------------------------------------------

if (shop_message != "")
{
    _left_dialog_text =
        shop_message;

    _left_dialog_color =
        c_yellow;
}


// ---------------------------------------------------------
// DESPEDIDA
// ---------------------------------------------------------

if (
    state == SHOP_EXIT_DIALOG
    &&
    array_length(exit_dialogues) > 0
)
{
    var _exit_line =
        exit_dialogues[
            exit_line_index
        ];


    var _exit_full_text =
        scr_loc(
            _exit_line.texto
        );


    _left_dialog_text =
        string_copy(
            _exit_full_text,
            1,
            floor(exit_char)
        );


    _left_dialog_color =
        _exit_line.color;


    if (
        _left_dialog_color == noone
        ||
        is_undefined(_left_dialog_color)
    )
    {
        _left_dialog_color =
            shop_data.vendedor_color_default;
    }


    _left_dialog_head =
        _exit_line.cabeza;


    if (
        _left_dialog_head == noone
        ||
        is_undefined(_left_dialog_head)
    )
    {
        _left_dialog_head =
            shop_data.vendedor_cabeza_default;
    }
}


// ---------------------------------------------------------
// DIBUJAR CABEZA + TEXTO IZQUIERDO
// ---------------------------------------------------------

var _left_text_x =
    _left_x + 14;

var _left_text_width =
    _left_w - 28;


if (
    _left_dialog_head != noone
    &&
    sprite_exists(_left_dialog_head)
)
{
    draw_sprite_stretched_ext(
        _left_dialog_head,
        0,
        _left_x + 12,
        _dialog_y + 14,
        48,
        48,
        c_white,
        _ui_alpha
    );


    _left_text_x =
        _left_x + 68;

    _left_text_width =
        _left_w - 82;
}


draw_set_color(
    _left_dialog_color
);


// Escala y separación del cuadro pequeño.
// El ancho se calcula con el MISMO margen visual a izquierda
// y derecha, y el interlineado es más amplio.
var _left_text_scale =
    0.45 * _text_mul;

var _left_line_sep =
    24;


draw_text_ext_transformed(
    _left_text_x,
    _dialog_y + 16,
    _left_dialog_text,
    _left_line_sep / _left_text_scale,
    _left_text_width / _left_text_scale,
    _left_text_scale,
    _left_text_scale,
    0
);


// =========================================================
// CONTENIDO DERECHO
// =========================================================


// =========================================================
// PREVISUALIZACIÓN DE PESTAÑAS
// =========================================================
//
// Mientras state == SHOP_TOP, mover izquierda/derecha solo
// cambia la pestaña visible. Su contenido aparece de inmediato,
// pero NO se vuelve interactivo hasta pulsar Z o Enter.
// =========================================================

var _preview_buy =
    (
        state == SHOP_TOP
        &&
        top_index == 0
    );

var _preview_sell =
    (
        state == SHOP_TOP
        &&
        top_index == 1
    );

var _preview_talk =
    (
        state == SHOP_TOP
        &&
        top_index == 2
    );

var _preview_exit =
    (
        state == SHOP_TOP
        &&
        top_index == 3
    );


var _show_buy =
    (
        state == SHOP_BUY
        ||
        _preview_buy
    );

var _show_sell_type =
    (
        state == SHOP_SELL_TYPE
        ||
        _preview_sell
    );

var _show_sell =
    (
        state == SHOP_SELL
    );

var _show_talk =
    (
        state == SHOP_TALK
        ||
        _preview_talk
    );


// SALIR no tiene lista propia; mostramos una indicación,
// pero solo Z/Enter inicia realmente la despedida.
if (_preview_exit)
{
    var _exit_preview_scale =
        0.5 * _text_mul;

    var _exit_preview_margin =
        22;

    var _exit_preview_width =
        _right_w
        -
        (_exit_preview_margin * 2);


    draw_set_color(
        c_ltgray
    );


    draw_text_ext_transformed(
        _right_x + _exit_preview_margin,
        _list_y + 25,
        scr_loc(
            scr_loc_src(
                "Salir de la tienda."
            )
        ),
        22 / _exit_preview_scale,
        _exit_preview_width / _exit_preview_scale,
        _exit_preview_scale,
        _exit_preview_scale,
        0
    );
}


// =========================================================
// COMPRAR
// =========================================================

if (_show_buy)
{
    var _stock =
        shop_data.items_venta;

    var _count =
        array_length(_stock);


    if (_count <= 0)
    {
        draw_set_color(
            _muted
        );

        var _buy_empty_scale =
            0.5 * _text_mul;

        var _buy_empty_margin =
            22;

        draw_text_ext_transformed(
            _right_x + _buy_empty_margin,
            _list_y + 25,
            scr_loc(
                scr_loc_src(
                    "No hay objetos a la venta."
                )
            ),
            22 / _buy_empty_scale,
            (_right_w - (_buy_empty_margin * 2)) / _buy_empty_scale,
            _buy_empty_scale,
            _buy_empty_scale,
            0
        );
    }
    else
    {
        var _row_h =
            50;


        for (
            var _row = 0;
            _row < visible_rows;
            _row++
        )
        {
            var _idx =
                buy_scroll
                +
                _row;


            if (_idx >= _count)
            {
                break;
            }


            var _entry =
                _stock[_idx];


            var _data =
                scr_shop_get_object_data(
                    _entry.tipo,
                    _entry.id
                );


            if (is_undefined(_data))
            {
                continue;
            }


            var _ry =
                _list_y
                +
                12
                +
                (_row * _row_h);


            var _is_selected =
                (
                    state == SHOP_BUY
                    &&
                    _idx == buy_index
                );


            draw_set_color(
                _is_selected
                ?
                _selected
                :
                _normal
            );


            if (
                variable_struct_exists(
                    _data,
                    "icono_tienda"
                )
                &&
                _data.icono_tienda != -1
                &&
                sprite_exists(
                    _data.icono_tienda
                )
            )
            {
                draw_sprite_stretched_ext(
                    _data.icono_tienda,
                    0,
                    _right_x + 38,
                    _ry + 5,
                    36,
                    36,
                    c_white,
                    _ui_alpha
                );
            }


            // Color opcional del nombre.
            // Prioridad: color definido en el stock de esta tienda,
            // después color_tienda del objeto. Al seleccionarlo,
            // el amarillo sigue indicando el cursor.
            var _buy_name_color =
                _normal;

            if (
                variable_struct_exists(_data, "color_tienda")
                &&
                _data.color_tienda != noone
                &&
                !is_undefined(_data.color_tienda)
            )
            {
                _buy_name_color =
                    _data.color_tienda;
            }

            if (
                variable_struct_exists(_entry, "color_nombre")
                &&
                _entry.color_nombre != noone
                &&
                !is_undefined(_entry.color_nombre)
            )
            {
                _buy_name_color =
                    _entry.color_nombre;
            }

            draw_set_color(
                _is_selected
                ?
                _selected
                :
                _buy_name_color
            );


            draw_text_transformed(
                _right_x + 84,
                _ry + 13,
                scr_loc(
                    _data.nombre
                ),
                0.38 * _text_mul,
                0.38 * _text_mul,
                0
            );


            var _price =
                scr_shop_get_buy_price(
                    _entry.tipo,
                    _entry.id
                );


            draw_set_halign(
                fa_right
            );

            draw_set_color(
                _is_selected
                ?
                _selected
                :
                _normal
            );


            draw_text_transformed(
                _right_x + _right_w - 18,
                _ry + 13,
                "$"
                +
                string(_price)
                +
                " SO",
                0.38 * _text_mul,
                0.38 * _text_mul,
                0
            );


            draw_set_halign(
                fa_left
            );


            if (_row < visible_rows - 1)
            {
                draw_set_color(
                    _divider
                );

                draw_line(
                    _right_x + 20,
                    _ry + _row_h - 2,
                    _right_x + _right_w - 20,
                    _ry + _row_h - 2
                );
            }
        }


        // =================================================
        // BARRA DE SCROLL - MISMO ESTILO DEL INVENTARIO
        // =================================================
        if (_count > visible_rows)
        {
            var _bar_x =
                _right_x + _right_w - 8;

            var _bar_y =
                _list_y + 18;

            var _bar_h =
                _list_h - 36;

            var _max_scroll =
                max(
                    0,
                    _count - visible_rows
                );

            var _scroll_ratio =
                (_max_scroll > 0)
                ?
                clamp(buy_scroll / _max_scroll, 0, 1)
                :
                0;

            var _dot_y =
                _bar_y + (_scroll_ratio * _bar_h);

            draw_set_color(c_dkgray);
            draw_line_width(
                _bar_x,
                _bar_y,
                _bar_x,
                _bar_y + _bar_h,
                2
            );

            draw_set_color(c_white);
            draw_rectangle(
                _bar_x - 3,
                _dot_y - 3,
                _bar_x + 3,
                _dot_y + 3,
                false
            );
        }
    }
}


// =========================================================
// VENDER - SELECTOR DE TIPO
// =========================================================

if (_show_sell_type)
{
    for (var _i = 0; _i < array_length(sell_type_options); _i++)
    {
        var _ry =
            _list_y
            +
            28
            +
            (_i * 48);

        var _selected_type =
            (
                state == SHOP_SELL_TYPE
                &&
                _i == sell_type_index
            );

        draw_set_color(
            _selected_type
            ?
            _selected
            :
            _normal
        );

        draw_text_transformed(
            _right_x + 22,
            _ry,
            scr_loc(sell_type_options[_i]),
            0.5 * _text_mul,
            0.5 * _text_mul,
            0
        );
    }
}


// =========================================================
// VENDER
// =========================================================

if (_show_sell)
{
    var _count =
        array_length(sell_list);


    if (_count <= 0)
    {
        draw_set_color(
            _muted
        );

        var _sell_empty_scale =
            0.5 * _text_mul;

        var _sell_empty_margin =
            22;

        draw_text_ext_transformed(
            _right_x + _sell_empty_margin,
            _list_y + 25,
            scr_loc(
                scr_loc_src(
                    "No tienes nada que vender."
                )
            ),
            22 / _sell_empty_scale,
            (_right_w - (_sell_empty_margin * 2)) / _sell_empty_scale,
            _sell_empty_scale,
            _sell_empty_scale,
            0
        );
    }
    else
    {
        var _row_h =
            50;


        for (
            var _row = 0;
            _row < visible_rows;
            _row++
        )
        {
            var _idx =
                sell_scroll
                +
                _row;


            if (_idx >= _count)
            {
                break;
            }


            var _entry =
                sell_list[_idx];


            var _data =
                scr_shop_get_object_data(
                    _entry.tipo,
                    _entry.id
                );


            if (is_undefined(_data))
            {
                continue;
            }


            var _ry =
                _list_y
                +
                12
                +
                (_row * _row_h);


            var _is_selected =
                (
                    state == SHOP_SELL
                    &&
                    _idx == sell_index
                );


            draw_set_color(
                _is_selected
                ?
                _selected
                :
                _normal
            );


            if (
                variable_struct_exists(
                    _data,
                    "icono_tienda"
                )
                &&
                _data.icono_tienda != -1
                &&
                sprite_exists(
                    _data.icono_tienda
                )
            )
            {
                draw_sprite_stretched_ext(
                    _data.icono_tienda,
                    0,
                    _right_x + 38,
                    _ry + 5,
                    36,
                    36,
                    c_white,
                    _ui_alpha
                );
            }


            // Color opcional del nombre en VENDER.
            var _sell_name_color =
                _normal;

            if (
                variable_struct_exists(_data, "color_tienda")
                &&
                _data.color_tienda != noone
                &&
                !is_undefined(_data.color_tienda)
            )
            {
                _sell_name_color =
                    _data.color_tienda;
            }

            draw_set_color(
                _is_selected
                ?
                _selected
                :
                _sell_name_color
            );


            draw_text_transformed(
                _right_x + 84,
                _ry + 13,
                scr_loc(
                    _data.nombre
                ),
                0.38 * _text_mul,
                0.38 * _text_mul,
                0
            );


            var _price =
                scr_shop_get_sell_price(
                    _entry.tipo,
                    _entry.id
                );


            draw_set_halign(
                fa_right
            );

            draw_set_color(
                _is_selected
                ?
                _selected
                :
                _normal
            );


            draw_text_transformed(
                _right_x + _right_w - 18,
                _ry + 13,
                "$"
                +
                string(_price)
                +
                " SO",
                0.38 * _text_mul,
                0.38 * _text_mul,
                0
            );


            draw_set_halign(
                fa_left
            );


            if (_row < visible_rows - 1)
            {
                draw_set_color(
                    _divider
                );

                draw_line(
                    _right_x + 20,
                    _ry + _row_h - 2,
                    _right_x + _right_w - 20,
                    _ry + _row_h - 2
                );
            }
        }


        // =================================================
        // BARRA DE SCROLL - MISMO ESTILO DEL INVENTARIO
        // =================================================
        if (_count > visible_rows)
        {
            var _bar_x =
                _right_x + _right_w - 8;

            var _bar_y =
                _list_y + 18;

            var _bar_h =
                _list_h - 36;

            var _max_scroll =
                max(
                    0,
                    _count - visible_rows
                );

            var _scroll_ratio =
                (_max_scroll > 0)
                ?
                clamp(sell_scroll / _max_scroll, 0, 1)
                :
                0;

            var _dot_y =
                _bar_y + (_scroll_ratio * _bar_h);

            draw_set_color(c_dkgray);
            draw_line_width(
                _bar_x,
                _bar_y,
                _bar_x,
                _bar_y + _bar_h,
                2
            );

            draw_set_color(c_white);
            draw_rectangle(
                _bar_x - 3,
                _dot_y - 3,
                _bar_x + 3,
                _dot_y + 3,
                false
            );
        }
    }
}


// =========================================================
// HABLAR - LISTA DE OPCIONES
// =========================================================

if (_show_talk)
{
    var _options =
        shop_data.talk_options;


    for (
        var _i = 0;
        _i < array_length(_options);
        _i++
    )
    {
        var _ry =
            _list_y
            +
            28
            +
            (_i * 38);


        var _selected_option =
            (
                state == SHOP_TALK
                &&
                _i == talk_index
            );


        draw_set_color(
            _selected_option
            ?
            _selected
            :
            _normal
        );




        draw_text_transformed(
            _right_x + 22,
            _ry,
            "* "
            +
            scr_loc(
                _options[_i].nombre
            ),
            0.5 * _text_mul,
            0.5 * _text_mul,
            0
        );
    }
}


// =========================================================
// HABLAR - DIÁLOGO EN LA MISMA CAJA DE TALK
// =========================================================
//
// ESTA es la diferencia importante:
//
// cuando eliges un tema,
// las opciones desaparecen y el diálogo ocupa la MISMA
// caja derecha.
// =========================================================

if (
    state == SHOP_TALK_DIALOG
    &&
    array_length(talk_dialogues) > 0
)
{
    var _talk_line =
        talk_dialogues[
            talk_line_index
        ];


    var _talk_full_text =
        scr_loc(
            _talk_line.texto
        );


    var _talk_visible_text =
        string_copy(
            _talk_full_text,
            1,
            floor(talk_char)
        );


    var _talk_color =
        _talk_line.color;


    if (
        _talk_color == noone
        ||
        is_undefined(_talk_color)
    )
    {
        _talk_color =
            shop_data.vendedor_color_default;
    }


    var _talk_head =
        _talk_line.cabeza;


    if (
        _talk_head == noone
        ||
        is_undefined(_talk_head)
    )
    {
        _talk_head =
            shop_data.vendedor_cabeza_default;
    }


    var _talk_text_x =
        _right_x + 28;

    var _talk_text_y =
        _list_y + 28;

    var _talk_text_width =
        _right_w - 56;


    if (
        _talk_head != noone
        &&
        sprite_exists(_talk_head)
    )
    {
        draw_sprite_stretched_ext(
            _talk_head,
            0,
            _right_x + 28,
            _list_y + 30,
            64,
            64,
            c_white,
            _ui_alpha
        );


        _talk_text_x =
            _right_x + 110;

        _talk_text_width =
            _right_w - 138;
    }


    draw_set_color(
        _talk_color
    );


    var _talk_dialog_scale =
        0.5 * _text_mul;

    var _talk_dialog_line_sep =
        28;


    draw_text_ext_transformed(
        _talk_text_x,
        _talk_text_y,
        _talk_visible_text,
        _talk_dialog_line_sep / _talk_dialog_scale,
        _talk_text_width / _talk_dialog_scale,
        _talk_dialog_scale,
        _talk_dialog_scale,
        0
    );
}


// =========================================================
// PANEL DE INFORMACIÓN DEL OBJETO
// =========================================================

var _info_entry =
    undefined;


if (
    state == SHOP_BUY
    &&
    array_length(shop_data.items_venta) > 0
)
{
    _info_entry =
        shop_data.items_venta[
            buy_index
        ];
}


if (
    state == SHOP_SELL
    &&
    array_length(sell_list) > 0
)
{
    _info_entry =
        sell_list[
            sell_index
        ];
}


if (!is_undefined(_info_entry))
{
    var _data =
        scr_shop_get_object_data(
            _info_entry.tipo,
            _info_entry.id
        );


    if (!is_undefined(_data))
    {
        var _ix =
            _right_x + 14;


        if (
            variable_struct_exists(
                _data,
                "icono_tienda"
            )
            &&
            _data.icono_tienda != -1
            &&
            sprite_exists(
                _data.icono_tienda
            )
        )
        {
            draw_sprite_stretched_ext(
                _data.icono_tienda,
                0,
                _right_x + 14,
                _info_y + 14,
                48,
                48,
                c_white,
                _ui_alpha
            );


            _ix =
                _right_x + 76;
        }


        draw_set_color(
            c_white
        );


        var _description_text =
            scr_loc(
                _data.descripcion
            );

        // Consumibles: mostrar cuánto HP recuperan.
        // Se añade al MISMO texto para que el wrapping
        // automático decida si cabe en la línea actual.
        if (
            _info_entry.tipo == "item"
            &&
            variable_struct_exists(
                _data,
                "curacion_hp"
            )
        )
        {
            _description_text +=
                "   HP +"
                +
                string(_data.curacion_hp);
        }


        // Armas/armaduras: mostrar cuánto AT y DF aportan.
        if (_info_entry.tipo == "equip")
        {
            var _atk =
                variable_struct_exists(
                    _data,
                    "ataque"
                )
                ?
                _data.ataque
                :
                0;

            var _def =
                variable_struct_exists(
                    _data,
                    "defensa"
                )
                ?
                _data.defensa
                :
                0;

            _description_text +=
                "   AT +"
                +
                string(_atk)
                +
                "   DF +"
                +
                string(_def);
        }

        // Descripción: doble del tamaño que tenía y con
        // mayor espacio visual entre renglones.
        var _description_scale =
            0.43 * _text_mul;

        var _description_line_sep =
            28;

        // Aprovechar prácticamente todo el ancho restante
        // de la caja hasta su margen derecho.
        var _description_right =
            _right_x + _right_w - 14;

        var _description_width =
            max(
                1,
                _description_right - _ix
            );


        draw_text_ext_transformed(
            _ix,
            _info_y + 12,
            _description_text,
            _description_line_sep / _description_scale,
            _description_width / _description_scale,
            _description_scale,
            _description_scale,
            0
        );



    }
}


// Restaurar.
draw_set_halign(
    fa_left
);

draw_set_valign(
    fa_top
);



// Restaurar alpha global para no afectar otros Draw GUI.
draw_set_alpha(1);
