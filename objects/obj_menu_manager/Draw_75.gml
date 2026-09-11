/// =========================================================
/// DESVELO - PLATAFORMERO V2
/// PANEL IZQUIERDO CON BOTÓN EXTRA
/// =========================================================

var _platformer_pause_active =
(
    variable_global_exists(
        "platformer_active"
    )
    &&
    global.platformer_active
    &&
    state != MENU_STATE.CLOSED
    &&
    state != MENU_STATE.EXITING
);


if (_platformer_pause_active)
{
    if (variable_global_exists("font_main"))
    {
        draw_set_font(
            global.font_main
        );
    }


    var _pm_x =
        80;


    var _pm_y =
        80;


    var _pm_w =
        130;


    var _pm_h =
        308;


    // Redibujar TODO el panel izquierdo para que la opción
    // sustituta main_index=4 no deje CERRAR amarillo cuando
    // realmente está seleccionada la sexta opción.
    draw_sprite_stretched(
        spr_textbox,
        scr_ui_box_frame(spr_textbox),
        _pm_x,
        _pm_y,
        _pm_w,
        _pm_h
    );


    var _pm_selected =
        0;


    if (
        variable_instance_exists(
            id,
            "platform_main_index"
        )
    )
    {
        _pm_selected =
            platform_main_index;
    }
    else
    {
        _pm_selected =
            main_index;
    }


    draw_set_halign(
        fa_left
    );


    draw_set_valign(
        fa_top
    );


    // Las cinco opciones existentes.
    for (
        var _pm_i = 0;
        _pm_i < array_length(main_options);
        _pm_i++
    )
    {
        draw_set_color(
            (
                state == MENU_STATE.MAIN
                &&
                _pm_selected == _pm_i
            )
            ?
            c_yellow
            :
            c_orange
        );


        draw_text(
            _pm_x + 16,
            _pm_y + 12 + (_pm_i * 46),
            scr_loc(
                main_options[_pm_i]
            )
        );
    }


    // Sexta opción.
    draw_set_color(
        (
            state == MENU_STATE.MAIN
            &&
            _pm_selected == 5
        )
        ?
        c_yellow
        :
        c_orange
    );


    draw_text_transformed(
        _pm_x + 16,
        _pm_y + 12 + (5 * 46),
        "CAMBIAR Z/X",
        0.66,
        0.66,
        0
    );


    // Mostrar SALTO y ATAQUE en DOS líneas.
    // ATAQUE queda exactamente debajo de SALTO.
    var _pm_jump_key =
        (
            global.platformer_controls_swapped
            ?
            "X"
            :
            "Z"
        );


    var _pm_attack_key =
        (
            global.platformer_controls_swapped
            ?
            "Z"
            :
            "X"
        );


    draw_set_color(
        c_white
    );


    draw_text_transformed(
        _pm_x + 16,
        _pm_y + 28 + (5 * 46),
        "SALTO " + _pm_jump_key,
        0.48,
        0.48,
        0
    );


    draw_text_transformed(
        _pm_x + 16,
        _pm_y + 41 + (5 * 46),
        "ATAQUE " + _pm_attack_key,
        0.48,
        0.48,
        0
    );


    draw_set_color(
        c_white
    );


    // =====================================================
    // HUD DE VIDA DEBAJO DEL MENÚ
    // =====================================================

    var _pm_heal_amount =
        0;


    if (
        variable_global_exists(
            "platformer_heal_hud_timer"
        )
        &&
        global.platformer_heal_hud_timer > 0
        &&
        variable_global_exists(
            "platformer_heal_amount"
        )
    )
    {
        _pm_heal_amount =
            global.platformer_heal_amount;
    }


    scr_platformer_draw_player_hp_hud(
        _pm_x,
        _pm_y + _pm_h + 8,
        _pm_heal_amount
    );
}


