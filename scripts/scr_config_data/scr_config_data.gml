/// =========================================================
/// SCR_CONFIG_DATA
///
/// Maneja la configuracion persistente de cada partida.
///
/// Guarda:
/// - Volumen general
/// - Pantalla completa
/// - Auto-correr
/// - Controles personalizados
/// =========================================================


// =========================================================
// CREAR / ASEGURAR DATOS
// =========================================================

function scr_config_data()
{
    // =====================================================
    // CREAR CONFIG POR PRIMERA VEZ
    // =====================================================

    if (
        !variable_global_exists("config_data")
        ||
        !is_struct(global.config_data)
    )
    {
        var _autocorrer_inicial =
            false;


        if (
            variable_global_exists(
                "autocorrer_enabled"
            )
        )
        {
            _autocorrer_inicial =
                global.autocorrer_enabled;
        }


        global.config_data =
        {
            master_volume:
                1.0,

            fullscreen_enabled:
                window_get_fullscreen(),

            autocorrer_enabled:
                _autocorrer_inicial,

            controls:
                scr_controls_defaults()
        };
    }


    // =====================================================
    // COMPATIBILIDAD CON GUARDADOS ANTIGUOS
    // =====================================================

    if (
        !variable_struct_exists(
            global.config_data,
            "master_volume"
        )
    )
    {
        global.config_data.master_volume =
            1.0;
    }


    if (
        !variable_struct_exists(
            global.config_data,
            "fullscreen_enabled"
        )
    )
    {
        global.config_data.fullscreen_enabled =
            window_get_fullscreen();
    }


    if (
        !variable_struct_exists(
            global.config_data,
            "autocorrer_enabled"
        )
    )
    {
        global.config_data.autocorrer_enabled =
            false;
    }


    if (
        !variable_struct_exists(
            global.config_data,
            "controls"
        )
        ||
        !is_struct(
            global.config_data.controls
        )
    )
    {
        global.config_data.controls =
            scr_controls_defaults();
    }


    // Añadir / reparar campos de controles de saves viejos.
    var _defaults =
        scr_controls_defaults();


    var _controls =
        global.config_data.controls;


    if (
        !variable_struct_exists(_controls, "down")
        ||
        !scr_controls_key_valid(_controls.down)
    )
    {
        _controls.down =
            _defaults.down;
    }


    if (
        !variable_struct_exists(_controls, "right")
        ||
        !scr_controls_key_valid(_controls.right)
    )
    {
        _controls.right =
            _defaults.right;
    }


    if (
        !variable_struct_exists(_controls, "up")
        ||
        !scr_controls_key_valid(_controls.up)
    )
    {
        _controls.up =
            _defaults.up;
    }


    if (
        !variable_struct_exists(_controls, "left")
        ||
        !scr_controls_key_valid(_controls.left)
    )
    {
        _controls.left =
            _defaults.left;
    }


    if (
        !variable_struct_exists(_controls, "confirm")
        ||
        !scr_controls_key_valid(_controls.confirm)
    )
    {
        _controls.confirm =
            _defaults.confirm;
    }


    if (
        !variable_struct_exists(_controls, "cancel")
        ||
        !scr_controls_key_valid(_controls.cancel)
    )
    {
        _controls.cancel =
            _defaults.cancel;
    }


    if (
        !variable_struct_exists(_controls, "menu")
        ||
        !scr_controls_key_valid(_controls.menu)
    )
    {
        _controls.menu =
            _defaults.menu;
    }


    return global.config_data;
}


// =========================================================
// SINCRONIZAR CONFIG ACTUAL
// =========================================================
//
// Se llama justo antes de guardar.
//
// Toma los valores que actualmente tiene el menu
// y los copia a global.config_data.
// =========================================================

function scr_config_sync()
{
    scr_config_data();


    // =====================================================
    // OBJ_MENU_MANAGER
    // =====================================================

    if (instance_exists(obj_menu_manager))
    {
        var _menu =
            instance_find(
                obj_menu_manager,
                0
            );


        // -------------------------------------------------
        // VOLUMEN
        // -------------------------------------------------

        if (
            variable_instance_exists(
                _menu,
                "master_volume"
            )
        )
        {
            global.config_data.master_volume =
                _menu.master_volume;
        }


        // -------------------------------------------------
        // PANTALLA COMPLETA
        // -------------------------------------------------

        if (
            variable_instance_exists(
                _menu,
                "fullscreen_enabled"
            )
        )
        {
            global.config_data.fullscreen_enabled =
                _menu.fullscreen_enabled;
        }
    }


    // =====================================================
    // AUTO-CORRER
    // =====================================================

    if (
        variable_global_exists(
            "autocorrer_enabled"
        )
    )
    {
        global.config_data.autocorrer_enabled =
            global.autocorrer_enabled;
    }


    // Los controles viven directamente en:
    //
    //     global.config_data.controls
    //
    // Solo aseguramos su estructura.
    scr_controls_ensure();


    return global.config_data;
}


// =========================================================
// APLICAR CONFIG CARGADA
// =========================================================
//
// Se ejecuta despues de cargar un Save.
//
// Aplica:
// - volumen
// - fullscreen
// - auto-correr
// - controles
// =========================================================

function scr_config_apply()
{
    scr_config_data();


    // =====================================================
    // VOLUMEN
    // =====================================================

    var _volumen =
        clamp(
            global.config_data.master_volume,
            0,
            1
        );


    global.config_data.master_volume =
        _volumen;


    audio_master_gain(
        _volumen
    );


    // =====================================================
    // PANTALLA COMPLETA
    // =====================================================

    var _fullscreen =
        global.config_data.fullscreen_enabled;


    if (
        window_get_fullscreen()
        !=
        _fullscreen
    )
    {
        window_set_fullscreen(
            _fullscreen
        );
    }


    // =====================================================
    // AUTO-CORRER
    // =====================================================

    global.autocorrer_enabled =
        global.config_data.autocorrer_enabled;


    // =====================================================
    // CONTROLES
    // =====================================================

    scr_controls_apply();


    // =====================================================
    // ACTUALIZAR OBJ_MENU_MANAGER
    // =====================================================

    if (instance_exists(obj_menu_manager))
    {
        var _menu =
            instance_find(
                obj_menu_manager,
                0
            );


        if (
            variable_instance_exists(
                _menu,
                "master_volume"
            )
        )
        {
            _menu.master_volume =
                _volumen;
        }


        if (
            variable_instance_exists(
                _menu,
                "fullscreen_enabled"
            )
        )
        {
            _menu.fullscreen_enabled =
                _fullscreen;
        }
    }
}
