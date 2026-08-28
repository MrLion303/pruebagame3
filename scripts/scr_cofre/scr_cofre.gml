/// =========================================================
/// SCR_COFRE
///
/// Cofre global compartido.
/// 50 espacios.
/// Puede guardar:
/// - consumibles
/// - toys
/// - equipamiento
/// =========================================================


// =========================================================
// INICIALIZAR
// =========================================================

function scr_cofre_init()
{
    if (!variable_global_exists("item_db"))
    {
        scr_item_db();
    }

    if (!variable_global_exists("toy_db"))
    {
        scr_toys_data();
    }

    if (!variable_global_exists("equip_db"))
    {
        scr_equips_data();
    }

    scr_inventarios_data();


    // =====================================================
    // CREAR COFRE
    // =====================================================

    if (
        !variable_global_exists("chest_data")
        ||
        !is_array(global.chest_data)
    )
    {
        global.chest_data =
            array_create(50, -1);
    }


    // =====================================================
    // ACTUALIZAR COFRES ANTIGUOS A 50 SLOTS
    // =====================================================

    if (array_length(global.chest_data) != 50)
    {
        var _viejo =
            global.chest_data;


        global.chest_data =
            array_create(50, -1);


        var _cantidad =
            min(
                50,
                array_length(_viejo)
            );


        for (var i = 0; i < _cantidad; i++)
        {
            global.chest_data[i] =
                _viejo[i];
        }
    }
}


// =========================================================
// VACIAR COFRE
// =========================================================

function scr_cofre_reset()
{
    global.chest_data =
        array_create(50, -1);
}


// =========================================================
// DATOS DE UN OBJETO
// =========================================================

function scr_cofre_item_data(_entrada)
{
    if (!is_struct(_entrada))
    {
        return undefined;
    }


    if (
        !variable_struct_exists(_entrada, "tipo")
        ||
        !variable_struct_exists(_entrada, "key")
    )
    {
        return undefined;
    }


    var _tipo =
        _entrada.tipo;

    var _key =
        _entrada.key;


    switch (_tipo)
    {
        case "consumible":

            if (
                variable_global_exists("item_db")
                &&
                global.item_db[$ _key] != undefined
            )
            {
                return global.item_db[$ _key];
            }

            break;


        case "toy":

            if (
                variable_global_exists("toy_db")
                &&
                global.toy_db[$ _key] != undefined
            )
            {
                return global.toy_db[$ _key];
            }

            break;


        case "equipamiento":

            if (
                variable_global_exists("equip_db")
                &&
                global.equip_db[$ _key] != undefined
            )
            {
                return global.equip_db[$ _key];
            }

            break;
    }


    return undefined;
}


// =========================================================
// NOMBRE
// =========================================================

function scr_cofre_item_nombre(_entrada)
{
    var _datos =
        scr_cofre_item_data(_entrada);


    if (
        _datos != undefined
        &&
        variable_struct_exists(_datos, "nombre")
    )
    {
        return scr_loc(_datos.nombre);
    }


    return "???";
}


// =========================================================
// DESCRIPCIÓN
// =========================================================

function scr_cofre_item_descripcion(_entrada)
{
    var _datos =
        scr_cofre_item_data(_entrada);


    if (
        _datos != undefined
        &&
        variable_struct_exists(_datos, "descripcion")
    )
    {
        return scr_loc(_datos.descripcion);
    }


    return "";
}


// =========================================================
// NOMBRE DEL TIPO
// =========================================================

function scr_cofre_tipo_nombre(_tipo)
{
    switch (_tipo)
    {
        case "consumible":
            return scr_loc("Objeto");

        case "toy":
            return scr_loc("Toy");

        case "equipamiento":
            return scr_loc("Equipo");
    }


    return "";
}


// =========================================================
// OBTENER SLOT DE INVENTARIO
// =========================================================

