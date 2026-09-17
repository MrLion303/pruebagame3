/// =========================================================
/// SCR_MENU_STAD_HABIL_DRAW
/// COMPLETO
/// =========================================================
///
/// Incluye:
/// - STAD / HABIL existente.
/// - Detalle de HABIL con animación de abrir/cerrar desde el centro.
/// - Z/Enter sobre un objeto CLAVE abre directamente su ficha de utilidad.
/// - Ficha de utilidad como overlay sobre CLAVE, sin botón intermedio.
/// - Panel CLAVE con su tamaño normal de 346x308: sin caja inferior ni texto legado.
/// - Ficha CLAVE del mismo tamaño exacto que su panel normal de fondo.
/// - Detalle HABIL como overlay sin ocultar la lista de fondo.
/// - Animaciones desde el centro al abrir y al cerrar.
/// - CLAVE redibujado sin caja inferior y con navegación por todos los slots vacíos.
/// =========================================================


// =========================================================
// EASE DE LAS VENTANAS DE DETALLE
// =========================================================

function scr_menu_detail_ease(_t)
{
    _t = clamp(_t, 0, 1);

    return _t * _t * (3 - (2 * _t));
}


// =========================================================
// DIBUJAR ICONO / ESPACIO PARA ICONO
// =========================================================

function scr_menu_detail_draw_icon(
    _icon,
    _x,
    _y,
    _size,
    _alpha = 1
)
{
    draw_set_alpha(_alpha);

    draw_set_color(c_gray);

    draw_rectangle(
        _x,
        _y,
        _x + _size,
        _y + _size,
        true
    );


    if (
        _icon != -1
        &&
        !is_undefined(_icon)
        &&
        sprite_exists(_icon)
    )
    {
        var _sw =
            max(
                1,
                sprite_get_width(_icon)
            );

        var _sh =
            max(
                1,
                sprite_get_height(_icon)
            );

        var _fit =
            min(
                (_size - 12) / _sw,
                (_size - 12) / _sh
            );

        var _cx =
            _x + (_size * 0.5);

        var _cy =
            _y + (_size * 0.5);

        var _draw_x =
            _cx
            +
            (
                sprite_get_xoffset(_icon)
                -
                (_sw * 0.5)
            )
            *
            _fit;

        var _draw_y =
            _cy
            +
            (
                sprite_get_yoffset(_icon)
                -
                (_sh * 0.5)
            )
            *
            _fit;


        draw_sprite_ext(
            _icon,
            0,
            _draw_x,
            _draw_y,
            _fit,
            _fit,
            0,
            c_white,
            _alpha
        );
    }


    draw_set_alpha(1);
    draw_set_color(c_white);
}


// =========================================================
// CLAVE -> DETALLE DIRECTO
// =========================================================

