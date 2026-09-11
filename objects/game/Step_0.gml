/// =========================================================
/// BLOQUEO DURANTE EL SEGUNDO DE MUERTE
/// =========================================================

if (
    variable_global_exists("gameover_death_freeze_active")
    &&
    global.gameover_death_freeze_active
)
{
    // No permitir debug, fullscreen ni sumar playtime
    // mientras el juego está congelado.
    keyboard_clear(ord("C"));
    keyboard_clear(vk_control);
    keyboard_clear(ord("Z"));
    keyboard_clear(vk_enter);
    keyboard_clear(ord("X"));
    keyboard_clear(vk_shift);

    exit;
}


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
