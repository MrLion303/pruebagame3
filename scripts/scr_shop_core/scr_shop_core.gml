/// =========================================================
/// SCR_SHOP_CORE
/// =========================================================
///
/// Funciones generales de las tiendas.
///
/// NO contiene información específica de shop_1.
/// Eso está en scr_shop_data.
/// =========================================================


// =========================================================
// ASEGURAR BASES DE DATOS
// =========================================================

function scr_shop_init()
{
    if (!variable_global_exists("item_db"))
    {
        scr_item_db();
    }

    if (!variable_global_exists("equip_db"))
    {
        scr_equips_data();
    }

    if (!variable_global_exists("toy_db"))
    {
        scr_toys_data();
    }

    scr_inventarios_data();
    scr_level_data();


    // Sueños puede no existir en saves antiguos.
    if (
        !variable_struct_exists(
            global.level_data,
            "suenos"
        )
    )
    {
        global.level_data.suenos =
            0;
    }


    if (!variable_global_exists("equipment_inventory"))
    {
        global.equipment_inventory =
            global.inventory_data.equipamiento;
    }


    // Mantener ambas referencias sincronizadas.
    global.inventory_data.equipamiento =
        global.equipment_inventory;
}


// =========================================================
// DINERO / SUEÑOS
// =========================================================

function scr_shop_get_money()
{
    scr_shop_init();

    return max(
        0,
        round(global.level_data.suenos)
    );
}


function scr_shop_add_money(_cantidad)
{
    scr_shop_init();

    global.level_data.suenos +=
        max(
            0,
            round(_cantidad)
        );

    return global.level_data.suenos;
}


function scr_shop_spend_money(_cantidad)
{
    scr_shop_init();

    var _cantidad_real =
        max(
            0,
            round(_cantidad)
        );

    if (
        global.level_data.suenos
        <
        _cantidad_real
    )
    {
        return false;
    }

    global.level_data.suenos -=
        _cantidad_real;

    return true;
}


// =========================================================
// OBTENER DATOS DE ITEM / EQUIP
// =========================================================

function scr_shop_get_object_data(
    _tipo,
    _id
)
{
    scr_shop_init();

    switch (_tipo)
    {
        case "item":

            return variable_struct_get(
                global.item_db,
                _id
            );


        case "equip":

            return variable_struct_get(
                global.equip_db,
                _id
            );


        case "toy":

            return variable_struct_get(
                global.toy_db,
                _id
            );
    }

    return undefined;
}


// =========================================================
// PRECIO
// =========================================================

function scr_shop_get_buy_price(
    _tipo,
    _id
)
{
    var _data =
        scr_shop_get_object_data(
            _tipo,
            _id
        );

    if (
        is_undefined(_data)
        ||
        !variable_struct_exists(
            _data,
            "precio_compra"
        )
    )
    {
        return 0;
    }

    return max(
        0,
        round(_data.precio_compra)
    );
}


function scr_shop_get_sell_price(
    _tipo,
    _id
)
{
    var _data =
        scr_shop_get_object_data(
            _tipo,
            _id
        );

    if (
        is_undefined(_data)
        ||
        !variable_struct_exists(
            _data,
            "precio_venta"
        )
    )
    {
        return 0;
    }

    return max(
        0,
        round(_data.precio_venta)
    );
}


// =========================================================
// CONTAR CUÁNTAS UNIDADES TIENES
// =========================================================

