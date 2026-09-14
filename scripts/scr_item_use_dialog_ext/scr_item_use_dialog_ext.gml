/// =========================================================
/// SCR_ITEM_USE_DIALOG_EXT
/// NUEVO SCRIPT
/// =========================================================
///
/// Detecta un consumible usado desde:
///
///     PAUSA -> INV -> Usar
///
/// y muestra:
///
///     "Usaste (objeto), recuperaste (N) HP."
/// =========================================================


// =========================================================
// COPIAR ARRAY DE INVENTARIO
// =========================================================

function scr_item_use_dialog_copy_inventory(_inventory)
{
    if (!is_array(_inventory))
    {
        return [];
    }


    var _copy =
        array_create(
            array_length(
                _inventory
            ),
            -1
        );


    for (
        var _i = 0;
        _i < array_length(_inventory);
        _i++
    )
    {
        _copy[_i] =
            _inventory[_i];
    }


    return _copy;
}


// =========================================================
// CREAR TEXTBOX SIMPLE
// =========================================================

function scr_item_use_dialog_show(
    _item_name,
    _heal_amount
)
{
    if (!instance_exists(obj_player))
    {
        return;
    }


    if (instance_exists(obj_textbox))
    {
        return;
    }


    var _p =
        instance_find(
            obj_player,
            0
        );


    var _message =
        "Usaste "
        +
        string(_item_name)
        +
        ", recuperaste "
        +
        string(
            max(
                0,
                round(_heal_amount)
            )
        )
        +
        " HP.";


    var _tb =
        instance_create_depth(
            _p.x,
            _p.y,
            -9999,
            obj_textbox
        );


    if (_tb == noone)
    {
        return;
    }


    // Sobrescribir la página default de Create.
    _tb.text_id =
        "item_use_result";


    _tb.page =
        0;


    _tb.page_number =
        1;


    _tb.text =
        [_message];


    _tb.text_lenght =
        [
            string_length(
                _message
            )
        ];


    _tb.text_color =
        [c_white];


    _tb.speaker_sprite =
        [noone];


    _tb.text_sound =
        [snd_text];


    _tb.txtb_spr =
        [spr_textbox];


    _tb.page_itemclave =
        [];


    _tb.page_itemclave_given =
        [];


    _tb.option_number =
        0;


    _tb.option =
        [""];


    _tb.draw_char =
        0;


    _tb.setup =
        false;
}


// =========================================================
// WATCHER
// =========================================================

function scr_item_use_dialog_update()
{
    if (
        !instance_exists(obj_player)
        ||
        !instance_exists(obj_menu_manager)
    )
    {
        return;
    }


    var _p =
        instance_find(
            obj_player,
            0
        );


    var _menu =
        instance_find(
            obj_menu_manager,
            0
        );


    if (
        _p == noone
        ||
        _menu == noone
        ||
        !variable_instance_exists(
            _p,
            "inventory"
        )
        ||
        !is_array(
            _p.inventory
        )
    )
    {
        return;
    }


    // =====================================================
    // INICIALIZAR SNAPSHOT
    // =====================================================

    if (
        !variable_global_exists(
            "item_use_dialog_watch_ready"
        )
        ||
        !global.item_use_dialog_watch_ready
    )
    {
        global.item_use_dialog_watch_ready =
            true;


        global.item_use_dialog_prev_inventory =
            scr_item_use_dialog_copy_inventory(
                _p.inventory
            );


        global.item_use_dialog_prev_hp =
            _p.hp;


        global.item_use_dialog_prev_menu_state =
            _menu.state;


        return;
    }


    var _prev_inventory =
        global.item_use_dialog_prev_inventory;


    var _prev_hp =
        global.item_use_dialog_prev_hp;


    var _prev_state =
        global.item_use_dialog_prev_menu_state;


    var _current_state =
        _menu.state;


    // =====================================================
    // DETECTAR CONSUMO REAL
    // =====================================================
    //
    // Usar:
    //
    //     ITEM_ACTION -> CLOSED
    //     slot ITEM -> -1
    //
    // Tirar:
    //
    //     ITEM_ACTION -> ITEM_DROP_CONFIRM
    //
    // así que no genera este diálogo.
    // =====================================================

    var _used_item_key =
        -1;


    if (
        _prev_state
        ==
        MENU_STATE.ITEM_ACTION
        &&
        _current_state
        ==
        MENU_STATE.CLOSED
        &&
        is_array(
            _prev_inventory
        )
    )
    {
        var _compare_count =
            min(
                array_length(
                    _prev_inventory
                ),
                array_length(
                    _p.inventory
                )
            );


        for (
            var _i = 0;
            _i < _compare_count;
            _i++
        )
        {
            var _before =
                _prev_inventory[_i];


            var _after =
                _p.inventory[_i];


            if (
                _before != -1
                &&
                _before != undefined
                &&
                _after == -1
            )
            {
                if (
                    variable_global_exists(
                        "item_db"
                    )
                    &&
                    is_struct(
                        global.item_db
                    )
                    &&
                    variable_struct_exists(
                        global.item_db,
                        _before
                    )
                )
                {
                    var _candidate =
                        variable_struct_get(
                            global.item_db,
                            _before
                        );


                    if (
                        is_struct(_candidate)
                        &&
                        variable_struct_exists(
                            _candidate,
                            "tipo"
                        )
                        &&
                        _candidate.tipo
                        ==
                        "consumible"
                    )
                    {
                        _used_item_key =
                            _before;

                        break;
                    }
                }
            }
        }
    }


    if (_used_item_key != -1)
    {
        var _item_data =
            variable_struct_get(
                global.item_db,
                _used_item_key
            );


        var _item_name =
            (
                variable_struct_exists(
                    _item_data,
                    "nombre"
                )
                ?
                scr_loc(
                    _item_data.nombre
                )
                :
                string(
                    _used_item_key
                )
            );


        // Cantidad REAL recuperada, ya limitada por hp_max.
        var _healed =
            max(
                0,
                _p.hp
                -
                _prev_hp
            );


        scr_item_use_dialog_show(
            _item_name,
            _healed
        );
    }


    // =====================================================
    // SNAPSHOT PARA EL SIGUIENTE FRAME
    // =====================================================

    global.item_use_dialog_prev_inventory =
        scr_item_use_dialog_copy_inventory(
            _p.inventory
        );


    global.item_use_dialog_prev_hp =
        _p.hp;


    global.item_use_dialog_prev_menu_state =
        _menu.state;
}