function scr_menu_clave_utilidad_draw(_menu)
{
    if (
        _menu == noone
        ||
        !instance_exists(_menu)
    )
    {
        return false;
    }


    // =====================================================
    // INICIALIZACIÓN
    // =====================================================

    if (
        !variable_instance_exists(
            _menu,
            "clave_detalle_ready"
        )
    )
    {
        _menu.clave_detalle_ready = true;

        _menu.clave_detalle_abierto = false;
        _menu.clave_detalle_cerrando = false;

        _menu.clave_detalle_anim = 0;
        _menu.clave_detalle_anim_speed = 1 / 8;

        _menu.clave_detalle_id = "";

        _menu.clave_detalle_lock_x = 0;
        _menu.clave_detalle_lock_y = 0;
        _menu.clave_detalle_lock_scroll = 0;

        // Sirve para distinguir la Z/Enter que CONFIRMA la
        // pestaña CLAVE de una Z/Enter que realmente selecciona
        // un objeto dentro del inventario.
        _menu.clave_prev_tab_focus =
            _menu.inventory_tab_focus;
    }


    // Fuera de CLAVE no conservamos ningún modal abierto.
    if (
        _menu.state
        !=
        MENU_STATE.CLAVE_MENU
    )
    {
        _menu.clave_detalle_abierto = false;
        _menu.clave_detalle_cerrando = false;
        _menu.clave_detalle_anim = 0;
        _menu.clave_detalle_id = "";

        _menu.clave_prev_tab_focus =
            _menu.inventory_tab_focus;

        return false;
    }


    // =====================================================
    // DATOS
    // =====================================================

    scr_inventarios_data();

    if (!variable_global_exists("itemclave_db"))
    {
        src_itemclave_data();
    }


    // =====================================================
    // DETECTAR ENTRADA DESDE LAS PESTAÑAS
    // =====================================================
    //
    // Step_0 procesa Z/Enter ANTES de Draw GUI End.
    // Si esa tecla acaba de confirmar la pestaña CLAVE,
    // NO debe reutilizarse en el mismo frame para abrir las
    // Tijeras. Este era el origen del doble-X al volver.
    // =====================================================

    var _acaba_de_entrar_desde_tabs =
        _menu.clave_prev_tab_focus
        &&
        !_menu.inventory_tab_focus;


    var _confirm =
        keyboard_check_pressed(ord("Z"))
        ||
        keyboard_check_pressed(vk_enter);

    var _back =
        keyboard_check_pressed(ord("X"))
        ||
        keyboard_check_pressed(vk_shift);


    var _confirm_objeto =
        _confirm
        &&
        !_acaba_de_entrar_desde_tabs;


    // =====================================================
    // REDIBUJAR CLAVE COMPLETO
    // =====================================================
    //
    // El Draw GUI antiguo todavía contiene la caja inferior
    // de descripción. Como spr_textbox tiene centro transparente,
    // simplemente dibujar otra caja encima no borra aquel texto.
    //
    // Por eso primero limpiamos TODO el interior con negro y
    // después dibujamos nuevamente el marco y los 15 slots.
    // =====================================================

    var _clave_box_x = 222;
    var _clave_box_y = 80;
    var _clave_box_w = 346;
    var _clave_box_h = 308;


    draw_set_alpha(1);
    draw_set_color(c_black);

    // Limpieza opaca del área completa de CLAVE. Esto elimina
    // también cualquier texto heredado que Draw GUI haya dibujado
    // en la antigua caja inferior de descripción/uso.
    draw_rectangle(
        _clave_box_x,
        _clave_box_y,
        _clave_box_x + _clave_box_w,
        _clave_box_y + _clave_box_h,
        false
    );


    draw_sprite_stretched(
        spr_textbox,
        scr_ui_box_frame(spr_textbox),
        _clave_box_x,
        _clave_box_y,
        _clave_box_w,
        _clave_box_h
    );


    var _start_x =
        _clave_box_x + 24;

    var _start_y =
        _clave_box_y + 20;

    var _cell_w = 100;
    var _cell_h = 58;


    // CLAVE son exactamente 15 slots: 5 filas x 3 columnas.
    // Ya no hay una ventana inferior, así que mostramos las
    // CINCO filas al mismo tiempo y eliminamos visualmente el
    // antiguo scroll.
    var _slot_total = 15;
    var _row_total = 5;


    // Step_0 conserva su sistema y/scroll de 3 filas visibles.
    // Para dibujar las 5 filas usamos la fila ABSOLUTA. De este
    // modo el cursor puede recorrer incluso slots vacíos sin que
    // el contenido del slot intervenga en la navegación.
    var _selected_abs_row =
        clamp(
            _menu.clave_y + _menu.clave_scroll,
            0,
            _row_total - 1
        );


    // -----------------------------------------------------
    // CUADRÍCULA COMPLETA: 5 x 3
    // -----------------------------------------------------

    for (var _yy = 0; _yy < _row_total; _yy++)
    {
        for (var _xx = 0; _xx < 3; _xx++)
        {
            var _slot_index =
                (_yy * 3) + _xx;

            var _cx =
                _start_x + (_xx * _cell_w);

            var _cy =
                _start_y + (_yy * _cell_h);


            // El selector depende SOLO de las coordenadas.
            // Un slot vacío se puede seleccionar exactamente
            // igual que uno ocupado.
            if (
                !_menu.inventory_tab_focus
                &&
                !_menu.clave_detalle_abierto
                &&
                _menu.clave_x == _xx
                &&
                _selected_abs_row == _yy
            )
            {
                draw_set_color(c_yellow);

                draw_rectangle(
                    _cx - 4,
                    _cy - 4,
                    _cx + _cell_w - 18,
                    _cy + 43,
                    true
                );
            }


            var _slot_id = -1;


            if (
                _slot_index >= 0
                &&
                _slot_index < _slot_total
                &&
                _slot_index < array_length(
                    global.itemclave_inventory
                )
            )
            {
                _slot_id =
                    global.itemclave_inventory[
                        _slot_index
                    ];
            }


            if (
                _slot_id != -1
                &&
                !is_undefined(_slot_id)
                &&
                is_string(_slot_id)
                &&
                variable_struct_exists(
                    global.itemclave_db,
                    _slot_id
                )
            )
            {
                var _slot_data =
                    variable_struct_get(
                        global.itemclave_db,
                        _slot_id
                    );


                draw_set_color(c_orange);


                draw_text_ext_transformed(
                    _cx,
                    _cy,
                    scr_loc(
                        _slot_data.nombre
                    ),
                    23,
                    84,
                    0.66,
                    0.66,
                    0
                );
            }
            else
            {
                draw_set_color(c_dkgray);

                draw_text_transformed(
                    _cx,
                    _cy,
                    "-----",
                    0.66,
                    0.66,
                    0
                );
            }
        }
    }


    // =====================================================
    // SLOT ACTUAL
    // =====================================================

    var _slot =
        (_selected_abs_row * 3)
        +
        _menu.clave_x;

    var _id = -1;


    if (
        _slot >= 0
        &&
        _slot < _slot_total
        &&
        _slot < array_length(
            global.itemclave_inventory
        )
    )
    {
        _id =
            global.itemclave_inventory[_slot];
    }


    var _data = undefined;


    if (
        _id != -1
        &&
        !is_undefined(_id)
        &&
        is_string(_id)
        &&
        variable_struct_exists(
            global.itemclave_db,
            _id
        )
    )
    {
        _data =
            variable_struct_get(
                global.itemclave_db,
                _id
            );
    }


    // =====================================================
    // ABRIR DIRECTAMENTE EL DETALLE
    // =====================================================
    //
    // Z/Enter sobre un objeto CLAVE abre su ficha directamente.
    // La Z/Enter usada para entrar desde las pestañas se ignora
    // durante ese frame para impedir una apertura accidental.
    // =====================================================

    if (
        !_menu.clave_detalle_abierto
        &&
        !_menu.inventory_tab_focus
        &&
        !is_undefined(_data)
        &&
        _confirm_objeto
    )
    {
        _menu.clave_detalle_abierto = true;
        _menu.clave_detalle_cerrando = false;
        _menu.clave_detalle_anim = 0;
        _menu.clave_detalle_id = _id;

        _menu.clave_detalle_lock_x =
            _menu.clave_x;

        _menu.clave_detalle_lock_y =
            _menu.clave_y;

        _menu.clave_detalle_lock_scroll =
            _menu.clave_scroll;


        keyboard_clear(ord("Z"));
        keyboard_clear(vk_enter);

        _confirm = false;
        _confirm_objeto = false;
    }


    // =====================================================
    // SIN MODAL
    // =====================================================

    if (!_menu.clave_detalle_abierto)
    {
        _menu.clave_prev_tab_focus =
            _menu.inventory_tab_focus;

        draw_set_color(c_white);
        draw_set_alpha(1);
        draw_set_halign(fa_left);

        return false;
    }


    // =====================================================
    // MODAL ABIERTO: RESTAURAR ESTADO DE FONDO
    // =====================================================
    //
    // Step_0 se ejecuta antes que este script. Si se pulsa X
    // mientras la ficha está abierta, Step_0 cree que debe volver
    // a las pestañas. Aquí corregimos eso: el primer X cierra la
    // ficha; el siguiente X sí vuelve a las pestañas.
    // =====================================================

    _menu.state =
        MENU_STATE.CLAVE_MENU;

    _menu.inventory_tab_focus =
        false;

    _menu.clave_x =
        _menu.clave_detalle_lock_x;

    _menu.clave_y =
        _menu.clave_detalle_lock_y;

    _menu.clave_scroll =
        _menu.clave_detalle_lock_scroll;


    var _detail_data =
        scr_itemclave_get(
            _menu.clave_detalle_id
        );


    if (is_undefined(_detail_data))
    {
        _menu.clave_detalle_abierto = false;
        _menu.clave_detalle_cerrando = false;
        _menu.clave_detalle_anim = 0;
        _menu.clave_detalle_id = "";

        _menu.clave_prev_tab_focus =
            false;

        return false;
    }


    // =====================================================
    // PEDIR CIERRE
    // =====================================================

    if (
        !_menu.clave_detalle_cerrando
        &&
        (_confirm || _back)
    )
    {
        _menu.clave_detalle_cerrando = true;

        keyboard_clear(ord("Z"));
        keyboard_clear(vk_enter);
        keyboard_clear(ord("X"));
        keyboard_clear(vk_shift);
    }


    // =====================================================
    // ANIMACIÓN
    // =====================================================

    if (_menu.clave_detalle_cerrando)
    {
        _menu.clave_detalle_anim =
            max(
                0,
                _menu.clave_detalle_anim
                -
                _menu.clave_detalle_anim_speed
            );
    }
    else
    {
        _menu.clave_detalle_anim =
            min(
                1,
                _menu.clave_detalle_anim
                +
                _menu.clave_detalle_anim_speed
            );
    }


    if (
        _menu.clave_detalle_cerrando
        &&
        _menu.clave_detalle_anim <= 0
    )
    {
        _menu.clave_detalle_abierto = false;
        _menu.clave_detalle_cerrando = false;
        _menu.clave_detalle_anim = 0;
        _menu.clave_detalle_id = "";

        _menu.state =
            MENU_STATE.CLAVE_MENU;

        _menu.inventory_tab_focus =
            false;

        _menu.clave_prev_tab_focus =
            false;

        return true;
    }


    // =====================================================
    // DIBUJAR MODAL DE UTILIDAD ENCIMA DE CLAVE
    // =====================================================

    // La ficha de objeto CLAVE ocupa EXACTAMENTE el mismo
    // rectángulo que el panel CLAVE normal de fondo.
    var _modal_x = _clave_box_x;
    var _modal_y = _clave_box_y;
    var _modal_w = _clave_box_w;
    var _modal_h = _clave_box_h;


    var _t =
        scr_menu_detail_ease(
            _menu.clave_detalle_anim
        );


    var _modal_cx =
        _modal_x + (_modal_w * 0.5);

    var _modal_cy =
        _modal_y + (_modal_h * 0.5);


    var _draw_w =
        max(
            2,
            _modal_w * _t
        );

    var _draw_h =
        max(
            2,
            _modal_h * _t
        );


    var _draw_x =
        _modal_cx - (_draw_w * 0.5);

    var _draw_y =
        _modal_cy - (_draw_h * 0.5);


    // Fondo negro real para que nada del inventario atraviese
    // el centro transparente de spr_textbox.
    draw_set_color(c_black);

    draw_rectangle(
        _draw_x,
        _draw_y,
        _draw_x + _draw_w,
        _draw_y + _draw_h,
        false
    );


    draw_sprite_stretched_ext(
        spr_textbox,
        scr_ui_box_frame(spr_textbox),
        _draw_x,
        _draw_y,
        _draw_w,
        _draw_h,
        c_white,
        1
    );


    var _content_alpha =
        clamp(
            (_t - 0.68) / 0.32,
            0,
            1
        );


    if (_content_alpha > 0)
    {
        var _margin = 22;
        var _icon_size = 82;

        var _icon_x =
            _modal_x + _margin;

        var _icon_y =
            _modal_y + 20;

        var _icon = -1;


        if (
            variable_struct_exists(
                _detail_data,
                "icono"
            )
        )
        {
            _icon =
                _detail_data.icono;
        }


        scr_menu_detail_draw_icon(
            _icon,
            _icon_x,
            _icon_y,
            _icon_size,
            _content_alpha
        );


        draw_set_alpha(_content_alpha);


        var _name_x =
            _icon_x + _icon_size + 18;

        var _name_w =
            max(
                40,
                (_modal_x + _modal_w - _margin)
                -
                _name_x
            );


        draw_set_color(c_yellow);

        draw_text_ext(
            _name_x,
            _icon_y + 8,
            scr_loc(
                _detail_data.nombre
            ),
            26,
            _name_w
        );


        var _detail_text = "";


        // La ficha de Utilidad usa un campo separado.
        // "uso" queda como compatibilidad para partidas/datos antiguos,
        // pero NUNCA usamos "descripcion" aquí.
        if (
            variable_struct_exists(
                _detail_data,
                "utilidad"
            )
            &&
            is_string(
                _detail_data.utilidad
            )
            &&
            _detail_data.utilidad != ""
        )
        {
            _detail_text =
                scr_loc(
                    _detail_data.utilidad
                );
        }
        else if (
            variable_struct_exists(
                _detail_data,
                "uso"
            )
            &&
            is_string(
                _detail_data.uso
            )
            &&
            _detail_data.uso != ""
        )
        {
            _detail_text =
                scr_loc(
                    _detail_data.uso
                );
        }


        draw_set_color(c_white);

        draw_text_ext(
            _modal_x + 26,
            _icon_y + _icon_size + 24,
            _detail_text,
            28,
            _modal_w - 52
        );


        draw_set_color(c_gray);
        draw_set_halign(fa_center);

        draw_text_transformed(
            _modal_x + (_modal_w * 0.5),
            _modal_y + _modal_h - 27,
            scr_loc(
                scr_loc_src(
                    "Z / X - Cerrar"
                )
            ),
            0.55,
            0.55,
            0
        );


        draw_set_halign(fa_left);
        draw_set_alpha(1);
        draw_set_color(c_white);
    }


    _menu.clave_prev_tab_focus =
        false;

    return true;
}