function scr_shop_inventory_count(
    _tipo,
    _id
)
{
    scr_shop_init();

    var _cantidad =
        0;


    switch (_tipo)
    {
        // -------------------------------------------------
        // CONSUMIBLES
        // -------------------------------------------------

        case "item":

            if (
                instance_exists(obj_player)
                &&
                variable_instance_exists(
                    obj_player,
                    "inventory"
                )
            )
            {
                for (
                    var _i = 0;
                    _i < array_length(obj_player.inventory);
                    _i++
                )
                {
                    if (
                        obj_player.inventory[_i]
                        ==
                        _id
                    )
                    {
                        _cantidad++;
                    }
                }
            }
            else
            {
                for (
                    var _i = 0;
                    _i < array_length(global.inventory_data.consumibles);
                    _i++
                )
                {
                    if (
                        global.inventory_data.consumibles[_i]
                        ==
                        _id
                    )
                    {
                        _cantidad++;
                    }
                }
            }

            break;


        // -------------------------------------------------
        // EQUIP
        // -------------------------------------------------

        case "equip":

            for (
                var _i = 0;
                _i < array_length(global.equipment_inventory);
                _i++
            )
            {
                if (
                    global.equipment_inventory[_i]
                    ==
                    _id
                )
                {
                    _cantidad++;
                }
            }

            break;


        // -------------------------------------------------
        // TOYS
        // -------------------------------------------------

        case "toy":

            for (
                var _i = 0;
                _i < array_length(global.toy_inventory);
                _i++
            )
            {
                if (
                    global.toy_inventory[_i]
                    ==
                    _id
                )
                {
                    _cantidad++;
                }
            }

            break;
    }


    return _cantidad;
}


// =========================================================
// AÑADIR AL INVENTARIO
// =========================================================
///
/// Devuelve true si encontró espacio.
/// =========================================================

function scr_shop_inventory_add(
    _tipo,
    _id
)
{
    scr_shop_init();


    switch (_tipo)
    {
        // -------------------------------------------------
        // CONSUMIBLE
        // -------------------------------------------------

        case "item":

            if (
                instance_exists(obj_player)
                &&
                variable_instance_exists(
                    obj_player,
                    "inventory"
                )
            )
            {
                for (
                    var _i = 0;
                    _i < array_length(obj_player.inventory);
                    _i++
                )
                {
                    if (
                        obj_player.inventory[_i]
                        ==
                        -1
                    )
                    {
                        obj_player.inventory[_i] =
                            _id;

                        global.inventory_data.consumibles =
                            obj_player.inventory;

                        return true;
                    }
                }
            }
            else
            {
                for (
                    var _i = 0;
                    _i < array_length(global.inventory_data.consumibles);
                    _i++
                )
                {
                    if (
                        global.inventory_data.consumibles[_i]
                        ==
                        -1
                    )
                    {
                        global.inventory_data.consumibles[_i] =
                            _id;

                        return true;
                    }
                }
            }

            return false;


        // -------------------------------------------------
        // EQUIPAMIENTO
        // -------------------------------------------------

        case "equip":

            for (
                var _i = 0;
                _i < array_length(global.equipment_inventory);
                _i++
            )
            {
                if (
                    global.equipment_inventory[_i]
                    ==
                    -1
                )
                {
                    global.equipment_inventory[_i] =
                        _id;

                    global.inventory_data.equipamiento =
                        global.equipment_inventory;

                    return true;
                }
            }

            return false;


        // -------------------------------------------------
        // TOY
        // -------------------------------------------------

        case "toy":

            for (
                var _i = 0;
                _i < array_length(global.toy_inventory);
                _i++
            )
            {
                if (global.toy_inventory[_i] == -1)
                {
                    global.toy_inventory[_i] =
                        _id;

                    global.inventory_data.toys =
                        global.toy_inventory;

                    return true;
                }
            }

            return false;
    }


    return false;
}


// =========================================================
// QUITAR UNA UNIDAD DEL INVENTARIO
// =========================================================
///
/// Devuelve true si encontró una unidad.
/// =========================================================

