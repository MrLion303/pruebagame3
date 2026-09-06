/// =========================================================
/// SCR_INVENTARIOS_DATA
/// =========================================================
///
/// Fuente central de los inventarios persistentes.
///
/// INVENTARIOS:
///
/// consumibles: 12 slots
/// toys:        30 slots
/// equipamiento:51 slots
/// claves:      15 slots
///
/// =========================================================


function scr_inventarios_data()
{
    // =====================================================
    // CREAR ESTRUCTURA BASE
    // =====================================================

    if (
        !variable_global_exists("inventory_data")
        ||
        !is_struct(global.inventory_data)
    )
    {
        global.inventory_data =
        {
            consumibles:
                [
                    "agua",
                    -1,
                    -1,
                    -1,
                    -1,
                    -1,
                    -1,
                    -1,
                    -1,
                    -1,
                    -1,
                    -1
                ],

            toys:
                array_create(
                    30,
                    -1
                ),

            equipamiento:
                array_create(
                    51,
                    -1
                ),

            // 15 espacios fijos para objetos CLAVE.
            claves:
                array_create(
                    15,
                    -1
                ),

            equipado_arma:
                -1,

            equipado_armadura:
                -1
        };


        global.inventory_data.toys[0] =
            "brillitos";

        global.inventory_data.toys[1] =
            "pegamento";

        global.inventory_data.equipamiento[0] =
            "espada_basica";

        global.inventory_data.equipamiento[1] =
            "armadura_basica";
    }


    // =====================================================
    // COMPATIBILIDAD CON SAVES ANTIGUOS
    // =====================================================
    //
    // Si un save fue creado antes de existir cualquiera de
    // estos campos, se añade aquí sin borrar lo que sí tenía.
    // =====================================================

    if (
        !variable_struct_exists(
            global.inventory_data,
            "consumibles"
        )
        ||
        !is_array(
            global.inventory_data.consumibles
        )
    )
    {
        global.inventory_data.consumibles =
            [
                "agua",
                -1,
                -1,
                -1,
                -1,
                -1,
                -1,
                -1,
                -1,
                -1,
                -1,
                -1
            ];
    }


    if (
        !variable_struct_exists(
            global.inventory_data,
            "toys"
        )
        ||
        !is_array(
            global.inventory_data.toys
        )
    )
    {
        global.inventory_data.toys =
            array_create(
                30,
                -1
            );
    }


    if (
        !variable_struct_exists(
            global.inventory_data,
            "equipamiento"
        )
        ||
        !is_array(
            global.inventory_data.equipamiento
        )
    )
    {
        global.inventory_data.equipamiento =
            array_create(
                51,
                -1
            );
    }


    // =====================================================
    // CLAVES - NORMALIZAR SIEMPRE A 15 SLOTS
    // =====================================================
    //
    // Esto también convierte automáticamente saves creados
    // con la versión anterior, donde CLAVE era un array
    // dinámico.
    // =====================================================

    if (
        !variable_struct_exists(
            global.inventory_data,
            "claves"
        )
        ||
        !is_array(
            global.inventory_data.claves
        )
    )
    {
        global.inventory_data.claves =
            array_create(
                15,
                -1
            );
    }
    else
    {
        var _claves_anteriores =
            global.inventory_data.claves;


        if (
            array_length(
                _claves_anteriores
            )
            !=
            15
        )
        {
            var _claves_nuevas =
                array_create(
                    15,
                    -1
                );


            var _copiar_claves =
                min(
                    15,
                    array_length(
                        _claves_anteriores
                    )
                );


            for (
                var _i = 0;
                _i < _copiar_claves;
                _i++
            )
            {
                _claves_nuevas[_i] =
                    _claves_anteriores[_i];
            }


            global.inventory_data.claves =
                _claves_nuevas;
        }
    }


    if (
        !variable_struct_exists(
            global.inventory_data,
            "equipado_arma"
        )
    )
    {
        global.inventory_data.equipado_arma =
            -1;
    }


    if (
        !variable_struct_exists(
            global.inventory_data,
            "equipado_armadura"
        )
    )
    {
        global.inventory_data.equipado_armadura =
            -1;
    }


    // =====================================================
    // ALIAS DE INVENTARIOS
    // =====================================================

    if (!variable_global_exists("toy_inventory"))
    {
        global.toy_inventory =
            global.inventory_data.toys;
    }


    if (!variable_global_exists("equipment_inventory"))
    {
        global.equipment_inventory =
            global.inventory_data.equipamiento;
    }


    // CLAVE se reasigna siempre a la estructura persistente.
    //
    // Esto es importante después de cargar una partida:
    // evita que quede apuntando al array de la sesión/save
    // anterior.
    global.itemclave_inventory =
        global.inventory_data.claves;


    return global.inventory_data;
}



function scr_inventarios_sync()
{
    scr_inventarios_data();


    // =====================================================
    // SINCRONIZAR ARREGLOS DE INVENTARIO
    // =====================================================

    if (variable_global_exists("toy_inventory"))
    {
        global.inventory_data.toys =
            global.toy_inventory;
    }


    if (variable_global_exists("equipment_inventory"))
    {
        global.inventory_data.equipamiento =
            global.equipment_inventory;
    }


    if (
        variable_global_exists("itemclave_inventory")
        &&
        is_array(global.itemclave_inventory)
    )
    {
        // Seguridad extra: CLAVE siempre debe medir 15.
        if (
            array_length(
                global.itemclave_inventory
            )
            !=
            15
        )
        {
            var _claves_sync =
                array_create(
                    15,
                    -1
                );


            var _copiar_sync =
                min(
                    15,
                    array_length(
                        global.itemclave_inventory
                    )
                );


            for (
                var _j = 0;
                _j < _copiar_sync;
                _j++
            )
            {
                _claves_sync[_j] =
                    global.itemclave_inventory[_j];
            }


            global.itemclave_inventory =
                _claves_sync;
        }


        global.inventory_data.claves =
            global.itemclave_inventory;
    }


    // =====================================================
    // SINCRONIZAR PLAYER
    // =====================================================

    if (instance_exists(obj_player))
    {
        if (
            variable_instance_exists(
                obj_player,
                "inventory"
            )
        )
        {
            global.inventory_data.consumibles =
                obj_player.inventory;
        }


        if (
            variable_instance_exists(
                obj_player,
                "equipo_arma"
            )
        )
        {
            global.inventory_data.equipado_arma =
                obj_player.equipo_arma;
        }


        if (
            variable_instance_exists(
                obj_player,
                "equipo_armadura"
            )
        )
        {
            global.inventory_data.equipado_armadura =
                obj_player.equipo_armadura;
        }
    }


    return global.inventory_data;
}
