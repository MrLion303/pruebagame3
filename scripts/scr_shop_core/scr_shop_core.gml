/// =========================================================
/// SCR_SHOP_CORE
/// =========================================================
///
/// Funciones generales de las tiendas.
///
/// CAMBIO DE ESTA VERSIÓN:
/// - "tijeras_jardin" se vende desde la tienda como una fila
///   de tipo "item", pero al comprarla entra directamente al
///   inventario CLAVE.
/// - Nunca ocupa el inventario normal de consumibles.
/// - No puede venderse ni quitarse desde la tienda.
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

    // La tienda también puede manejar las Tijeras Jardín,
    // que realmente pertenecen al inventario CLAVE.
    scr_itemclave_init();

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
// ¿ES UN OBJETO CLAVE VENDIDO DESDE LA LISTA DE ITEMS?
// =========================================================

function scr_shop_is_key_item_alias(_tipo, _id)
{
    return
        _tipo == "item"
        &&
        _id == "tijeras_jardin";
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
// OBTENER DATOS DE ITEM / EQUIP / TOY
// =========================================================

function scr_shop_get_object_data(
    _tipo,
    _id
)
{
    scr_shop_init();


    // Las Tijeras Jardín aparecen en la tienda dentro de la
    // lista de ITEM para no tener que alterar la UI de tienda,
    // pero sus datos reales vienen de OBJETOS CLAVE.
    if (scr_shop_is_key_item_alias(_tipo, _id))
    {
        return scr_itemclave_get(
            "tijeras_jardin"
        );
    }


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


    // Las tijeras son únicas. Para el sistema de stock:
    // 0 = todavía no las tienes
    // 1 = ya fueron obtenidas
    if (scr_shop_is_key_item_alias(_tipo, _id))
    {
        return
            scr_itemclave_tiene(
                "tijeras_jardin"
            )
            ? 1
            : 0;
    }


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


    // Tijeras Jardín: se añaden DIRECTAMENTE a CLAVE.
    // Así jamás pasan por el inventario normal y no pueden
    // tirarse como un consumible.
    if (scr_shop_is_key_item_alias(_tipo, _id))
    {
        return scr_itemclave_dar(
            "tijeras_jardin"
        );
    }


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


    // Los objetos clave no se venden ni se eliminan desde la
    // lógica normal de tienda.
    if (scr_shop_is_key_item_alias(_tipo, _id))
    {
        return false;
    }


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


            for (
                var _i = 0;
                _i < array_length(global.toy_inventory);
                _i++
            )
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


            for (
                var _i = 0;
                _i < array_length(global.equipment_inventory);
                _i++
            )
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
/// Cada unidad ocupa una fila individual y conserva su slot.
/// Los objetos CLAVE no entran aquí.
/// =========================================================

function scr_shop_build_sell_list(_categoria)
{
    scr_shop_init();

    var _lista =
        [];


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
                var _item_id =
                    _consumibles[_i];


                if (
                    _item_id == -1
                    ||
                    is_undefined(_item_id)
                )
                {
                    continue;
                }


                var _data =
                    variable_struct_get(
                        global.item_db,
                        _item_id
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
                            _item_id,

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
                var _toy_id =
                    global.toy_inventory[_i];


                if (
                    _toy_id == -1
                    ||
                    is_undefined(_toy_id)
                )
                {
                    continue;
                }


                var _data =
                    variable_struct_get(
                        global.toy_db,
                        _toy_id
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
                            _toy_id,

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
                var _equip_id =
                    global.equipment_inventory[_i];


                if (
                    _equip_id == -1
                    ||
                    is_undefined(_equip_id)
                )
                {
                    continue;
                }


                var _data =
                    variable_struct_get(
                        global.equip_db,
                        _equip_id
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
                            _equip_id,

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
                var _equip_id =
                    global.equipment_inventory[_i];


                if (
                    _equip_id == -1
                    ||
                    is_undefined(_equip_id)
                )
                {
                    continue;
                }


                var _data =
                    variable_struct_get(
                        global.equip_db,
                        _equip_id
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
                            _equip_id,

                        cantidad:
                            1,

                        slot:
                            _i
                    }
                );
            }

            break;


        default:
            return [];
    }


    return _lista;
}


// =========================================================
// ESPACIOS DEL INVENTARIO
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


            for (
                var _i = 0;
                _i < _total;
                _i++
            )
            {
                if (
                    global.toy_inventory[_i] != -1
                    &&
                    !is_undefined(
                        global.toy_inventory[_i]
                    )
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