function scr_shop_inventory_remove(
    _tipo,
    _id,
    _slot = -1
)
{
    scr_shop_init();


    switch (_tipo)
    {
        // -------------------------------------------------
        // CONSUMIBLE
        // -------------------------------------------------

        case "item":

            var _inv =
                global.inventory_data.consumibles;

            if (
                instance_exists(obj_player)
                &&
                variable_instance_exists(
                    obj_player,
                    "inventory"
                )
            )
            {
                _inv =
                    obj_player.inventory;
            }


            if (
                _slot >= 0
                &&
                _slot < array_length(_inv)
                &&
                _inv[_slot] == _id
            )
            {
                _inv[_slot] =
                    -1;

                if (instance_exists(obj_player))
                {
                    obj_player.inventory =
                        _inv;
                }

                global.inventory_data.consumibles =
                    _inv;

                return true;
            }


            for (var _i = 0; _i < array_length(_inv); _i++)
            {
                if (_inv[_i] == _id)
                {
                    _inv[_i] =
                        -1;

                    if (instance_exists(obj_player))
                    {
                        obj_player.inventory =
                            _inv;
                    }

                    global.inventory_data.consumibles =
                        _inv;

                    return true;
                }
            }

            return false;


        // -------------------------------------------------
        // TOY
        // -------------------------------------------------

        case "toy":

            if (
                _slot >= 0
                &&
                _slot < array_length(global.toy_inventory)
                &&
                global.toy_inventory[_slot] == _id
            )
            {
                global.toy_inventory[_slot] =
                    -1;

                global.inventory_data.toys =
                    global.toy_inventory;

                return true;
            }


            for (var _i = 0; _i < array_length(global.toy_inventory); _i++)
            {
                if (global.toy_inventory[_i] == _id)
                {
                    global.toy_inventory[_i] =
                        -1;

                    global.inventory_data.toys =
                        global.toy_inventory;

                    return true;
                }
            }

            return false;


        // -------------------------------------------------
        // EQUIPAMIENTO
        // -------------------------------------------------

        case "equip":

            if (
                _slot >= 0
                &&
                _slot < array_length(global.equipment_inventory)
                &&
                global.equipment_inventory[_slot] == _id
            )
            {
                global.equipment_inventory[_slot] =
                    -1;

                global.inventory_data.equipamiento =
                    global.equipment_inventory;

                return true;
            }


            for (var _i = 0; _i < array_length(global.equipment_inventory); _i++)
            {
                if (global.equipment_inventory[_i] == _id)
                {
                    global.equipment_inventory[_i] =
                        -1;

                    global.inventory_data.equipamiento =
                        global.equipment_inventory;

                    return true;
                }
            }

            return false;
    }


    return false;
}


// =========================================================
// CONSTRUIR LISTA DE VENTA
// =========================================================
///
/// Devuelve una lista SIN duplicados:
///
/// {
///     tipo: "item" / "equip",
///     id: "...",
///     cantidad: 2
/// }
///
/// Solo muestra consumibles + equipamiento.
/// Los TOYS no forman parte de esta tienda por ahora.
/// =========================================================