/// =========================================================
/// OBJ_MENU_MANAGER
/// DRAW GUI END
/// =========================================================
///
/// CONFIG V3
///
/// Este evento redibuja COMPLETAMENTE el panel CONFIG encima
/// de su version anterior.
///
/// Asi conseguimos:
//
//  - eliminar las pestañas viejas internas;
//  - eliminar "Configuracion de controles";
//  - eliminar "Proximamente...";
//  - dibujar General / Controles arriba como INV/EQUIP/CLAVE;
//  - dibujar la ventana inferior animada;
//  - dibujar Controles con texto mas grande;
//  - eliminar por completo el selector ">".
// =========================================================


// =========================================================
// AJUSTE DE PESTAÑAS INV / EQUIP / CLAVE
// =========================================================
//
// El Draw GUI normal ya dibuja estas pestañas con su propia
// animacion.
//
// Aqui volvemos a dibujar exactamente la misma caja en la
// misma posicion animada para:
//
//     - tapar el texto anterior;
//     - conservar la animacion intacta;
//     - subir un poco INV / EQUIP / CLAVE en Y.
//
// No cambia ninguna logica del inventario.
// =========================================================

var _show_inventory_tabs_v4 =
(
    (
        state >= MENU_STATE.INVENTORY
        &&
        state <= MENU_STATE.ITEM_DROP_CONFIRM
    )
    ||
    (
        state >= MENU_STATE.EQUIP_MENU
        &&
        state <= MENU_STATE.EQUIP_DROP_CONFIRM
    )
    ||
    state == MENU_STATE.CLAVE_MENU
);


