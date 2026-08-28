/// =========================================================
/// SCR_SAVE_SYSTEM
/// =========================================================



// =========================================================
// GUARDAR
// =========================================================

/// @function scr_guardar_juego(_seccion)
function scr_guardar_juego(_seccion)
{
    // =====================================================
    // ASEGURAR SISTEMAS
    // =====================================================

    scr_level_data();

    scr_inventarios_data();

    scr_config_data();

    scr_cofre_init();


    // =====================================================
    // SINCRONIZAR DATOS ACTUALES
    // =====================================================

    scr_config_sync();

    scr_inventarios_sync();


    // =====================================================
    // POSICIÓN
    // =====================================================

    var _px =
        0;

    var _py =
        0;

    var _proom =
        room;

    var _facing =
        2;


    // =====================================================
    // DATOS DEL JUGADOR
    // =====================================================

    if (instance_exists(obj_player))
    {
        _px =
            obj_player.x;


        _py =
            obj_player.y;


        _proom =
            room;


        _facing =
            obj_player.face;


        // =================================================
        // NIVEL
        // =================================================

        global.level_data.nivel =
            obj_player.nivel;


        global.level_data.exp_actual =
            obj_player.exp_actual;


        global.level_data.exp_siguiente =
            obj_player.exp_siguiente;


        global.level_data.ataque_base =
            obj_player.ataque_base;


        global.level_data.defensa_base =
            obj_player.defensa_base;


        global.level_data.hp_max =
            obj_player.hp_max;


        // =================================================
        // INVENTARIO
        // =================================================

        global.inventory_data.consumibles =
            obj_player.inventory;


        global.inventory_data.equipado_arma =
            obj_player.equipo_arma;


        global.inventory_data.equipado_armadura =
            obj_player.equipo_armadura;
    }


    // =====================================================
    // DATOS COMPLETOS DEL SAVE
    // =====================================================

    var _save_data =
    {
        // -------------------------------------------------
        // CONFIGURACIÓN
        // -------------------------------------------------

        config:
            global.config_data,


        // -------------------------------------------------
        // INVENTARIOS
        // -------------------------------------------------

        inventarios:
            global.inventory_data,


        // -------------------------------------------------
        // NIVEL
        // -------------------------------------------------

        nivel:
            global.level_data,


        // -------------------------------------------------
        // COFRE
        // -------------------------------------------------

        cofre:
            global.chest_data
    };


    // =====================================================
    // JSON
    // =====================================================

    var _json_string =
        json_stringify(
            _save_data
        );


    // =====================================================
    // BASE64
    // =====================================================

    var _base64_string =
        base64_encode(
            _json_string
        );


    // =====================================================
    // GUARDAR EN SAVE.INI
    // =====================================================

    ini_open(
        "save.ini"
    );


    ini_write_real(
        _seccion,
        "room",
        _proom
    );


    ini_write_real(
        _seccion,
        "x",
        _px
    );


    ini_write_real(
        _seccion,
        "y",
        _py
    );


    ini_write_real(
        _seccion,
        "facing",
        _facing
    );


    // =====================================================
    // TIEMPO
    // =====================================================

    ini_write_real(
        _seccion,
        "playtime",
        global.playtime_frames
    );


    // =====================================================
    // DATOS COMPLETOS
    // =====================================================

    ini_write_string(
        _seccion,
        "extra_data",
        _base64_string
    );


    ini_close();


    show_debug_message(
        "¡Juego guardado en "
        +
        _seccion
        +
        " con éxito!"
    );
}



// =========================================================
// CARGAR
// =========================================================