function scr_shop_build_sell_list(_categoria)
{
    scr_shop_init();

    var _lista =
        [];


    // =====================================================
    // IMPORTANTE
    // =====================================================
    //
    // Esta función construye UNA SOLA categoría.
    //
    // Ya NO existe un modo "all" para VENDER.
    // Esto evita que ITEM/JUGUETE/ARMA/ARMADURA terminen
    // mostrando juntos todos los inventarios.
    // =====================================================

    switch (_categoria)
    {
        // =================================================
        // ITEM = SOLO CONSUMIBLES
        // =================================================

        case "item":

            var _consumibles =
                global.inventory_data.consumibles;


            if (
                instance_exists(obj_player)
                &&
                variable_instance_exists(
                    obj_player,
                    "inventory"
                )
            )
            {
                _consumibles =
                    obj_player.inventory;
            }


            for (
                var _i = 0;
                _i < array_length(_consumibles);
                _i++
            )
            {
                var _id =
                    _consumibles[_i];


                if (
                    _id == -1
                    ||
                    is_undefined(_id)
                )
                {
                    continue;
                }


                var _data =
                    variable_struct_get(
                        global.item_db,
                        _id
                    );


                if (is_undefined(_data))
                {
                    continue;
                }


                array_push(
                    _lista,
                    {
                        tipo:
                            "item",

                        id:
                            _id,

                        cantidad:
                            1,

                        slot:
                            _i
                    }
                );
            }

            break;


        // =================================================
        // JUGUETE = SOLO TOYS
        // =================================================

        case "toy":

            for (
                var _i = 0;
                _i < array_length(global.toy_inventory);
                _i++
            )
            {
                var _id =
                    global.toy_inventory[_i];


                if (
                    _id == -1
                    ||
                    is_undefined(_id)
                )
                {
                    continue;
                }


                var _data =
                    variable_struct_get(
                        global.toy_db,
                        _id
                    );


                if (is_undefined(_data))
                {
                    continue;
                }


                array_push(
                    _lista,
                    {
                        tipo:
                            "toy",

                        id:
                            _id,

                        cantidad:
                            1,

                        slot:
                            _i
                    }
                );
            }

            break;


        // =================================================
        // ARMA = SOLO EQUIPO DE TIPO "arma"
        // =================================================

        case "arma":

            for (
                var _i = 0;
                _i < array_length(global.equipment_inventory);
                _i++
            )
            {
                var _id =
                    global.equipment_inventory[_i];


                if (
                    _id == -1
                    ||
                    is_undefined(_id)
                )
                {
                    continue;
                }


                var _data =
                    variable_struct_get(
                        global.equip_db,
                        _id
                    );


                if (
                    is_undefined(_data)
                    ||
                    !variable_struct_exists(
                        _data,
                        "tipo"
                    )
                    ||
                    _data.tipo != "arma"
                )
                {
                    continue;
                }


                array_push(
                    _lista,
                    {
                        tipo:
                            "equip",

                        id:
                            _id,

                        cantidad:
                            1,

                        slot:
                            _i
                    }
                );
            }

            break;


        // =================================================
        // ARMADURA = SOLO EQUIPO DE TIPO "armadura"
        // =================================================

        case "armadura":

            for (
                var _i = 0;
                _i < array_length(global.equipment_inventory);
                _i++
            )
            {
                var _id =
                    global.equipment_inventory[_i];


                if (
                    _id == -1
                    ||
                    is_undefined(_id)
                )
                {
                    continue;
                }


                var _data =
                    variable_struct_get(
                        global.equip_db,
                        _id
                    );


                if (
                    is_undefined(_data)
                    ||
                    !variable_struct_exists(
                        _data,
                        "tipo"
                    )
                    ||
                    _data.tipo != "armadura"
                )
                {
                    continue;
                }


                array_push(
                    _lista,
                    {
                        tipo:
                            "equip",

                        id:
                            _id,

                        cantidad:
                            1,

                        slot:
                            _i
                    }
                );
            }

            break;


        // =================================================
        // CATEGORÍA INVÁLIDA
        // =================================================

        default:

            return [];
    }


    return _lista;
}


// =========================================================
// ESPACIOS DEL INVENTARIO
// =========================================================
//
// Devuelve:
//
// {
//     usados: 3,
//     total: 12
// }
//
// "item"  -> inventario de consumibles.
// "equip" -> inventario de armas/armaduras.
// =========================================================

function scr_shop_inventory_space(_tipo)
{
    scr_shop_init();


    var _usados =
        0;

    var _total =
        0;


    switch (_tipo)
    {
        // -------------------------------------------------
        // CONSUMIBLES
        // -------------------------------------------------

        case "item":

            var _inv =
                global.inventory_data.consumibles;


            if (
                instance_exists(obj_player)
                &&
                variable_instance_exists(
                    obj_player,
                    "inventory"
                )
            )
            {
                _inv =
                    obj_player.inventory;
            }


            _total =
                array_length(_inv);


            for (
                var _i = 0;
                _i < _total;
                _i++
            )
            {
                if (
                    _inv[_i] != -1
                    &&
                    !is_undefined(_inv[_i])
                )
                {
                    _usados++;
                }
            }

            break;


        // -------------------------------------------------
        // EQUIPAMIENTO
        // -------------------------------------------------

        case "equip":

            _total =
                array_length(
                    global.equipment_inventory
                );


            for (
                var _i = 0;
                _i < _total;
                _i++
            )
            {
                if (
                    global.equipment_inventory[_i] != -1
                    &&
                    !is_undefined(
                        global.equipment_inventory[_i]
                    )
                )
                {
                    _usados++;
                }
            }

            break;


        // -------------------------------------------------
        // JUGUETES
        // -------------------------------------------------

        case "toy":

            _total =
                array_length(global.toy_inventory);

            for (var _i = 0; _i < _total; _i++)
            {
                if (
                    global.toy_inventory[_i] != -1
                    &&
                    !is_undefined(global.toy_inventory[_i])
                )
                {
                    _usados++;
                }
            }

            break;
    }


    return {
        usados:
            _usados,

        total:
            _total
    };
}
