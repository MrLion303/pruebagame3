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
    // SINCRONIZAR SISTEMAS
    // =====================================================

    scr_config_sync();

    scr_inventarios_sync();

    // Asegura que el cofre global exista
    // y tenga sus 50 espacios.
    scr_cofre_init();


    // =====================================================
    // POSICIÓN
    // =====================================================

    var _px = 0;
    var _py = 0;

    var _proom = room;

    var _facing = 2;


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


        // -------------------------------------------------
        // NIVEL
        // -------------------------------------------------

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


        // -------------------------------------------------
        // INVENTARIOS
        // -------------------------------------------------

        global.inventory_data.consumibles =
            obj_player.inventory;

        global.inventory_data.equipado_arma =
            obj_player.equipo_arma;

        global.inventory_data.equipado_armadura =
            obj_player.equipo_armadura;
    }


    // =====================================================
    // TODOS LOS DATOS DEL SAVE
    // =====================================================
    //
    // El cofre se guarda completo dentro de extra_data.
    //
    // global.chest_data contiene exactamente 50 slots.
    //
    // Cada Save tiene su propio cofre:
    //
    // Save1 -> su contenido
    // Save2 -> su contenido
    // Save3 -> su contenido
    // =====================================================

    var _save_data =
    {
        config:
            global.config_data,

        inventarios:
            global.inventory_data,

        nivel:
            global.level_data,

        cofre:
            global.chest_data
    };


    // =====================================================
    // JSON + BASE64
    // =====================================================

    var _json_string =
        json_stringify(
            _save_data
        );


    var _base64_string =
        base64_encode(
            _json_string
        );


    // =====================================================
    // ESCRIBIR SAVE.INI
    // =====================================================

    ini_open("save.ini");


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


    // -----------------------------------------------------
    // TIEMPO DE JUEGO
    // -----------------------------------------------------

    ini_write_real(
        _seccion,
        "playtime",
        global.playtime_frames
    );


    // -----------------------------------------------------
    // DATOS EXTRA
    // -----------------------------------------------------

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
    // COMPROBAR ARCHIVO
    // =====================================================

    if (!file_exists("save.ini"))
    {
        return false;
    }


    // =====================================================
    // LEER DATOS PRINCIPALES
    // =====================================================

    ini_open("save.ini");


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
    // DECODIFICAR SAVE
    // =====================================================

    var _json_string =
        base64_decode(
            _extra
        );


    var _save_data =
        json_parse(
            _json_string
        );


    // Seguridad.
    if (!is_struct(_save_data))
    {
        show_debug_message(
            "[SAVE] Error: extra_data no contiene un struct válido."
        );

        return false;
    }


    // =====================================================
    // CONFIGURACIÓN
    // =====================================================

    if (
        variable_struct_exists(
            _save_data,
            "config"
        )
    )
    {
        global.config_data =
            _save_data.config;
    }


    // =====================================================
    // INVENTARIOS
    // =====================================================

    if (
        variable_struct_exists(
            _save_data,
            "inventarios"
        )
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
    )
    {
        global.level_data =
            _save_data.nivel;
    }


    // =====================================================
    // COFRE
    // =====================================================
    //
    // El cofre actual siempre tendrá 50 espacios.
    //
    // Esto también permite cargar:
    //
    // - saves viejos de 20 slots
    // - saves nuevos de 50 slots
    // - saves que todavía no tenían cofre
    //
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
        is_array(
            _save_data.cofre
        )
    )
    {
        var _cofre_guardado =
            _save_data.cofre;


        // ---------------------------------------------
        // COPIAR CONTENIDO
        // ---------------------------------------------
        //
        // Si el save tenía:
        //
        // 20 slots -> copia los 20 y deja 30 vacíos.
        // 50 slots -> copia los 50.
        // más de 50 -> conserva solamente los primeros 50.
        //
        // ---------------------------------------------

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
    // RESTAURAR CONFIGURACIÓN DERIVADA
    // =====================================================

    if (
        variable_global_exists(
            "config_data"
        )
    )
    {
        if (
            is_struct(global.config_data)
            &&
            variable_struct_exists(
                global.config_data,
                "autocorrer_enabled"
            )
        )
        {
            global.autocorrer_enabled =
                global.config_data.autocorrer_enabled;
        }
    }


    // =====================================================
    // RESTAURAR INVENTARIOS GLOBALES
    // =====================================================

    if (
        variable_global_exists(
            "inventory_data"
        )
        &&
        is_struct(
            global.inventory_data
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
    // DIRECCIÓN DEL JUGADOR
    // =====================================================

    global.load_facing =
        _facing;


    show_debug_message(
        "[SAVE] Partida cargada desde "
        +
        _seccion
        +
        ". Cofre: "
        +
        string(array_length(global.chest_data))
        +
        " slots."
    );


    return true;
}



// =========================================================
// APLICAR DATOS CARGADOS AL JUGADOR
// =========================================================

/// @function scr_aplicar_datos_cargados(_jugador)
/// @description Pasa los globales al jugador al iniciar la room
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
            // DERECHA
            case 0:

                _jugador.face =
                    RIGHT;

                _jugador.direccion =
                    "derecha";

                break;


            // IZQUIERDA
            case 1:

                _jugador.face =
                    LEFT;

                _jugador.direccion =
                    "izquierda";

                break;


            // ABAJO
            case 2:

                _jugador.face =
                    DOWN;

                _jugador.direccion =
                    "abajo";

                break;


            // ARRIBA
            case 3:

                _jugador.face =
                    UP;

                _jugador.direccion =
                    "arriba";

                break;
        }
    }
}