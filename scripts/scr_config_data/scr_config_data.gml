/// =========================================================
/// SCR_CONFIG_DATA
///
/// Maneja la configuración persistente de cada partida.
///
/// Guarda:
/// - Volumen general
/// - Pantalla completa
/// - Auto-correr
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
                _autocorrer_inicial
        };
    }


    // =====================================================
    // COMPATIBILIDAD CON GUARDADOS ANTIGUOS
    // =====================================================
    //
    // Si cargas un save creado antes de agregar alguna
    // de estas opciones, se crea automáticamente.
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


    return global.config_data;
}


// =========================================================
// SINCRONIZAR CONFIG ACTUAL
// =========================================================
//
// Se llama justo antes de guardar.
//
// Toma los valores que actualmente tiene el menú
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


    return global.config_data;
}


// =========================================================
// APLICAR CONFIG CARGADA
// =========================================================
//
// Se ejecuta después de cargar un Save.
//
// Aplica realmente:
// - volumen
// - fullscreen
// - auto-correr
//
// También actualiza visualmente obj_menu_manager.
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


    // Solo cambiarla si realmente es diferente.
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