/// @function scr_cargar_juego(_seccion)
function scr_cargar_juego(_seccion)
{
    // =====================================================
    // ARCHIVO NO EXISTE
    // =====================================================

    if (!file_exists("save.ini"))
    {
        return false;
    }


    // =====================================================
    // LEER SAVE
    // =====================================================

    ini_open(
        "save.ini"
    );


    var _extra =
        ini_read_string(
            _seccion,
            "extra_data",
            ""
        );


    var _facing =
        ini_read_real(
            _seccion,
            "facing",
            2
        );


    global.playtime_frames =
        ini_read_real(
            _seccion,
            "playtime",
            0
        );


    ini_close();


    // =====================================================
    // SLOT VACÍO
    // =====================================================

    if (_extra == "")
    {
        return false;
    }


    // =====================================================
    // DECODIFICAR
    // =====================================================

    var _json_string =
        base64_decode(
            _extra
        );


    var _save_data =
        json_parse(
            _json_string
        );


    if (!is_struct(_save_data))
    {
        return false;
    }


    // =====================================================
    // ASEGURAR VALORES BASE
    // =====================================================

    scr_config_data();

    scr_inventarios_data();

    scr_level_data();

    scr_cofre_init();


    // =====================================================
    // CONFIGURACIÓN
    // =====================================================

    if (
        variable_struct_exists(
            _save_data,
            "config"
        )
        &&
        is_struct(_save_data.config)
    )
    {
        global.config_data =
            _save_data.config;
    }


    // Añadir campos faltantes de saves antiguos.
    scr_config_data();


    // =====================================================
    // INVENTARIOS
    // =====================================================

    if (
        variable_struct_exists(
            _save_data,
            "inventarios"
        )
        &&
        is_struct(_save_data.inventarios)
    )
    {
        global.inventory_data =
            _save_data.inventarios;
    }


    // =====================================================
    // NIVEL
    // =====================================================

    if (
        variable_struct_exists(
            _save_data,
            "nivel"
        )
        &&
        is_struct(_save_data.nivel)
    )
    {
        global.level_data =
            _save_data.nivel;
    }


    // =====================================================
    // COFRE
    // =====================================================
    //
    // Siempre reconstruimos un cofre nuevo de 50 slots.
    //
    // Después copiamos lo que exista dentro del save.
    //
    // Así:
    //
    // - saves viejos de 20 slots funcionan
    // - saves actuales de 50 funcionan
    // - nunca quedan slots basura
    // =====================================================

    global.chest_data =
        array_create(
            50,
            -1
        );


    if (
        variable_struct_exists(
            _save_data,
            "cofre"
        )
        &&
        is_array(_save_data.cofre)
    )
    {
        var _cofre_guardado =
            _save_data.cofre;


        var _cantidad_copiar =
            min(
                50,
                array_length(
                    _cofre_guardado
                )
            );


        for (
            var i = 0;
            i < _cantidad_copiar;
            i++
        )
        {
            global.chest_data[i] =
                _cofre_guardado[i];
        }
    }


    // =====================================================
    // RESTAURAR INVENTARIOS DERIVADOS
    // =====================================================

    if (
        variable_global_exists(
            "inventory_data"
        )
    )
    {
        if (
            variable_struct_exists(
                global.inventory_data,
                "toys"
            )
        )
        {
            global.toy_inventory =
                global.inventory_data.toys;
        }


        if (
            variable_struct_exists(
                global.inventory_data,
                "equipamiento"
            )
        )
        {
            global.equipment_inventory =
                global.inventory_data.equipamiento;
        }
    }


    // =====================================================
    // APLICAR CONFIGURACIÓN CARGADA
    // =====================================================
    //
    // Aquí es donde realmente cambia:
    //
    // volumen
    // fullscreen
    // auto-correr
    // =====================================================

    scr_config_apply();


    // =====================================================
    // DIRECCIÓN
    // =====================================================

    global.load_facing =
        _facing;


    return true;
}



// =========================================================
// APLICAR DATOS CARGADOS AL JUGADOR
// =========================================================

/// @function scr_aplicar_datos_cargados(_jugador)
function scr_aplicar_datos_cargados(_jugador)
{
    // =====================================================
    // NIVEL
    // =====================================================

    _jugador.nivel =
        global.level_data.nivel;


    _jugador.exp_actual =
        global.level_data.exp_actual;


    _jugador.exp_siguiente =
        global.level_data.exp_siguiente;


    _jugador.ataque_base =
        global.level_data.ataque_base;


    _jugador.defensa_base =
        global.level_data.defensa_base;


    _jugador.hp_max =
        global.level_data.hp_max;


    _jugador.hp =
        global.level_data.hp_max;


    // =====================================================
    // INVENTARIO
    // =====================================================

    _jugador.inventory =
        global.inventory_data.consumibles;


    _jugador.equipo_arma =
        global.inventory_data.equipado_arma;


    _jugador.equipo_armadura =
        global.inventory_data.equipado_armadura;


    // =====================================================
    // DIRECCIÓN
    // =====================================================

    if (
        variable_global_exists(
            "load_facing"
        )
    )
    {
        _jugador.facing_direction =
            global.load_facing;


        switch (global.load_facing)
        {
            // =================================================
            // DERECHA
            // =================================================

            case 0:

                _jugador.face =
                    RIGHT;

                _jugador.direccion =
                    "derecha";

                break;


            // =================================================
            // IZQUIERDA
            // =================================================

            case 1:

                _jugador.face =
                    LEFT;

                _jugador.direccion =
                    "izquierda";

                break;


            // =================================================
            // ABAJO
            // =================================================

            case 2:

                _jugador.face =
                    DOWN;

                _jugador.direccion =
                    "abajo";

                break;


            // =================================================
            // ARRIBA
            // =================================================

            case 3:

                _jugador.face =
                    UP;

                _jugador.direccion =
                    "arriba";

                break;
        }
    }
}