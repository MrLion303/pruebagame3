/// =========================================================
/// OBJ_MENU_MANAGER
/// DRAW GUI BEGIN
/// =========================================================
///
/// ANIMACION OUT DE LAS VENTANAS:
//
//     HP
//     AT
//     DEF
//
// El Draw GUI normal ya tiene su animacion IN.
//
// Este evento agrega la misma animacion en reversa cuando
// dejamos ITEM_INFO o EQUIP_INFO.
//
// Se dibuja en Draw GUI Begin para que despues:
//
//     obj_menu_manager -> Draw GUI
//
// dibuje el panel principal ENCIMA.
//
// Asi la ventana realmente vuelve a esconderse por detras,
// igual que cuando aparecio.
// =========================================================


// =========================================================
// FUENTE
// =========================================================

if (variable_global_exists("font_main"))
{
    draw_set_font(
        global.font_main
    );
}


// =========================================================
// INICIALIZAR ESTADO DE SALIDA
// =========================================================

if (
    !variable_instance_exists(
        id,
        "extra_stat_out_ready"
    )
)
{
    extra_stat_out_ready =
        true;


    extra_stat_prev_active =
        false;


    extra_stat_prev_type =
        0;


    extra_stat_cached_text =
        "";


    extra_stat_out_slide =
        0;


    extra_stat_out_speed =
        1 / 12;
}


// =========================================================
// ESTADO ACTUAL
// =========================================================

var _active_item =
(
    state == MENU_STATE.ITEM_INFO
);


var _active_equip =
(
    state == MENU_STATE.EQUIP_INFO
);


var _active_now =
(
    _active_item

    ||

    _active_equip
);


// =========================================================
// MIENTRAS ESTA ABIERTA: CACHEAR SU TEXTO ACTUAL
// =========================================================

if (_active_now)
{
    var _cache_text =
        "";


    var _cache_type =
        (
            _active_item
            ?
            1
            :
            2
        );


    // -----------------------------------------------------
    // ITEM -> HP
    // -----------------------------------------------------

    if (
        _active_item

        &&

        instance_exists(obj_player)
    )
    {
        var _item_index =
            min(
                (inv_y + inv_scroll) * 3 + inv_x,
                array_length(obj_player.inventory) - 1
            );


        var _item_key =
            obj_player.inventory[
                _item_index
            ];


        if (
            _item_key != -1
            &&
            !is_undefined(_item_key)
        )
        {
            var _item_info =
                variable_struct_get(
                    global.item_db,
                    _item_key
                );


            if (_item_info != undefined)
            {
                var _hp =
                    (
                        variable_struct_exists(
                            _item_info,
                            "curacion_hp"
                        )
                    )
                    ?
                    _item_info.curacion_hp
                    :
                    0;


                _cache_text =
                    "HP +" + string(_hp);
            }
        }
    }


    // -----------------------------------------------------
    // EQUIP -> AT / DEF
    // -----------------------------------------------------

    else if (_active_equip)
    {
        var _eq_index =
            min(
                (equip_y + equip_scroll) * 3 + equip_x,
                array_length(equipment) - 1
            );


        var _eq_key =
            equipment[
                _eq_index
            ];


        if (
            _eq_key != -1
            &&
            !is_undefined(_eq_key)
        )
        {
            var _eq_info =
                variable_struct_get(
                    global.equip_db,
                    _eq_key
                );


            if (_eq_info != undefined)
            {
                var _at =
                    (
                        variable_struct_exists(
                            _eq_info,
                            "ataque"
                        )
                    )
                    ?
                    _eq_info.ataque
                    :
                    0;


                var _df =
                    (
                        variable_struct_exists(
                            _eq_info,
                            "defensa"
                        )
                    )
                    ?
                    _eq_info.defensa
                    :
                    0;


                if (_at > 0)
                {
                    _cache_text =
                        "AT +" + string(_at);
                }


                if (_df > 0)
                {
                    if (_cache_text != "")
                    {
                        _cache_text +=
                            "    ";
                    }


                    _cache_text +=
                        "DEF +" + string(_df);
                }


                if (_cache_text == "")
                {
                    _cache_text =
                        scr_loc(
                            scr_loc_src(
                                "Sin bonificacion"
                            )
                        );
                }
            }
        }
    }


    if (_cache_text != "")
    {
        extra_stat_cached_text =
            _cache_text;


        extra_stat_prev_type =
            _cache_type;
    }


    extra_stat_prev_active =
        true;


    // Mientras esta abierta no dibujamos OUT.
    extra_stat_out_slide =
        0;
}


// =========================================================
// ACABA DE CERRARSE -> INICIAR OUT DESDE 1
// =========================================================

else if (extra_stat_prev_active)
{
    extra_stat_prev_active =
        false;


    extra_stat_out_slide =
        1;
}


// =========================================================
// DIBUJAR OUT
// =========================================================

if (
    !_active_now

    &&

    extra_stat_out_slide > 0

    &&

    extra_stat_cached_text != ""
)
{
    // -----------------------------------------------------
    // MISMAS COORDENADAS DEL PANEL INVENTARIO / EQUIP
    // -----------------------------------------------------

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


    var _box_x =
        _m_x + _m_w + 12;


    var _box_y =
        _m_y;


    var _box_w =
        346;


    var _box_h =
        308;


    var _stat_h =
        48;


    // -----------------------------------------------------
    // EXACTO REVERSO DEL EASE-OUT DE ENTRADA
    // -----------------------------------------------------
    //
    // extra_stat_out_slide:
    //
    //     1 -> 0
    //
    // usando la misma funcion:
    //
    //     1 - (1 - t)^3
    //
    // Esto es literalmente reproducir el movimiento
    // original hacia atras.
    // -----------------------------------------------------

    var _t =
        1
        -
        power(
            1 - extra_stat_out_slide,
            3
        );


    var _hidden_y =
        _box_y
        +
        _box_h
        -
        _stat_h;


    var _final_y =
        _box_y
        +
        _box_h
        +
        8;


    var _stat_y =
        lerp(
            _hidden_y,
            _final_y,
            _t
        );


    draw_sprite_stretched(
        spr_textbox,
        scr_ui_box_frame(spr_textbox),
        _box_x,
        _stat_y,
        _box_w,
        _stat_h
    );


    draw_set_color(
        c_yellow
    );


    // Texto un pelin mas arriba que antes.
    draw_text(
        _box_x + 16,
        _stat_y + 7,
        extra_stat_cached_text
    );


    // -----------------------------------------------------
    // AVANZAR SALIDA
    // -----------------------------------------------------

    extra_stat_out_slide =
        max(
            0,
            extra_stat_out_slide
            -
            extra_stat_out_speed
        );
}


draw_set_color(
    c_white
);