function scr_cofre_inv_get(_tipo, _slot)
{
    switch (_tipo)
    {
        case "consumible":

            if (
                instance_exists(obj_player)
                &&
                _slot >= 0
                &&
                _slot < array_length(obj_player.inventory)
            )
            {
                return obj_player.inventory[_slot];
            }

            break;


        case "toy":

            if (
                variable_global_exists("toy_inventory")
                &&
                _slot >= 0
                &&
                _slot < array_length(global.toy_inventory)
            )
            {
                return global.toy_inventory[_slot];
            }

            break;


        case "equipamiento":

            if (
                variable_global_exists("equipment_inventory")
                &&
                _slot >= 0
                &&
                _slot < array_length(global.equipment_inventory)
            )
            {
                return global.equipment_inventory[_slot];
            }

            break;
    }


    return -1;
}


// =========================================================
// MODIFICAR SLOT DE INVENTARIO
// =========================================================

function scr_cofre_inv_set(_tipo, _slot, _valor)
{
    switch (_tipo)
    {
        case "consumible":

            if (
                instance_exists(obj_player)
                &&
                _slot >= 0
                &&
                _slot < array_length(obj_player.inventory)
            )
            {
                obj_player.inventory[_slot] =
                    _valor;

                return true;
            }

            break;


        case "toy":

            if (
                variable_global_exists("toy_inventory")
                &&
                _slot >= 0
                &&
                _slot < array_length(global.toy_inventory)
            )
            {
                global.toy_inventory[_slot] =
                    _valor;

                return true;
            }

            break;


        case "equipamiento":

            if (
                variable_global_exists("equipment_inventory")
                &&
                _slot >= 0
                &&
                _slot < array_length(global.equipment_inventory)
            )
            {
                global.equipment_inventory[_slot] =
                    _valor;

                return true;
            }

            break;
    }


    return false;
}


// =========================================================
// BUSCAR ESPACIO VACÍO EN INVENTARIO
// =========================================================

function scr_cofre_inv_slot_vacio(_tipo)
{
    var _cantidad = 0;


    switch (_tipo)
    {
        case "consumible":

            if (!instance_exists(obj_player))
            {
                return -1;
            }

            _cantidad =
                array_length(obj_player.inventory);

            break;


        case "toy":

            if (!variable_global_exists("toy_inventory"))
            {
                return -1;
            }

            _cantidad =
                array_length(global.toy_inventory);

            break;


        case "equipamiento":

            if (!variable_global_exists("equipment_inventory"))
            {
                return -1;
            }

            _cantidad =
                array_length(global.equipment_inventory);

            break;


        default:

            return -1;
    }


    for (var i = 0; i < _cantidad; i++)
    {
        var _valor =
            scr_cofre_inv_get(
                _tipo,
                i
            );


        if (
            _valor == -1
            ||
            _valor == undefined
        )
        {
            return i;
        }
    }


    return -1;
}


// =========================================================
// LISTA UNIFICADA DEL INVENTARIO
// =========================================================

function scr_cofre_inventario_lista()
{
    scr_cofre_init();


    var _lista = [];


    // =====================================================
    // CONSUMIBLES
    // =====================================================

    if (instance_exists(obj_player))
    {
        for (
            var i = 0;
            i < array_length(obj_player.inventory);
            i++
        )
        {
            var _key =
                obj_player.inventory[i];


            if (
                _key != -1
                &&
                _key != undefined
            )
            {
                array_push(
                    _lista,
                    {
                        tipo: "consumible",
                        slot: i,
                        key: _key
                    }
                );
            }
        }
    }


    // =====================================================
    // TOYS
    // =====================================================

    if (variable_global_exists("toy_inventory"))
    {
        for (
            var i = 0;
            i < array_length(global.toy_inventory);
            i++
        )
        {
            var _key =
                global.toy_inventory[i];


            if (
                _key != -1
                &&
                _key != undefined
            )
            {
                array_push(
                    _lista,
                    {
                        tipo: "toy",
                        slot: i,
                        key: _key
                    }
                );
            }
        }
    }


    // =====================================================
    // EQUIPAMIENTO
    // =====================================================

    if (variable_global_exists("equipment_inventory"))
    {
        for (
            var i = 0;
            i < array_length(global.equipment_inventory);
            i++
        )
        {
            var _key =
                global.equipment_inventory[i];


            if (
                _key != -1
                &&
                _key != undefined
            )
            {
                array_push(
                    _lista,
                    {
                        tipo: "equipamiento",
                        slot: i,
                        key: _key
                    }
                );
            }
        }
    }


    return _lista;
}