// =========================================================
// DIBUJAR LISTA HABIL COMO FONDO DE LA VENTANA MODAL
// =========================================================
//
// Se usa mientras la ficha de una habilidad está abierta.
// La lista NO desaparece: permanece dibujada detrás.
// =========================================================

function scr_menu_habil_draw_background(
    _menu,
    _box_x,
    _box_y,
    _box_w,
    _box_h
)
{
    draw_sprite_stretched(
        spr_textbox,
        scr_ui_box_frame(spr_textbox),
        _box_x,
        _box_y,
        _box_w,
        _box_h
    );


    var _bg_lista =
        scr_habilidades_lista_obtenidas();

    var _bg_total =
        array_length(_bg_lista);

    var _bg_start_x =
        _box_x + 20;

    var _bg_start_y =
        _box_y + 22;

    var _bg_row_h =
        56;

    var _bg_icon_size =
        36;


    if (_bg_total <= 0)
    {
        draw_set_color(c_gray);

        draw_text(
            _bg_start_x,
            _bg_start_y,
            scr_loc(
                scr_loc_src(
                    "Todavía no tienes habilidades."
                )
            )
        );

        draw_set_color(c_white);
        return;
    }


    var _bg_last =
        min(
            _bg_total,
            _menu.habil_scroll
            +
            _menu.habil_visible_rows
        );


    for (
        var _bg_idx = _menu.habil_scroll;
        _bg_idx < _bg_last;
        _bg_idx++
    )
    {
        var _bg_row =
            _bg_idx - _menu.habil_scroll;

        var _bg_row_y =
            _bg_start_y
            +
            (_bg_row * _bg_row_h);

        var _bg_selected =
            _bg_idx == _menu.habil_index;

        var _bg_ability_id =
            _bg_lista[_bg_idx];

        var _bg_data =
            scr_habilidad_data(
                _bg_ability_id
            );


        if (_bg_selected)
        {
            draw_set_color(c_yellow);

            draw_rectangle(
                _bg_start_x - 6,
                _bg_row_y - 5,
                _box_x + _box_w - 18,
                _bg_row_y + 43,
                true
            );
        }


        draw_set_color(
            _bg_selected
            ?
            c_yellow
            :
            c_gray
        );

        draw_rectangle(
            _bg_start_x,
            _bg_row_y,
            _bg_start_x + _bg_icon_size,
            _bg_row_y + _bg_icon_size,
            true
        );


        if (
            variable_struct_exists(
                _bg_data,
                "icono"
            )
            &&
            _bg_data.icono != -1
            &&
            sprite_exists(_bg_data.icono)
        )
        {
            var _bg_sw =
                max(
                    1,
                    sprite_get_width(
                        _bg_data.icono
                    )
                );

            var _bg_sh =
                max(
                    1,
                    sprite_get_height(
                        _bg_data.icono
                    )
                );

            var _bg_fit =
                min(
                    (_bg_icon_size - 6) / _bg_sw,
                    (_bg_icon_size - 6) / _bg_sh
                );

            var _bg_cx =
                _bg_start_x
                +
                (_bg_icon_size * 0.5);

            var _bg_cy =
                _bg_row_y
                +
                (_bg_icon_size * 0.5);

            var _bg_draw_x =
                _bg_cx
                +
                (
                    sprite_get_xoffset(
                        _bg_data.icono
                    )
                    -
                    (_bg_sw * 0.5)
                )
                *
                _bg_fit;

            var _bg_draw_y =
                _bg_cy
                +
                (
                    sprite_get_yoffset(
                        _bg_data.icono
                    )
                    -
                    (_bg_sh * 0.5)
                )
                *
                _bg_fit;


            draw_sprite_ext(
                _bg_data.icono,
                0,
                _bg_draw_x,
                _bg_draw_y,
                _bg_fit,
                _bg_fit,
                0,
                c_white,
                1
            );
        }


        draw_set_color(
            _bg_selected
            ?
            c_yellow
            :
            c_white
        );

        draw_text(
            _bg_start_x
            +
            _bg_icon_size
            +
            16,
            _bg_row_y + 7,
            scr_loc(
                _bg_data.nombre
            )
        );
    }


    draw_set_color(c_white);
    draw_set_alpha(1);
    draw_set_halign(fa_left);
}


