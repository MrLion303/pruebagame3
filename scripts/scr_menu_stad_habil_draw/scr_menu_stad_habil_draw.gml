/// =========================================================
/// SCR_MENU_STAD_HABIL_DRAW
/// NUEVO SCRIPT
/// =========================================================
///
/// Lo llama DIRECTAMENTE obj_menu_manager desde Draw GUI End.
/// No usa ningún objeto externo.
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
    // GEOMETRÍA EXACTA DEL MENÚ ACTUAL
    // =====================================================

    var _box_x =
        222;

    var _box_y =
        80;

    var _box_w =
        346;

    // STAD actual = 308 + 55.
    var _box_h =
        363;


    // =====================================================
    // PESTAÑAS SUPERIORES STAD / HABIL
    // =====================================================
    //
    // Misma caja y misma animación que INV / EQUIP / CLAVE.
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


        // Igual que las pestañas de INV cuando tienen foco.
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
    //
    // El Draw GUI normal ya dibujó el STAD exactamente como
    // siempre. Si esta pestaña está activa, no hay que tapar
    // nada.
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
    // HABIL - TAPAR STAD Y DIBUJAR LISTA
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
            // ESPACIO PARA SPRITE
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
                        (_icon_size - 6)
                        /
                        _sw,

                        (_icon_size - 6)
                        /
                        _sh
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


    // =====================================================
    // CUADRO DE INFO
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


        // Descripción actualizada según la nueva regla OR.
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


        var _info_w =
            _box_w
            -
            28;

        var _info_h =
            150;

        var _info_x =
            _box_x
            +
            14;

        var _info_y =
            _box_y
            +
            (_box_h * 0.5)
            -
            (_info_h * 0.5);


        draw_set_alpha(
            0.72
        );


        draw_set_color(
            c_black
        );


        draw_rectangle(
            _box_x,
            _box_y,
            _box_x + _box_w,
            _box_y + _box_h,
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
            _info_x,
            _info_y,
            _info_w,
            _info_h
        );


        draw_set_color(
            c_yellow
        );


        draw_text(
            _info_x + 18,
            _info_y + 16,
            scr_loc(
                _info.nombre
            )
        );


        draw_set_color(
            c_white
        );


        draw_text_ext(
            _info_x + 18,
            _info_y + 50,
            _desc,
            20,
            _info_w - 36
        );


        draw_set_color(
            c_gray
        );


        draw_set_halign(
            fa_center
        );


        draw_text(
            _info_x
            +
            (_info_w * 0.5),
            _info_y
            +
            _info_h
            -
            27,
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
}
