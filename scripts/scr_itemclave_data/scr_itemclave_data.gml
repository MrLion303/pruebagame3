/// =========================================================
/// SRC_ITEMCLAVE_DATA
/// =========================================================
///
/// Base de datos universal para OBJETOS CLAVE.
///
/// Cada objeto clave se identifica mediante una ID de texto.
/// En la partida SOLO se guarda esa ID.
///
/// El inventario CLAVE tiene 15 espacios fijos.
///
/// CAMPOS:
///
/// nombre:
///     Nombre visible.
///
/// descripcion:
///     Descripción visible.
///
/// uso:
///     Explicación visible de para qué sirve.
///
/// funcion:
///     Identificador interno libre para que otros sistemas
///     sepan qué función cumple este objeto.
///
/// =========================================================



// =========================================================
// CREAR / RECREAR BASE DE DATOS
// =========================================================

function src_itemclave_data()
{
    global.itemclave_db =
    {
        // =================================================
        // LLAVE DE PRUEBA
        // =================================================
        //
        // EJEMPLO:
        //
        // otro_objeto:
        // {
        //     nombre:
        //         scr_loc_src("Nombre"),
        //
        //     descripcion:
        //         scr_loc_src("Descripción."),
        //
        //     uso:
        //         scr_loc_src("Para qué sirve."),
        //
        //     funcion:
        //         "funcion_interna"
        // }
        //
        // =================================================

        llave_prueba:
        {
            nombre:
                scr_loc_src(
                    "Llave de prueba"
                ),

            descripcion:
                scr_loc_src(
                    "Una llave creada para probar el sistema."
                ),

            uso:
                scr_loc_src(
                    "Abre una cerradura de prueba."
                ),

            funcion:
                "abrir_cerradura_prueba"
        }
    };


    return global.itemclave_db;
}



// =========================================================
// ASEGURAR BASE DE DATOS
// =========================================================

function scr_itemclave_init()
{
    if (
        !variable_global_exists(
            "itemclave_db"
        )
        ||
        !is_struct(
            global.itemclave_db
        )
    )
    {
        src_itemclave_data();
    }


    return global.itemclave_db;
}



// =========================================================
// OBTENER DATOS DE UN OBJETO CLAVE
// =========================================================

function scr_itemclave_get(_itemclave_id)
{
    scr_itemclave_init();


    if (
        !is_string(
            _itemclave_id
        )
        ||
        _itemclave_id == ""
    )
    {
        return undefined;
    }


    if (
        !variable_struct_exists(
            global.itemclave_db,
            _itemclave_id
        )
    )
    {
        return undefined;
    }


    return variable_struct_get(
        global.itemclave_db,
        _itemclave_id
    );
}



// =========================================================
// COMPROBAR SI YA LO TENEMOS
// =========================================================

function scr_itemclave_tiene(_itemclave_id)
{
    scr_inventarios_data();


    if (
        !is_string(
            _itemclave_id
        )
        ||
        _itemclave_id == ""
    )
    {
        return false;
    }


    if (
        !variable_global_exists(
            "itemclave_inventory"
        )
        ||
        !is_array(
            global.itemclave_inventory
        )
    )
    {
        return false;
    }


    for (
        var _i = 0;
        _i < 15;
        _i++
    )
    {
        if (
            global.itemclave_inventory[_i]
            ==
            _itemclave_id
        )
        {
            return true;
        }
    }


    return false;
}



// =========================================================
// BUSCAR PRIMER SLOT VACÍO
// =========================================================
//
// Devuelve 0..14.
// Devuelve -1 si los 15 espacios están llenos.
// =========================================================

function scr_itemclave_slot_vacio()
{
    scr_inventarios_data();


    for (
        var _i = 0;
        _i < 15;
        _i++
    )
    {
        if (
            global.itemclave_inventory[_i]
            ==
            -1
            ||
            is_undefined(
                global.itemclave_inventory[_i]
            )
        )
        {
            return _i;
        }
    }


    return -1;
}



// =========================================================
// DAR OBJETO CLAVE
// =========================================================
//
// Los objetos clave son únicos.
//
// Devuelve:
//
// true:
//     Se añadió.
//
// false:
//     La ID no existe, ya lo tenías o los 15 slots
//     están ocupados.
// =========================================================

function scr_itemclave_dar(_itemclave_id)
{
    scr_inventarios_data();


    var _data =
        scr_itemclave_get(
            _itemclave_id
        );


    if (is_undefined(_data))
    {
        show_debug_message(
            "[ITEM CLAVE] ID no encontrada: "
            +
            string(
                _itemclave_id
            )
        );


        return false;
    }


    if (
        scr_itemclave_tiene(
            _itemclave_id
        )
    )
    {
        return false;
    }


    var _slot =
        scr_itemclave_slot_vacio();


    if (_slot == -1)
    {
        show_debug_message(
            "[ITEM CLAVE] Inventario CLAVE lleno. No se pudo añadir: "
            +
            string(
                _itemclave_id
            )
        );


        return false;
    }


    global.itemclave_inventory[_slot] =
        _itemclave_id;


    global.inventory_data.claves =
        global.itemclave_inventory;


    return true;
}



// =========================================================
// QUITAR OBJETO CLAVE
// =========================================================
//
// NO compacta el inventario.
// El slot vuelve a quedar vacío.
//
// Devuelve:
//
// true:
//     Se eliminó.
//
// false:
//     No lo tenías.
// =========================================================

function scr_itemclave_quitar(_itemclave_id)
{
    scr_inventarios_data();


    if (
        !is_string(
            _itemclave_id
        )
        ||
        _itemclave_id == ""
    )
    {
        return false;
    }


    for (
        var _i = 0;
        _i < 15;
        _i++
    )
    {
        if (
            global.itemclave_inventory[_i]
            ==
            _itemclave_id
        )
        {
            global.itemclave_inventory[_i] =
                -1;


            global.inventory_data.claves =
                global.itemclave_inventory;


            return true;
        }
    }


    return false;
}



// =========================================================
// CONSULTAR FUNCIÓN CONFIGURADA
// =========================================================

function scr_itemclave_funcion(_itemclave_id)
{
    var _data =
        scr_itemclave_get(
            _itemclave_id
        );


    if (
        is_undefined(_data)
        ||
        !variable_struct_exists(
            _data,
            "funcion"
        )
    )
    {
        return "";
    }


    return _data.funcion;
}



// =========================================================
// CONSULTAR TEXTO DE USO
// =========================================================

function scr_itemclave_uso(_itemclave_id)
{
    var _data =
        scr_itemclave_get(
            _itemclave_id
        );


    if (
        is_undefined(_data)
        ||
        !variable_struct_exists(
            _data,
            "uso"
        )
    )
    {
        return "";
    }


    return _data.uso;
}



// =========================================================
// CONSULTAR NOMBRE
// =========================================================

function scr_itemclave_nombre(_itemclave_id)
{
    var _data =
        scr_itemclave_get(
            _itemclave_id
        );


    if (
        is_undefined(_data)
        ||
        !variable_struct_exists(
            _data,
            "nombre"
        )
    )
    {
        return "";
    }


    return _data.nombre;
}



// =========================================================
// CONSULTAR DESCRIPCIÓN
// =========================================================

function scr_itemclave_descripcion(_itemclave_id)
{
    var _data =
        scr_itemclave_get(
            _itemclave_id
        );


    if (
        is_undefined(_data)
        ||
        !variable_struct_exists(
            _data,
            "descripcion"
        )
    )
    {
        return "";
    }


    return _data.descripcion;
}