if (_show_inventory_tabs_v4)
{
    var _inv_tab_t_v4 =
        1
        -
        power(
            1 - inventory_tab_slide,
            3
        );


    var _inv_tab_box_x_v4 =
        222;


    var _inv_tab_final_y_v4 =
        28;


    var _inv_tab_hidden_y_v4 =
        88;


    var _inv_tab_box_y_v4 =
        lerp(
            _inv_tab_hidden_y_v4,
            _inv_tab_final_y_v4,
            _inv_tab_t_v4
        );


    var _inv_tab_box_w_v4 =
        346;


    var _inv_tab_box_h_v4 =
        44;


    draw_sprite_stretched(
        spr_textbox,
        scr_ui_box_frame(spr_textbox),
        _inv_tab_box_x_v4,
        _inv_tab_box_y_v4,
        _inv_tab_box_w_v4,
        _inv_tab_box_h_v4
    );


    var _inv_active_tab_v4 =
        0;


    if (
        state >= MENU_STATE.EQUIP_MENU
        &&
        state <= MENU_STATE.EQUIP_DROP_CONFIRM
    )
    {
        _inv_active_tab_v4 =
            1;
    }
    else if (state == MENU_STATE.CLAVE_MENU)
    {
        _inv_active_tab_v4 =
            2;
    }


    var _inv_tab_names_v4 =
    [
        scr_loc_src("INV"),
        scr_loc_src("EQUIP"),
        scr_loc_src("CLAVE")
    ];


    var _inv_tab_slot_w_v4 =
        _inv_tab_box_w_v4 / 3;


    for (
        var _inv_tab_i_v4 = 0;
        _inv_tab_i_v4 < 3;
        _inv_tab_i_v4++
    )
    {
        var _inv_slot_left_v4 =
            _inv_tab_box_x_v4
            +
            (
                _inv_tab_i_v4
                *
                _inv_tab_slot_w_v4
            );


        var _inv_slot_right_v4 =
            _inv_slot_left_v4
            +
            _inv_tab_slot_w_v4;


        if (
            inventory_tab_focus
            &&
            _inv_tab_i_v4 == _inv_active_tab_v4
        )
        {
            draw_set_color(
                c_yellow
            );


            draw_rectangle(
                _inv_slot_left_v4 + 6,
                _inv_tab_box_y_v4 + 7,
                _inv_slot_right_v4 - 6,
                _inv_tab_box_y_v4 + 36,
                true
            );
        }


        draw_set_color(
            _inv_tab_i_v4 == _inv_active_tab_v4
            ?
            c_yellow
            :
            c_orange
        );


        draw_set_halign(
            fa_center
        );


        // Antes estaba visualmente un poco bajo.
        // +8 lo centra mejor dentro de la caja de 44 px.
        draw_text(
            (_inv_slot_left_v4 + _inv_slot_right_v4) * 0.5,
            _inv_tab_box_y_v4 + 8,
            scr_loc(
                _inv_tab_names_v4[
                    _inv_tab_i_v4
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
}


// =========================================================
// HUD DE CURACIÓN DESPUÉS DE CERRAR EL MENÚ
// =========================================================
//
// Al consumir un item, el menú se cierra.
//
// Mientras queden frames del timer, dejamos la misma caja
// donde estaba físicamente debajo del panel.
//
// En los últimos 12 frames:
//     - baja fuera de la pantalla;
//     - hace fade-out;
//     - usa el mismo smoothstep del HUD de enemigo.
//
//     X = 0
//     Y = 396
//
// Como el menú ya está cerrado, Draw GUI Begin no aplica
// la traslación -80, por eso usamos X=0 directamente.
// =========================================================

var _platformer_heal_hud_active =
(
    variable_global_exists(
        "platformer_active"
    )
    &&
    global.platformer_active
    &&
    variable_global_exists(
        "platformer_heal_hud_timer"
    )
    &&
    global.platformer_heal_hud_timer > 0
);


if (
    _platformer_heal_hud_active
    &&
    !_platformer_pause_active
)
{
    var _heal_amount_draw =
        (
            variable_global_exists(
                "platformer_heal_amount"
            )
            ?
            global.platformer_heal_amount
            :
            0
        );


    // =====================================================
    // SALIDA DESLIZÁNDOSE HACIA ABAJO
    // =====================================================
    //
    // Replica el comportamiento del HUD de enemigo:
    //
    //     12 frames
    //     smoothstep
    //     baja fuera de pantalla
    //     fade-out simultáneo
    //
    // Durante el resto del timer permanece totalmente quieto.
    // =====================================================

    var _heal_exit_frames =
        12;


    var _heal_timer_now =
        global.platformer_heal_hud_timer;


    var _heal_slide_t =
        clamp(
            _heal_timer_now
            /
            _heal_exit_frames,
            0,
            1
        );


    var _heal_slide_ease =
        _heal_slide_t
        *
        _heal_slide_t
        *
        (
            3
            -
            (2 * _heal_slide_t)
        );


    var _heal_gui_w =
        display_get_gui_width();


    var _heal_gui_h =
        display_get_gui_height();


    var _heal_scale =
        min(
            _heal_gui_w / 320,
            _heal_gui_h / 240
        )
        *
        0.78;


    var _heal_target_y =
        396;


    var _heal_hidden_y =
        _heal_gui_h
        +
        (10 * _heal_scale);


    var _heal_draw_y =
        lerp(
            _heal_hidden_y,
            _heal_target_y,
            _heal_slide_ease
        );


    scr_platformer_draw_player_hp_hud(
        0,
        _heal_draw_y,
        _heal_amount_draw,
        _heal_slide_ease
    );
}


// =========================================================
// STAD / HABIL - INTEGRADO DIRECTAMENTE EN OBJ_MENU_MANAGER
// =========================================================
//
// IMPORTANTE:
// Este llamado ocurre ANTES del "SOLO CONFIG" y por tanto
// también se ejecuta cuando state == INFO_MENU.
// =========================================================

scr_menu_stad_habil_draw(
    id
);


// =========================================================
// SOLO CONFIG
// =========================================================

if (
    state != MENU_STATE.CONFIG_MENU

    &&

    state != MENU_STATE.CONFIG_ACTION
)
{
    // Restaurar la matriz antes de salir del evento.
    if (
        variable_instance_exists(
            id,
            "platformer_menu_matrix_active"
        )
        &&
        platformer_menu_matrix_active
    )
    {
        matrix_set(
            matrix_world,
            platformer_menu_matrix_previous
        );


        platformer_menu_matrix_active =
            false;
    }


    exit;
}


// =========================================================
// RESPALDO DE VARIABLES
// =========================================================

if (
    !variable_instance_exists(
        id,
        "controls_system_ready"
    )
)
{
    controls_system_ready =
        true;


    controls_index =
        0;


    controls_scroll =
        0;


    controls_visible_rows =
        6;


    controls_listening =
        false;


    controls_wait_release =
        false;


    controls_message =
        "";


    controls_message_timer =
        0;


    controls_was_action =
        false;


    controls_repeat_dir =
        0;


    controls_repeat_timer =
        0;


    controls_repeat_delay =
        10;


    controls_repeat_rate =
        3;


    controls_tab_slide =
        1;


    controls_tab_slide_speed =
        1 / 12;


    controls_notice_slide =
        0;


    controls_notice_slide_speed =
        1 / 12;


    controls_notice_cached_text =
        "";


    controls_notice_cached_yellow =
        false;


    scr_config_data();


    scr_controls_apply();
}


// =========================================================
// DRAW BASE
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
// COORDENADAS EXACTAS DEL CONFIG ACTUAL
// =========================================================

var _box_x =
    222;


var _box_y =
    80;


var _box_w =
    346;


var _box_h =
    308;


// =========================================================
// EASE-OUT CUBICO DE PESTAÑAS
// =========================================================

var _tab_t =
    1
    -
    power(
        1 - controls_tab_slide,
        3
    );


// =========================================================
// PESTAÑAS GENERAL / CONTROLES
// =========================================================
//
// Misma geometria y movimiento que:
//
//     INV / EQUIP / CLAVE
//
// La caja empieza dentro del panel:
//
//     y = _box_y + 8
//
// y termina arriba:
//
//     y = _box_y - 52
//
// Luego el panel grande se redibuja DESPUES para ocultar la
// parte superpuesta. Visualmente parece salir desde detras.
// =========================================================

var _tabs_x =
    _box_x;


var _tabs_w =
    _box_w;


var _tabs_h =
    44;


var _tabs_hidden_y =
    _box_y + 8;


var _tabs_final_y =
    _box_y - 52;


var _tabs_y =
    lerp(
        _tabs_hidden_y,
        _tabs_final_y,
        _tab_t
    );


draw_sprite_stretched(
    spr_textbox,
    scr_ui_box_frame(spr_textbox),
    _tabs_x,
    _tabs_y,
    _tabs_w,
    _tabs_h
);


var _tab_slot_w =
    _tabs_w / 2;


var _tab_names =
[
    "General",
    "Controles"
];


for (
    var _tab_i = 0;
    _tab_i < 2;
    _tab_i++
)
{
    var _slot_left =
        _tabs_x
        +
        (
            _tab_i
            *
            _tab_slot_w
        );


    var _slot_right =
        _slot_left
        +
        _tab_slot_w;


    // Cuando estamos sobre las pestañas, marcar la activa
    // igual que INV / EQUIP / CLAVE.
    if (
        state == MENU_STATE.CONFIG_MENU

        &&

        config_tab == _tab_i
    )
    {
        draw_set_color(
            c_yellow
        );


        draw_rectangle(
            _slot_left + 6,
            _tabs_y + 7,
            _slot_right - 6,
            _tabs_y + 36,
            true
        );
    }


    draw_set_color(
        config_tab == _tab_i
        ?
        c_yellow
        :
        c_orange
    );


    draw_set_halign(
        fa_center
    );


    draw_text(
        (_slot_left + _slot_right) * 0.5,
        _tabs_y + 8,
        _tab_names[_tab_i]
    );
}


draw_set_halign(
    fa_left
);


// =========================================================
// VENTANA INFERIOR DE MENSAJES
// =========================================================
//
// Ahora se dibuja mientras:
//
//     controls_notice_slide > 0
//
// no solamente mientras el mensaje esta activo.
//
// Esto permite:
//
//     aparecer:
//         hidden -> final
//
//     desaparecer:
//         final -> hidden
//
// con la MISMA animacion reproducida en reversa.
//
// El texto se conserva en:
//     controls_notice_cached_text
//
// hasta terminar completamente la salida.
// =========================================================

if (controls_notice_slide > 0)
{
    var _notice_t =
        1
        -
        power(
            1 - controls_notice_slide,
            3
        );


    var _notice_x =
        _box_x;


    var _notice_w =
        _box_w;


    var _notice_h =
        48;


    var _notice_hidden_y =
        _box_y
        +
        _box_h
        -
        _notice_h;


    var _notice_final_y =
        _box_y
        +
        _box_h
        +
        8;


    var _notice_y =
        lerp(
            _notice_hidden_y,
            _notice_final_y,
            _notice_t
        );


    draw_sprite_stretched(
        spr_textbox,
        scr_ui_box_frame(spr_textbox),
        _notice_x,
        _notice_y,
        _notice_w,
        _notice_h
    );


    draw_set_halign(
        fa_center
    );


    draw_set_color(
        controls_notice_cached_yellow
        ?
        c_yellow
        :
        c_white
    );


    draw_text_transformed(
        _notice_x + (_notice_w * 0.5),
        _notice_y + 11,
        controls_notice_cached_text,
        0.68,
        0.68,
        0
    );


    draw_set_halign(
        fa_left
    );
}


// =========================================================
// REDIBUJAR PANEL PRINCIPAL LIMPIO
// =========================================================
//
// Esto tapa:
//
// - las pestañas internas antiguas;
// - "Configuracion de controles";
// - "Proximamente...";
// - la parte de las ventanas animadas que sigue detras.
//
// NO necesitamos modificar el Draw GUI original.
/// =========================================================

draw_sprite_stretched(
    spr_textbox,
    scr_ui_box_frame(spr_textbox),
    _box_x,
    _box_y,
    _box_w,
    _box_h
);


// =========================================================
// PESTAÑA GENERAL
// =========================================================
//
// Como acabamos de limpiar el panel, volvemos a dibujar
// las opciones General que ya tenia tu menu.
// =========================================================

if (config_tab == 0)
{
    var _general_start_y =
        _box_y + 28;


    var _general_spacing =
        52;


    var _general_names =
    [
        "Volumen General",
        "Pantalla Comp",
        "Auto-correr",
        "Volver"
    ];


    var _general_values =
    [
        string(
            round(
                master_volume * 100
            )
        )
        +
        "%",

        fullscreen_enabled
        ?
        scr_loc("Si")
        :
        scr_loc("No"),

        global.autocorrer_enabled
        ?
        scr_loc("Si")
        :
        scr_loc("No"),

        ""
    ];


    for (
        var _gi = 0;
        _gi < 4;
        _gi++
    )
    {
        var _selected_general =
        (
            state == MENU_STATE.CONFIG_ACTION

            &&

            config_index == _gi
        );


        draw_set_color(
            _selected_general
            ?
            c_yellow
            :
            c_orange
        );


        draw_text(
            _box_x + 24,
            _general_start_y
            +
            (
                _gi
                *
                _general_spacing
            ),
            scr_loc(
                _general_names[_gi]
            )
        );


        if (_general_values[_gi] != "")
        {
            draw_set_color(
                _selected_general
                ?
                c_yellow
                :
                c_white
            );


            draw_set_halign(
                fa_right
            );


            draw_text(
                _box_x + _box_w - 24,
                _general_start_y
                +
                (
                    _gi
                    *
                    _general_spacing
                ),
                _general_values[_gi]
            );


            draw_set_halign(
                fa_left
            );
        }
    }
}


// =========================================================
// PESTAÑA CONTROLES
// =========================================================

else
{
    // -----------------------------------------------------
    // ENCABEZADOS
    // -----------------------------------------------------

    var _name_x =
        _box_x + 24;


    var _key_x =
        _box_x + 232;


    var _header_y =
        _box_y + 20;


    var _list_y =
        _box_y + 54;


    var _line_h =
        38;


    draw_set_color(
        c_ltgray
    );


    draw_text_transformed(
        _name_x,
        _header_y,
        "Funcion",
        0.84,
        0.84,
        0
    );


    draw_text_transformed(
        _key_x,
        _header_y,
        "Tecla",
        0.84,
        0.84,
        0
    );


    // -----------------------------------------------------
    // DATOS
    // -----------------------------------------------------

    var _names =
    [
        "Abajo",
        "Derecha",
        "Arriba",
        "Izquierda",
        "Confirmar",
        "Cancelar/Correr",
        "Menu",
        "Restaurar predeterminado"
    ];


    var _total =
        array_length(
            _names
        );


    var _max_scroll =
        max(
            0,
            _total
            -
            controls_visible_rows
        );


    controls_scroll =
        clamp(
            controls_scroll,
            0,
            _max_scroll
        );


    // -----------------------------------------------------
    // FILAS VISIBLES
    // -----------------------------------------------------

    for (
        var _row = 0;
        _row < controls_visible_rows;
        _row++
    )
    {
        var _index =
            controls_scroll
            +
            _row;


        if (_index >= _total)
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
            state == MENU_STATE.CONFIG_ACTION

            &&

            controls_index == _index
        );


        draw_set_color(
            _selected
            ?
            c_yellow
            :
            c_white
        );


        // -------------------------------------------------
        // RESTAURAR PREDETERMINADO
        // -------------------------------------------------

        if (_index == 7)
        {
            draw_text_transformed(
                _name_x,
                _y,
                "Restaurar predeterminado",
                0.80,
                0.80,
                0
            );
        }

        // -------------------------------------------------
        // CONTROLES NORMALES
        // -------------------------------------------------

        else
        {
            var _name_scale =
                0.86;


            if (_index == 5)
            {
                _name_scale =
                    0.76;
            }


            draw_text_transformed(
                _name_x,
                _y,
                _names[_index],
                _name_scale,
                _name_scale,
                0
            );


            var _key_text =
                "";


            if (
                controls_listening

                &&

                controls_index == _index
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
                0.86,
                0.86,
                0
            );
        }
    }


    // =====================================================
    // SCROLLBAR
    // =====================================================

    if (_max_scroll > 0)
    {
        var _bar_x =
            _box_x
            +
            _box_w
            -
            19;


        var _bar_y =
            _list_y
            +
            3;


        var _bar_h =
            (
                controls_visible_rows
                *
                _line_h
            )
            -
            18;


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
                controls_scroll
                /
                _max_scroll
            )
            *
            _bar_h;


        draw_set_color(
            c_white
        );


        draw_rectangle(
            _bar_x - 4,
            _thumb_y - 4,
            _bar_x + 4,
            _thumb_y + 4,
            false
        );
    }
}


// =========================================================
// AJUSTE VISUAL FINAL DE LAS VENTANAS HP / AT / DEF
// =========================================================
//
// El Draw GUI normal ya dibuja estas ventanas y mantiene su
// animacion de entrada.
//
// Cuando ya terminaron de salir completamente de detras del
// panel, las redibujamos encima para:
//
//     - subir un pelin el texto;
//     - dejarlo mejor centrado verticalmente.
//
// Durante la entrada NO hacemos este redraw, para no romper
// el efecto de quedar por detras del panel.
/// =========================================================

if (
    info_stat_slide >= 0.999

    &&

    (
        state == MENU_STATE.ITEM_INFO

        ||

        state == MENU_STATE.EQUIP_INFO
    )
)
{
    var _stat_x =
        _box_x;


    var _stat_w =
        _box_w;


    var _stat_h =
        48;


    var _stat_y =
        _box_y
        +
        _box_h
        +
        8;


    var _stat_text =
        "";


    // -----------------------------------------------------
    // ITEM -> HP
    // -----------------------------------------------------

    if (
        state == MENU_STATE.ITEM_INFO

        &&

        instance_exists(obj_player)
    )
    {
        var _stat_item_index =
            min(
                (inv_y + inv_scroll) * 3 + inv_x,
                array_length(obj_player.inventory) - 1
            );


        var _stat_item_key =
            obj_player.inventory[
                _stat_item_index
            ];


        if (
            _stat_item_key != -1
            &&
            !is_undefined(_stat_item_key)
        )
        {
            var _stat_item_info =
                variable_struct_get(
                    global.item_db,
                    _stat_item_key
                );


            if (_stat_item_info != undefined)
            {
                var _stat_hp =
                    (
                        variable_struct_exists(
                            _stat_item_info,
                            "curacion_hp"
                        )
                    )
                    ?
                    _stat_item_info.curacion_hp
                    :
                    0;


                _stat_text =
                    "HP +" + string(_stat_hp);
            }
        }
    }


    // -----------------------------------------------------
    // EQUIP -> AT / DEF
    // -----------------------------------------------------

    else if (state == MENU_STATE.EQUIP_INFO)
    {
        var _stat_eq_index =
            min(
                (equip_y + equip_scroll) * 3 + equip_x,
                array_length(equipment) - 1
            );


        var _stat_eq_key =
            equipment[
                _stat_eq_index
            ];


        if (
            _stat_eq_key != -1
            &&
            !is_undefined(_stat_eq_key)
        )
        {
            var _stat_eq_info =
                variable_struct_get(
                    global.equip_db,
                    _stat_eq_key
                );


            if (_stat_eq_info != undefined)
            {
                var _stat_at =
                    (
                        variable_struct_exists(
                            _stat_eq_info,
                            "ataque"
                        )
                    )
                    ?
                    _stat_eq_info.ataque
                    :
                    0;


                var _stat_df =
                    (
                        variable_struct_exists(
                            _stat_eq_info,
                            "defensa"
                        )
                    )
                    ?
                    _stat_eq_info.defensa
                    :
                    0;


                if (_stat_at > 0)
                {
                    _stat_text =
                        "AT +" + string(_stat_at);
                }


                if (_stat_df > 0)
                {
                    if (_stat_text != "")
                    {
                        _stat_text +=
                            "    ";
                    }


                    _stat_text +=
                        "DEF +" + string(_stat_df);
                }


                if (_stat_text == "")
                {
                    _stat_text =
                        scr_loc(
                            scr_loc_src(
                                "Sin bonificacion"
                            )
                        );
                }
            }
        }
    }


    if (_stat_text != "")
    {
        draw_sprite_stretched(
            spr_textbox,
            scr_ui_box_frame(spr_textbox),
            _stat_x,
            _stat_y,
            _stat_w,
            _stat_h
        );


        draw_set_color(
            c_yellow
        );


        // Antes estaba visualmente un poco bajo.
        // +7 lo deja mejor centrado en la caja de 48px.
        draw_text(
            _stat_x + 16,
            _stat_y + 7,
            _stat_text
        );
    }
}


// =========================================================
// RESTAURAR DRAW
// =========================================================

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


// =========================================================
// PLATAFORMERO V2 - RESTAURAR MATRIZ GUI
// =========================================================

if (
    variable_instance_exists(
        id,
        "platformer_menu_matrix_active"
    )
    &&
    platformer_menu_matrix_active
)
{
    matrix_set(
        matrix_world,
        platformer_menu_matrix_previous
    );


    platformer_menu_matrix_active =
        false;
}
