/// =========================================================
/// SCR_SHOP_STOCK_SYSTEM
/// =========================================================
///
/// Stock persistente para las tiendas.
///
/// - "infinito" o -1 = compras ilimitadas.
/// - cualquier número >= 0 = máximo total de compras.
/// - el contador se guarda dentro de global.cutscene_flags,
///   así que entra automáticamente al save actual.
/// - cuando una entrada llega a 0, se convierte visualmente
///   en "Agotado" y deja de poder seleccionarse/comprarse.
/// - las Tijeras Jardín también quedan agotadas si el jugador
///   ya las tiene en el inventario CLAVE.
/// =========================================================


// =========================================================
// NORMALIZAR LÍMITE
// =========================================================

function scr_shop_stock_limit_value(_value)
{
    if (is_string(_value))
    {
        var _text =
            string_lower(
                string(_value)
            );


        if (
            _text == "infinito"
            ||
            _text == "infinite"
            ||
            _text == "inf"
        )
        {
            return -1;
        }


        var _number =
            real(_value);


        if (_number < 0)
        {
            return -1;
        }


        return max(
            0,
            floor(_number)
        );
    }


    if (is_real(_value))
    {
        if (_value < 0)
        {
            return -1;
        }


        return max(
            0,
            floor(_value)
        );
    }


    return -1;
}


// =========================================================
// CLAVE PERSISTENTE
// =========================================================

function scr_shop_stock_save_key(
    _shop_id,
    _tipo,
    _id
)
{
    return
        "__shopstock__"
        +
        string(_shop_id)
        +
        "__"
        +
        string(_tipo)
        +
        "__"
        +
        string(_id);
}


// =========================================================
// COMPRAS REALIZADAS
// =========================================================

function scr_shop_stock_purchased_count(
    _shop_id,
    _tipo,
    _id
)
{
    scr_cutscene_flags_init();


    var _key =
        scr_shop_stock_save_key(
            _shop_id,
            _tipo,
            _id
        );


    if (
        !variable_struct_exists(
            global.cutscene_flags,
            _key
        )
    )
    {
        return 0;
    }


    var _value =
        variable_struct_get(
            global.cutscene_flags,
            _key
        );


    if (!is_real(_value))
    {
        return 0;
    }


    return max(
        0,
        floor(_value)
    );
}


function scr_shop_stock_register_purchase(
    _shop_id,
    _tipo,
    _id,
    _limit,
    _amount = 1
)
{
    var _limit_value =
        scr_shop_stock_limit_value(
            _limit
        );


    // Infinito: no hace falta escribir nada en el save.
    if (_limit_value < 0)
    {
        return;
    }


    scr_cutscene_flags_init();


    var _key =
        scr_shop_stock_save_key(
            _shop_id,
            _tipo,
            _id
        );


    var _current =
        scr_shop_stock_purchased_count(
            _shop_id,
            _tipo,
            _id
        );


    var _new_value =
        min(
            _limit_value,
            _current
            +
            max(0, floor(_amount))
        );


    variable_struct_set(
        global.cutscene_flags,
        _key,
        _new_value
    );
}


// =========================================================
// STOCK RESTANTE
// =========================================================

function scr_shop_stock_remaining(
    _shop_id,
    _tipo,
    _id,
    _limit
)
{
    // Las Tijeras Jardín son un objeto CLAVE único.
    // Si ya existen en CLAVE (por compra anterior, save viejo
    // o incluso un pickup de pruebas), la tienda debe mostrarlas
    // como agotadas aunque el contador de stock todavía no exista.
    if (
        _id == "tijeras_jardin"
        &&
        scr_itemclave_tiene("tijeras_jardin")
    )
    {
        return 0;
    }


    var _limit_value =
        scr_shop_stock_limit_value(
            _limit
        );


    if (_limit_value < 0)
    {
        return -1;
    }


    return max(
        0,
        _limit_value
        -
        scr_shop_stock_purchased_count(
            _shop_id,
            _tipo,
            _id
        )
    );
}


