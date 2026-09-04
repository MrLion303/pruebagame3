/// =========================================================
/// OBJETO "game" - STEP
/// =========================================================


// =========================================================
// F3 - INTERFAZ DE DEBUG
// =========================================================

if (
    keyboard_check_pressed(
        vk_f3
    )
)
{
    mostrar_info =
        !mostrar_info;
}


// =========================================================
// F4 - PANTALLA COMPLETA
// =========================================================

if (
    keyboard_check_pressed(
        vk_f4
    )
)
{
    var _fullscreen =
        !window_get_fullscreen();


    window_set_fullscreen(
        _fullscreen
    );


    // Mantener sincronizada la configuración si existe.
    if (
        variable_global_exists(
            "config_data"
        )
        &&
        is_struct(
            global.config_data
        )
    )
    {
        global.config_data.fullscreen_enabled =
            _fullscreen;
    }


    // Mantener sincronizado el menú de pausa si existe.
    if (
        instance_exists(
            obj_menu_manager
        )
    )
    {
        var _menu =
            instance_find(
                obj_menu_manager,
                0
            );


        if (
            _menu != noone
            &&
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


// =========================================================
// CONTADOR DE TIEMPO DE JUEGO
// =========================================================

if (
    variable_global_exists(
        "playtime_frames"
    )
)
{
    global.playtime_frames +=
        1;
}
