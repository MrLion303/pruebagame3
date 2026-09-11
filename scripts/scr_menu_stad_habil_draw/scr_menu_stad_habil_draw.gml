/// =========================================================
/// SCR_MENU_STAD_HABIL_DRAW
/// REEMPLAZO COMPLETO
/// =========================================================
///
/// HABIL:
///
/// - Lista de habilidades.
/// - Al seleccionar, toda la ventana se convierte en detalle.
/// - Icono arriba a la izquierda.
/// - Nombre a la derecha del icono.
/// - DESCRIPCIÓN empieza DEBAJO del icono y ocupa el ancho.
/// - Mayor separación entre renglones.
/// - "Z / X - Cerrar" centrado abajo y más pequeño.
/// =========================================================

function scr_menu_stad_habil_draw(_menu)
{
    if (
        _menu == noone
        ||
        !instance_exists(
            _menu
        )
        ||
        _menu.state
        !=
        MENU_STATE.INFO_MENU
    )
    {
        return;
    }


    if (
        !variable_instance_exists(
            _menu,
            "stad_tabs_ready"
        )
    )
    {
        return;
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


    // =====================================================
    // GEOMETRÍA
    // =====================================================

    var _box_x =
        222;

    var _box_y =
        80;

    var _box_w =
        346;

    var _box_h =
        363;


    // =====================================================
    // PESTAÑAS
    // =====================================================

    var _tab_t =
        1
        -
        power(
            1 - _menu.stad_tab_slide,
            3
        );


    var _tabs_x =
        _box_x;

    var _tabs_y =
        lerp(
            88,
            28,
            _tab_t
        );

    var _tabs_w =
        _box_w;

    var _tabs_h =
        44;


    draw_sprite_stretched(
        spr_textbox,
        scr_ui_box_frame(
            spr_textbox
        ),
        _tabs_x,
        _tabs_y,
        _tabs_w,
        _tabs_h
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
        _tabs_w
        /
        2;


    for (
        var _i = 0;
        _i < 2;
        _i++
    )
    {
        var _left =
            _tabs_x
            +
            (_i * _slot_w);


        var _right =
            _left
            +
            _slot_w;


        if (
            _menu.stad_tab
            ==
            _i
        )
        {
            draw_set_color(
                c_yellow
            );


            draw_rectangle(
                _left + 6,
                _tabs_y + 7,
                _right - 6,
                _tabs_y + 36,
                true
            );
        }


        draw_set_color(
            (
                _menu.stad_tab
                ==
                _i
            )
            ?
            c_yellow
            :
            c_orange
        );


        draw_set_halign(
            fa_center
        );


        draw_text(
            (_left + _right)
            *
            0.5,
            _tabs_y + 8,
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


    // =====================================================
    // STAD
    // =====================================================

    if (
        _menu.stad_tab
        ==
        0
    )
    {
        return;
    }


    // =====================================================
    // PANEL HABIL
    // =====================================================

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


    // =====================================================
    // DETALLE DE HABILIDAD
    // =====================================================

    if (
        _menu.habil_info_open
        &&
        _menu.habil_info_id
        !=
        ""
    )
    {
        var _info =
            scr_habilidad_data(
                _menu.habil_info_id
            );


        var _desc =
            scr_loc(
                _info.descripcion
            );


        if (
            _menu.habil_info_id
            ==
            "dash"
        )
        {
            _desc =
                scr_loc(
                    "Permite hacer dash dentro del rango de peligro de un enemigo. Funciona con la habilidad Dash o con los Zapatos Rápidos."
                );
        }


        // -------------------------------------------------
        // ICONO
        // -------------------------------------------------

        var _detail_margin =
            22;

        var _icon_size =
            82;

        var _icon_x =
            _box_x
            +
            _detail_margin;

        var _icon_y =
            _box_y
            +
            24;


        draw_set_color(
            c_gray
        );


        draw_rectangle(
            _icon_x,
            _icon_y,
            _icon_x + _icon_size,
            _icon_y + _icon_size,
            true
        );


        if (
            variable_struct_exists(
                _info,
                "icono"
            )
            &&
            _info.icono
            !=
            -1
            &&
            sprite_exists(
                _info.icono
            )
        )
        {
            var _sw =
                max(
                    1,
                    sprite_get_width(
                        _info.icono
                    )
                );


            var _sh =
                max(
                    1,
                    sprite_get_height(
                        _info.icono
                    )
                );


            var _fit =
                min(
                    (_icon_size - 12) / _sw,
                    (_icon_size - 12) / _sh
                );


            var _cx =
                _icon_x
                +
                (_icon_size * 0.5);


            var _cy =
                _icon_y
                +
                (_icon_size * 0.5);


            var _draw_x =
                _cx
                +
                (
                    sprite_get_xoffset(
                        _info.icono
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
                        _info.icono
                    )
                    -
                    (_sh * 0.5)
                )
                *
                _fit;


            draw_sprite_ext(
                _info.icono,
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


        // -------------------------------------------------
        // NOMBRE A LA DERECHA DEL ICONO
        // -------------------------------------------------

        var _name_x =
            _icon_x
            +
            _icon_size
            +
            20;


        draw_set_color(
            c_yellow
        );


        draw_text(
            _name_x,
            _icon_y + 8,
            scr_loc(
                _info.nombre
            )
        );


        // -------------------------------------------------
        // DESCRIPCIÓN DEBAJO DEL ICONO
        // -------------------------------------------------
        //
        // Empieza debajo de TODA la imagen.
        // Usa todo el ancho del panel.
        //
        // Separación entre líneas aumentada a 30 px.
        // -------------------------------------------------

        var _desc_x =
            _box_x
            +
            22;

        var _desc_y =
            _icon_y
            +
            _icon_size
            +
            24;

        var _desc_w =
            _box_w
            -
            44;


        draw_set_color(
            c_white
        );


        draw_text_ext(
            _desc_x,
            _desc_y,
            _desc,
            30,
            _desc_w
        );


        // -------------------------------------------------
        // Z / X - CERRAR
        // -------------------------------------------------

        draw_set_color(
            c_gray
        );


        draw_set_halign(
            fa_center
        );


        draw_text_transformed(
            _box_x + (_box_w * 0.5),
            _box_y + _box_h - 27,
            scr_loc(
                "Z / X - Cerrar"
            ),
            0.55,
            0.55,
            0
        );


        draw_set_halign(
            fa_left
        );


        draw_set_color(
            c_white
        );


        return;
    }


    // =====================================================
    // LISTA
    // =====================================================

    var _lista =
        scr_habilidades_lista_obtenidas();


    var _total =
        array_length(
            _lista
        );


    var _start_x =
        _box_x
        +
        20;

    var _start_y =
        _box_y
        +
        22;

    var _row_h =
        56;

    var _list_icon_size =
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
                _menu.habil_scroll
                +
                _menu.habil_visible_rows
            );


        for (
            var _idx = _menu.habil_scroll;
            _idx < _last;
            _idx++
        )
        {
            var _row =
                _idx
                -
                _menu.habil_scroll;


            var _row_y =
                _start_y
                +
                (_row * _row_h);


            var _selected =
                (
                    _idx
                    ==
                    _menu.habil_index
                );


            var _ability_id =
                _lista[
                    _idx
                ];


            var _data =
                scr_habilidad_data(
                    _ability_id
                );


            if (_selected)
            {
                draw_set_color(
                    c_yellow
                );


                draw_rectangle(
                    _start_x - 6,
                    _row_y - 5,
                    _box_x + _box_w - 18,
                    _row_y + 43,
                    true
                );
            }


            // -----------------------------------------
            // ICONO
            // -----------------------------------------

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
                _start_x + _list_icon_size,
                _row_y + _list_icon_size,
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
                var _lsw =
                    max(
                        1,
                        sprite_get_width(
                            _data.icono
                        )
                    );


                var _lsh =
                    max(
                        1,
                        sprite_get_height(
                            _data.icono
                        )
                    );


                var _lfit =
                    min(
                        (_list_icon_size - 6) / _lsw,
                        (_list_icon_size - 6) / _lsh
                    );


                var _lcx =
                    _start_x
                    +
                    (_list_icon_size * 0.5);


                var _lcy =
                    _row_y
                    +
                    (_list_icon_size * 0.5);


                var _ldraw_x =
                    _lcx
                    +
                    (
                        sprite_get_xoffset(
                            _data.icono
                        )
                        -
                        (_lsw * 0.5)
                    )
                    *
                    _lfit;


                var _ldraw_y =
                    _lcy
                    +
                    (
                        sprite_get_yoffset(
                            _data.icono
                        )
                        -
                        (_lsh * 0.5)
                    )
                    *
                    _lfit;


                draw_sprite_ext(
                    _data.icono,
                    0,
                    _ldraw_x,
                    _ldraw_y,
                    _lfit,
                    _lfit,
                    0,
                    c_white,
                    1
                );
            }


            // -----------------------------------------
            // NOMBRE
            // -----------------------------------------

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
                _list_icon_size
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


    draw_set_color(
        c_white
    );


    draw_set_alpha(
        1
    );
}