function scr_shop_stock_entry_is_exhausted(
    _shop_id,
    _entry
)
{
    if (
        is_undefined(_entry)
        ||
        !is_struct(_entry)
    )
    {
        return false;
    }


    var _tipo =
        variable_struct_exists(
            _entry,
            "stock_original_tipo"
        )
        ?
        _entry.stock_original_tipo
        :
        _entry.tipo;


    var _id =
        variable_struct_exists(
            _entry,
            "stock_original_id"
        )
        ?
        _entry.stock_original_id
        :
        variable_struct_get(
            _entry,
            "id"
        );


    var _limit =
        variable_struct_exists(
            _entry,
            "cantidad_max"
        )
        ?
        _entry.cantidad_max
        :
        "infinito";


    var _remaining =
        scr_shop_stock_remaining(
            _shop_id,
            _tipo,
            _id,
            _limit
        );


    return
        _remaining == 0;
}


// =========================================================
// REGISTRO VISUAL "AGOTADO"
// =========================================================

function scr_shop_stock_install_soldout_data()
{
    scr_shop_init();


    var _soldout =
    {
        nombre:
            scr_loc_src(
                "Agotado"
            ),

        descripcion:
            scr_loc_src(
                "No quedan unidades disponibles."
            ),

        uso:
            scr_loc_src(
                ""
            ),

        tipo:
            "agotado",

        precio_compra:
            0,

        precio_venta:
            0,

        icono_tienda:
            -1,

        color_tienda:
            c_gray,

        atk:
            0,

        def:
            0,

        hp:
            0
    };


    if (variable_global_exists("item_db"))
    {
        variable_struct_set(
            global.item_db,
            "__agotado__",
            _soldout
        );
    }


    if (variable_global_exists("toy_db"))
    {
        variable_struct_set(
            global.toy_db,
            "__agotado__",
            _soldout
        );
    }


    if (variable_global_exists("equip_db"))
    {
        variable_struct_set(
            global.equip_db,
            "__agotado__",
            _soldout
        );
    }
}


// =========================================================
// ACTUALIZAR ENTRADAS DE UNA TIENDA
// =========================================================

function scr_shop_stock_refresh_controller(_controller)
{
    if (
        _controller == noone
        ||
        !instance_exists(_controller)
        ||
        !variable_instance_exists(
            _controller,
            "shop_data"
        )
        ||
        !is_struct(_controller.shop_data)
        ||
        !variable_struct_exists(
            _controller.shop_data,
            "items_venta"
        )
        ||
        !is_array(
            _controller.shop_data.items_venta
        )
    )
    {
        return;
    }


    scr_shop_stock_install_soldout_data();


    var _stock =
        _controller.shop_data.items_venta;


    for (
        var _i = 0;
        _i < array_length(_stock);
        _i++
    )
    {
        var _entry =
            _stock[_i];


        if (
            is_undefined(_entry)
            ||
            !is_struct(_entry)
        )
        {
            continue;
        }


        // -------------------------------------------------
        // DATOS AUTORITATIVOS
        // -------------------------------------------------
        //
        // Nunca asignamos directamente _entry.id.
        // `id` es un nombre reservado/read-only para el
        // compilador de GameMaker en determinados contextos.
        //
        // En vez de editar ese campo, construimos un struct
        // NUEVO completo para la fila y lo reemplazamos en el
        // array. Así desaparece GM1008 de forma limpia.
        // -------------------------------------------------

        var _original_tipo =
            variable_struct_exists(
                _entry,
                "stock_original_tipo"
            )
            ?
            _entry.stock_original_tipo
            :
            variable_struct_get(
                _entry,
                "tipo"
            );


        var _original_id =
            variable_struct_exists(
                _entry,
                "stock_original_id"
            )
            ?
            _entry.stock_original_id
            :
            variable_struct_get(
                _entry,
                "id"
            );


        var _original_color =
            variable_struct_exists(
                _entry,
                "stock_color_original"
            )
            ?
            _entry.stock_color_original
            :
            (
                variable_struct_exists(
                    _entry,
                    "color_nombre"
                )
                ?
                _entry.color_nombre
                :
                noone
            );


        var _limit =
            variable_struct_exists(
                _entry,
                "cantidad_max"
            )
            ?
            _entry.cantidad_max
            :
            "infinito";


        var _agotado =
            (
                scr_shop_stock_remaining(
                    _controller.shop_id,
                    _original_tipo,
                    _original_id,
                    _limit
                )
                ==
                0
            );


        var _display_id =
            _agotado
            ?
            "__agotado__"
            :
            _original_id;


        var _display_color =
            _agotado
            ?
            c_gray
            :
            _original_color;


        // `id:` dentro del literal de creación es válido.
        // Lo que evitamos por completo es reasignarlo después.
        _stock[_i] =
        {
            tipo:
                _original_tipo,

            id:
                _display_id,

            cantidad_max:
                _limit,

            color_nombre:
                _display_color,

            stock_original_tipo:
                _original_tipo,

            stock_original_id:
                _original_id,

            stock_color_original:
                _original_color,

            stock_agotado:
                _agotado
        };
    }


    _controller.shop_data.items_venta =
        _stock;
}