// =========================================================
// STAD / HABIL
// =========================================================

function scr_menu_stad_habil_draw(_menu)
{
    if (
        _menu == noone
        ||
        !instance_exists(_menu)
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


    draw_set_alpha(1);
    draw_set_halign(fa_left);
    draw_set_valign(fa_top);


    // =====================================================
    // PRIMERO: CLAVE / UTILIDAD
    // =====================================================
    //
    // Esta función se llama desde Draw GUI End todos los frames,
    // así que aquí redibujamos CLAVE sin su caja inferior y
    // superponemos directamente la ficha del objeto elegido.
    // =====================================================

    scr_menu_clave_utilidad_draw(
        _menu
    );


    // Fuera de STAD/HABIL ya no hay nada más que dibujar aquí.
    if (
        _menu.state
        !=
        MENU_STATE.INFO_MENU
    )
    {
        // Limpiar animación de HABIL si abandonamos el menú.
        if (
            variable_instance_exists(
                _menu,
                "habil_info_window_ready"
            )
        )
        {
            _menu.habil_info_window_anim = 0;
            _menu.habil_info_window_closing = false;
            _menu.habil_info_window_id = "";
        }

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


    // =====================================================
    // GEOMETRÍA
    // =====================================================

    var _box_x = 222;
    var _box_y = 80;
    var _box_w = 346;
    var _box_h = 363;


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


    var _habilidades_tabs =
        scr_habilidades_lista_obtenidas();


    var _habil_tab_available =
        array_length(
            _habilidades_tabs
        )
        >
        0;


    var _tabs_w =
        _habil_tab_available
        ?
        _box_w
        :
        (_box_w * 0.5);


    if (!_habil_tab_available)
    {
        _tabs_x =
            _box_x
            +
            ((_box_w - _tabs_w) * 0.5);

        _menu.stad_tab = 0;
    }


    var _tabs_h = 44;


    draw_sprite_stretched(
        spr_textbox,
        scr_ui_box_frame(spr_textbox),
        _tabs_x,
        _tabs_y,
        _tabs_w,
        _tabs_h
    );


    var _tab_names =
    [
        scr_loc_src("STAD"),
        scr_loc_src("HABIL")
    ];


    var _tab_count =
        _habil_tab_available
        ?
        2
        :
        1;


    var _slot_w =
        _tabs_w / _tab_count;


    for (
        var _i = 0;
        _i < _tab_count;
        _i++
    )
    {
        var _left =
            _tabs_x + (_i * _slot_w);

        var _right =
            _left + _slot_w;


        if (
            _menu.stad_tab
            ==
            _i
        )
        {
            draw_set_color(c_yellow);

            draw_rectangle(
                _left + 6,
                _tabs_y + 7,
                _right - 6,
                _tabs_y + 36,
                true
            );
        }


        draw_set_color(
            (_menu.stad_tab == _i)
            ?
            c_yellow
            :
            c_orange
        );


        draw_set_halign(fa_center);

        draw_text(
            (_left + _right) * 0.5,
            _tabs_y + 8,
            scr_loc(
                _tab_names[_i]
            )
        );
    }


    draw_set_halign(fa_left);
    draw_set_color(c_white);


    // =====================================================
    // STAD
    // =====================================================

    if (_menu.stad_tab == 0)
    {
        return;
    }


    // =====================================================
    // INICIALIZAR ANIMACIÓN DE DETALLE HABIL
    // =====================================================

    if (
        !variable_instance_exists(
            _menu,
            "habil_info_window_ready"
        )
    )
    {
        _menu.habil_info_window_ready = true;

        _menu.habil_info_window_anim = 0;

        _menu.habil_info_window_speed = 1 / 8;

        _menu.habil_info_window_closing = false;

        _menu.habil_info_window_id = "";
    }


    var _habil_signal_open =
        _menu.habil_info_open
        &&
        _menu.habil_info_id != "";


    // -----------------------------------------------------
    // CIERRE ANIMADO
    // -----------------------------------------------------

    if (_menu.habil_info_window_closing)
    {
        _menu.habil_info_window_anim =
            max(
                0,
                _menu.habil_info_window_anim
                -
                _menu.habil_info_window_speed
            );


        // Mientras cierra mantenemos lógicamente el detalle
        // abierto para que Step_2 no permita navegar por detrás.
        if (_menu.habil_info_window_anim > 0)
        {
            _menu.habil_info_open = true;
            _menu.habil_info_id =
                _menu.habil_info_window_id;
        }
        else
        {
            _menu.habil_info_window_anim = 0;
            _menu.habil_info_window_closing = false;
            _menu.habil_info_open = false;
            _menu.habil_info_id = "";
            _menu.habil_info_window_id = "";
        }
    }

    // -----------------------------------------------------
    // APERTURA ANIMADA
    // -----------------------------------------------------

    else if (_habil_signal_open)
    {
        if (
            _menu.habil_info_window_id == ""
            ||
            _menu.habil_info_window_id
            !=
            _menu.habil_info_id
        )
        {
            _menu.habil_info_window_id =
                _menu.habil_info_id;
        }


        _menu.habil_info_window_anim =
            min(
                1,
                _menu.habil_info_window_anim
                +
                _menu.habil_info_window_speed
            );
    }

    // -----------------------------------------------------
    // STEP_2 ACABA DE PEDIR CERRAR
    // -----------------------------------------------------

    else if (
        _menu.habil_info_window_id != ""
        &&
        _menu.habil_info_window_anim > 0
    )
    {
        _menu.habil_info_window_closing = true;

        _menu.habil_info_window_anim =
            max(
                0,
                _menu.habil_info_window_anim
                -
                _menu.habil_info_window_speed
            );


        if (_menu.habil_info_window_anim > 0)
        {
            _menu.habil_info_open = true;
            _menu.habil_info_id =
                _menu.habil_info_window_id;
        }
        else
        {
            _menu.habil_info_window_closing = false;
            _menu.habil_info_window_id = "";
        }
    }


    var _detail_visual =
        _menu.habil_info_window_id != ""
        &&
        _menu.habil_info_window_anim > 0;


    // =====================================================
    // DETALLE HABIL ANIMADO
    // =====================================================

    if (_detail_visual)
    {
        // La interfaz HABIL normal permanece visible detrás
        // de la ficha modal.
        scr_menu_habil_draw_background(
            _menu,
            _box_x,
            _box_y,
            _box_w,
            _box_h
        );


        var _info =
            scr_habilidad_data(
                _menu.habil_info_window_id
            );


        var _desc =
            scr_loc(
                _info.descripcion
            );


        if (
            _menu.habil_info_window_id
            ==
            "dash"
        )
        {
            _desc =
                scr_loc(
                    "Permite hacer dash dentro del rango de peligro de un enemigo. Funciona con la habilidad Dash o con los Zapatos Rápidos."
                );
        }


        // La ficha ocupa EXACTAMENTE el mismo rectángulo que
        // el panel HABIL de fondo. Durante la animación se ve la
        // lista alrededor; al terminar, la ficha queda alineada
        // 1:1 con la ventana de fondo.
        var _modal_x =
            _box_x;

        var _modal_y =
            _box_y;

        var _modal_w =
            _box_w;

        var _modal_h =
            _box_h;


        var _detail_t =
            scr_menu_detail_ease(
                _menu.habil_info_window_anim
            );

        var _detail_cx =
            _modal_x + (_modal_w * 0.5);

        var _detail_cy =
            _modal_y + (_modal_h * 0.5);

        var _detail_w =
            max(
                2,
                _modal_w * _detail_t
            );

        var _detail_h =
            max(
                2,
                _modal_h * _detail_t
            );

        var _detail_x =
            _detail_cx - (_detail_w * 0.5);

        var _detail_y =
            _detail_cy - (_detail_h * 0.5);


        draw_set_color(c_black);

        draw_rectangle(
            _detail_x,
            _detail_y,
            _detail_x + _detail_w,
            _detail_y + _detail_h,
            false
        );


        draw_sprite_stretched_ext(
            spr_textbox,
            scr_ui_box_frame(spr_textbox),
            _detail_x,
            _detail_y,
            _detail_w,
            _detail_h,
            c_white,
            1
        );


        var _content_alpha =
            clamp(
                (_detail_t - 0.68) / 0.32,
                0,
                1
            );


        if (_content_alpha > 0)
        {
            var _detail_margin = 22;
            var _icon_size = 82;

            var _icon_x =
                _modal_x + _detail_margin;

            var _icon_y =
                _modal_y + 20;

            var _ability_icon = -1;


            if (
                variable_struct_exists(
                    _info,
                    "icono"
                )
            )
            {
                _ability_icon =
                    _info.icono;
            }


            scr_menu_detail_draw_icon(
                _ability_icon,
                _icon_x,
                _icon_y,
                _icon_size,
                _content_alpha
            );


            draw_set_alpha(_content_alpha);

            var _habil_name_x =
                _icon_x + _icon_size + 18;

            var _habil_name_w =
                max(
                    40,
                    (_modal_x + _modal_w - 22)
                    -
                    _habil_name_x
                );


            draw_set_color(c_yellow);

            draw_text_ext(
                _habil_name_x,
                _icon_y + 8,
                scr_loc(
                    _info.nombre
                ),
                26,
                _habil_name_w
            );


            draw_set_color(c_white);

            draw_text_ext(
                _modal_x + 26,
                _icon_y + _icon_size + 20,
                _desc,
                28,
                _modal_w - 52
            );


            draw_set_color(c_gray);
            draw_set_halign(fa_center);

            draw_text_transformed(
                _modal_x + (_modal_w * 0.5),
                _modal_y + _modal_h - 27,
                scr_loc(
                    scr_loc_src("Z / X - Cerrar")
                ),
                0.55,
                0.55,
                0
            );


            draw_set_halign(fa_left);
            draw_set_alpha(1);
            draw_set_color(c_white);
        }


        return;
    }


    // =====================================================
    // PANEL HABIL NORMAL
    // =====================================================

    draw_sprite_stretched(
        spr_textbox,
        scr_ui_box_frame(spr_textbox),
        _box_x,
        _box_y,
        _box_w,
        _box_h
    );


    // =====================================================
    // LISTA
    // =====================================================

    var _lista =
        scr_habilidades_lista_obtenidas();

    var _total =
        array_length(_lista);

    var _start_x =
        _box_x + 20;

    var _start_y =
        _box_y + 22;

    var _row_h = 56;
    var _list_icon_size = 36;


    if (_total <= 0)
    {
        draw_set_color(c_gray);

        draw_text(
            _start_x,
            _start_y,
            scr_loc(
                scr_loc_src(
                    "Todavía no tienes habilidades."
                )
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
                _idx - _menu.habil_scroll;

            var _row_y =
                _start_y + (_row * _row_h);

            var _selected =
                _idx == _menu.habil_index;

            var _ability_id =
                _lista[_idx];

            var _data =
                scr_habilidad_data(
                    _ability_id
                );


            if (_selected)
            {
                draw_set_color(c_yellow);

                draw_rectangle(
                    _start_x - 6,
                    _row_y - 5,
                    _box_x + _box_w - 18,
                    _row_y + 43,
                    true
                );
            }


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
                _data.icono != -1
                &&
                sprite_exists(_data.icono)
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
                _row_y + 7,
                scr_loc(
                    _data.nombre
                )
            );
        }
    }


    draw_set_color(c_white);
    draw_set_alpha(1);
    draw_set_halign(fa_left);
}
