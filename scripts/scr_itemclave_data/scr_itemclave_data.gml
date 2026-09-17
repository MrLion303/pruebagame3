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

            // No se dibuja texto de uso en la interfaz base CLAVE.
            // El texto real de utilidad vive en "utilidad".
            uso:
                "",

            utilidad:
                scr_loc_src(
                    "Abre una cerradura de prueba."
                ),

            // No muestra el botón Utilidad en CLAVE.
            mostrar_utilidad:
                false,

            // -1 = espacio reservado sin imagen.
            icono:
                -1,

            funcion:
                "abrir_cerradura_prueba"
        },


        // =================================================
        // TIJERAS DE JARDINERÍA
        // =================================================
        //
        // Objeto clave único.
        // Es una habilidad pasiva permanente. Una vez obtenida,
        // no se usa ni se consume desde el inventario CLAVE.
        // =================================================

        tijeras_jardin:
        {
            nombre:
                scr_loc_src(
                    "Tijeras Jardín"
                ),

            descripcion:
                scr_loc_src(
                    "Unas tijeras de jardinería resistentes."
                ),

            // IMPORTANTE:
            // "uso" queda vacío para que el Draw GUI antiguo de CLAVE
            // no pueda volver a dibujar este texto detrás del panel.
            uso:
                "",

            // Este es el texto REAL que muestra la ficha de Utilidad.
            utilidad:
                scr_loc_src(
                    "Al tenerlas, puedes cortar lianas, cables y cuerdas al interactuar con ellas."
                ),

            // Al seleccionarlas en CLAVE aparece el botón
            // "Utilidad", que abre una ficha con este texto.
            mostrar_utilidad:
                true,

            // Espacio reservado para una imagen.
            // Cuando exista un sprite, cambia -1 por, por ejemplo:
            //     spr_tijeras_jardin
            icono:
                -1,

            funcion:
                "habilidad_pasiva_tijeras",

            // La tienda actual consulta estos campos.
            // Las Tijeras Jardín cuestan 0 Sueños por defecto.
            precio_compra:
                0,

            precio_venta:
                0,

            // Campo informativo para que nunca se trate como
            // un consumible real fuera de la tienda.
            tipo:
                "objeto_clave"
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


    if (is_undefined(_data))
    {
        return "";
    }


    // Nuevo campo: el texto de utilidad se conserva separado
    // de la interfaz base del inventario CLAVE.
    if (
        variable_struct_exists(
            _data,
            "utilidad"
        )
        &&
        is_string(
            _data.utilidad
        )
        &&
        _data.utilidad != ""
    )
    {
        return _data.utilidad;
    }


    // Compatibilidad con objetos clave antiguos.
    if (
        variable_struct_exists(
            _data,
            "uso"
        )
    )
    {
        return _data.uso;
    }


    return "";
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