// =========================================================
// ENCONTRAR ENTRADA DISPONIBLE
// =========================================================

function scr_shop_stock_first_available(_controller)
{
    var _stock =
        _controller.shop_data.items_venta;


    for (
        var _i = 0;
        _i < array_length(_stock);
        _i++
    )
    {
        var _entry =
            _stock[_i];


        if (
            is_struct(_entry)
            &&
            variable_struct_exists(
                _entry,
                "stock_agotado"
            )
            &&
            !_entry.stock_agotado
        )
        {
            return _i;
        }
    }


    return -1;
}


function scr_shop_stock_find_available_from(
    _controller,
    _start,
    _direction
)
{
    var _stock =
        _controller.shop_data.items_venta;


    var _count =
        array_length(_stock);


    var _i =
        _start + _direction;


    while (
        _i >= 0
        &&
        _i < _count
    )
    {
        var _entry =
            _stock[_i];


        if (
            is_struct(_entry)
            &&
            variable_struct_exists(
                _entry,
                "stock_agotado"
            )
            &&
            !_entry.stock_agotado
        )
        {
            return _i;
        }


        _i +=
            _direction;
    }


    return _start;
}


function scr_shop_stock_all_exhausted(_controller)
{
    var _stock =
        _controller.shop_data.items_venta;


    if (array_length(_stock) <= 0)
    {
        return false;
    }


    return
        scr_shop_stock_first_available(
            _controller
        )
        ==
        -1;
}


function scr_shop_stock_fix_scroll(_controller)
{
    if (
        !variable_instance_exists(
            _controller,
            "visible_rows"
        )
    )
    {
        return;
    }


    if (
        _controller.buy_index
        <
        _controller.buy_scroll
    )
    {
        _controller.buy_scroll =
            _controller.buy_index;
    }


    if (
        _controller.buy_index
        >=
        _controller.buy_scroll
        +
        _controller.visible_rows
    )
    {
        _controller.buy_scroll =
            _controller.buy_index
            -
            _controller.visible_rows
            +
            1;
    }
}


// =========================================================
// GUARD GLOBAL
// =========================================================
///
/// Se llama desde obj_settings Begin Step.
///
/// Hace cuatro cosas:
///
/// 1. detecta si la confirmación anterior produjo una compra;
/// 2. registra esa compra en el save;
/// 3. convierte las entradas agotadas en "Agotado";
/// 4. impide entrar/comprar una entrada agotada.
/// =========================================================

function scr_shop_stock_guard_update()
{
    if (!instance_exists(obj_shop_controller))
    {
        return;
    }


    var _shop =
        instance_find(
            obj_shop_controller,
            0
        );


    if (
        _shop == noone
        ||
        !instance_exists(_shop)
        ||
        !variable_instance_exists(_shop, "shop_data")
        ||
        !variable_instance_exists(_shop, "shop_id")
    )
    {
        return;
    }


    // =====================================================
    // CONFIRMAR SI EL FRAME ANTERIOR TERMINÓ EN COMPRA REAL
    // =====================================================

    if (
        variable_instance_exists(
            _shop,
            "stock_prev_state"
        )
        &&
        variable_instance_exists(
            _shop,
            "stock_prev_type"
        )
        &&
        variable_instance_exists(
            _shop,
            "stock_prev_id"
        )
        &&
        variable_instance_exists(
            _shop,
            "stock_prev_inventory_count"
        )
        &&
        variable_instance_exists(
            _shop,
            "stock_prev_limit"
        )
        &&
        _shop.stock_prev_state
        ==
        _shop.SHOP_BUY_CONFIRM
        &&
        _shop.state
        ==
        _shop.SHOP_BUY
    )
    {
        var _now_count =
            scr_shop_inventory_count(
                _shop.stock_prev_type,
                _shop.stock_prev_id
            );


        var _delta =
            _now_count
            -
            _shop.stock_prev_inventory_count;


        if (_delta > 0)
        {
            scr_shop_stock_register_purchase(
                _shop.shop_id,
                _shop.stock_prev_type,
                _shop.stock_prev_id,
                _shop.stock_prev_limit,
                _delta
            );
        }
    }


    // Ya con el contador actualizado, refrescar visualmente.
    scr_shop_stock_refresh_controller(
        _shop
    );


    var _stock =
        _shop.shop_data.items_venta;


    var _count =
        array_length(_stock);


    if (_count <= 0)
    {
        return;
    }


    var _all_exhausted =
        scr_shop_stock_all_exhausted(
            _shop
        );


    // =====================================================
    // SI TODO ESTÁ AGOTADO
    // =====================================================

    if (_all_exhausted)
    {
        if (
            _shop.state == _shop.SHOP_BUY
            ||
            _shop.state == _shop.SHOP_BUY_CONFIRM
        )
        {
            _shop.state =
                _shop.SHOP_TOP;

            _shop.top_index =
                0;

            _shop.top_preview_index =
                0;

            _shop.buy_confirm_index =
                1;

            _shop.shop_message =
                scr_loc(
                    scr_loc_src(
                        "* Todo está agotado."
                    )
                );
        }


        if (
            _shop.state == _shop.SHOP_TOP
            &&
            _shop.top_index == 0
            &&
            (
                keyboard_check_pressed(ord("Z"))
                ||
                keyboard_check_pressed(vk_enter)
            )
        )
        {
            keyboard_clear(
                ord("Z")
            );

            keyboard_clear(
                vk_enter
            );


            if (audio_is_playing(snd_error))
            {
                audio_stop_sound(
                    snd_error
                );
            }


            audio_play_sound(
                snd_error,
                10,
                false
            );


            _shop.shop_message =
                scr_loc(
                    scr_loc_src(
                        "* Todo está agotado."
                    )
                );
        }
    }


    // =====================================================
    // LISTA DE COMPRA NORMAL
    // =====================================================

    if (
        !_all_exhausted
        &&
        _shop.state == _shop.SHOP_BUY
    )
    {
        _shop.buy_index =
            clamp(
                _shop.buy_index,
                0,
                _count - 1
            );


        var _current =
            _stock[_shop.buy_index];


        // Si el artículo seleccionado acaba de agotarse por la
        // compra del frame anterior, mover el cursor al siguiente
        // disponible para que "Agotado" permanezca gris.
        if (
            is_struct(_current)
            &&
            variable_struct_exists(
                _current,
                "stock_agotado"
            )
            &&
            _current.stock_agotado
        )
        {
            var _replacement =
                scr_shop_stock_first_available(
                    _shop
                );


            if (_replacement >= 0)
            {
                _shop.buy_index =
                    _replacement;

                scr_shop_stock_fix_scroll(
                    _shop
                );
            }
        }


        // -------------------------------------------------
        // SALTAR FILAS AGOTADAS AL NAVEGAR
        // -------------------------------------------------

        var _up_pressed =
            keyboard_check_pressed(vk_up);


        var _down_pressed =
            keyboard_check_pressed(vk_down);


        if (_up_pressed)
        {
            var _raw_up =
                max(
                    0,
                    _shop.buy_index - 1
                );


            if (
                _raw_up != _shop.buy_index
                &&
                _stock[_raw_up].stock_agotado
            )
            {
                var _target_up =
                    scr_shop_stock_find_available_from(
                        _shop,
                        _shop.buy_index,
                        -1
                    );


                keyboard_clear(vk_up);


                if (_target_up != _shop.buy_index)
                {
                    _shop.buy_index =
                        _target_up;

                    _shop.shop_message =
                        "";

                    scr_shop_stock_fix_scroll(
                        _shop
                    );

                    audio_play_sound(
                        snd_menumove,
                        10,
                        false
                    );
                }
            }
        }


        if (_down_pressed)
        {
            var _raw_down =
                min(
                    _count - 1,
                    _shop.buy_index + 1
                );


            if (
                _raw_down != _shop.buy_index
                &&
                _stock[_raw_down].stock_agotado
            )
            {
                var _target_down =
                    scr_shop_stock_find_available_from(
                        _shop,
                        _shop.buy_index,
                        1
                    );


                keyboard_clear(vk_down);


                if (_target_down != _shop.buy_index)
                {
                    _shop.buy_index =
                        _target_down;

                    _shop.shop_message =
                        "";

                    scr_shop_stock_fix_scroll(
                        _shop
                    );

                    audio_play_sound(
                        snd_menumove,
                        10,
                        false
                    );
                }
            }
        }


        // -------------------------------------------------
        // SEGURIDAD: NO ABRIR CONFIRMACIÓN DE AGOTADO
        // -------------------------------------------------

        var _selected_entry =
            _stock[_shop.buy_index];


        if (
            _selected_entry.stock_agotado
            &&
            (
                keyboard_check_pressed(ord("Z"))
                ||
                keyboard_check_pressed(vk_enter)
            )
        )
        {
            keyboard_clear(ord("Z"));
            keyboard_clear(vk_enter);


            if (audio_is_playing(snd_error))
            {
                audio_stop_sound(
                    snd_error
                );
            }


            audio_play_sound(
                snd_error,
                10,
                false
            );


            _shop.shop_message =
                scr_loc(
                    scr_loc_src(
                        "* Agotado."
                    )
                );
        }
    }


    // =====================================================
    // SEGURIDAD EN CONFIRMACIÓN
    // =====================================================

    if (
        _shop.state == _shop.SHOP_BUY_CONFIRM
        &&
        _shop.buy_index >= 0
        &&
        _shop.buy_index < _count
        &&
        _stock[_shop.buy_index].stock_agotado
    )
    {
        _shop.state =
            _shop.SHOP_BUY;

        _shop.buy_confirm_index =
            1;

        keyboard_clear(ord("Z"));
        keyboard_clear(vk_enter);

        _shop.shop_message =
            scr_loc(
                scr_loc_src(
                    "* Agotado."
                )
            );
    }


    // =====================================================
    // SNAPSHOT PARA DETECTAR LA COMPRA DEL PRÓXIMO FRAME
    // =====================================================

    _shop.stock_prev_state =
        _shop.state;


    if (
        _shop.state == _shop.SHOP_BUY_CONFIRM
        &&
        _shop.buy_index >= 0
        &&
        _shop.buy_index < _count
    )
    {
        var _watch_entry =
            _stock[_shop.buy_index];


        _shop.stock_prev_type =
            _watch_entry.stock_original_tipo;

        _shop.stock_prev_id =
            _watch_entry.stock_original_id;

        _shop.stock_prev_limit =
            _watch_entry.cantidad_max;

        _shop.stock_prev_inventory_count =
            scr_shop_inventory_count(
                _shop.stock_prev_type,
                _shop.stock_prev_id
            );
    }
}
