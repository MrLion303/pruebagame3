/// =========================================================
/// SCR_CONTROLS_SYSTEM
/// =========================================================
///
/// Sistema global de controles remapeables.
///
/// Acciones:
///
///     0 = Abajo
///     1 = Derecha
///     2 = Arriba
///     3 = Izquierda
///     4 = Confirmar       (Z)
///     5 = Cancelar/Correr (X)
///     6 = Menu            (C)
///
/// El juego puede seguir usando sus keyboard_check()
/// actuales. keyboard_set_map() convierte la tecla fisica
/// elegida en la tecla que el juego ya espera.
/// =========================================================


// =========================================================
// PREDETERMINADOS
// =========================================================

function scr_controls_defaults()
{
    return
    {
        down:
            vk_down,

        right:
            vk_right,

        up:
            vk_up,

        left:
            vk_left,

        confirm:
            ord("Z"),

        cancel:
            ord("X"),

        menu:
            ord("C")
    };
}


// =========================================================
// TECLA VALIDA
// =========================================================
//
// Permitimos las teclas utiles para este sistema:
//
//     A-Z
//     0-9
//     Flechas
//     Espacio
//     Tab
//     Backspace
//     Delete
//     Insert
//     Home
//     End
//     Page Up / Page Down
//
// Enter, Shift y Ctrl se mantienen como accesos alternativos
// fijos del juego.
//
// Escape cancela la captura.
// =========================================================

function scr_controls_key_valid(_key)
{
    if (
        _key >= ord("A")
        &&
        _key <= ord("Z")
    )
    {
        return true;
    }


    if (
        _key >= ord("0")
        &&
        _key <= ord("9")
    )
    {
        return true;
    }


    switch (_key)
    {
        case vk_left:
        case vk_right:
        case vk_up:
        case vk_down:

        case vk_space:
        case vk_tab:
        case vk_backspace:

        case vk_delete:
        case vk_insert:

        case vk_home:
        case vk_end:

        case vk_pageup:
        case vk_pagedown:
            return true;
    }


    return false;
}


// =========================================================
// ASEGURAR DATOS
// =========================================================

function scr_controls_ensure()
{
    if (
        !variable_global_exists("config_data")
        ||
        !is_struct(global.config_data)
    )
    {
        scr_config_data();
    }


    var _defaults =
        scr_controls_defaults();


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
            _defaults;
    }


    var _c =
        global.config_data.controls;


    if (
        !variable_struct_exists(_c, "down")
        ||
        !scr_controls_key_valid(_c.down)
    )
    {
        _c.down =
            _defaults.down;
    }


    if (
        !variable_struct_exists(_c, "right")
        ||
        !scr_controls_key_valid(_c.right)
    )
    {
        _c.right =
            _defaults.right;
    }


    if (
        !variable_struct_exists(_c, "up")
        ||
        !scr_controls_key_valid(_c.up)
    )
    {
        _c.up =
            _defaults.up;
    }


    if (
        !variable_struct_exists(_c, "left")
        ||
        !scr_controls_key_valid(_c.left)
    )
    {
        _c.left =
            _defaults.left;
    }


    if (
        !variable_struct_exists(_c, "confirm")
        ||
        !scr_controls_key_valid(_c.confirm)
    )
    {
        _c.confirm =
            _defaults.confirm;
    }


    if (
        !variable_struct_exists(_c, "cancel")
        ||
        !scr_controls_key_valid(_c.cancel)
    )
    {
        _c.cancel =
            _defaults.cancel;
    }


    if (
        !variable_struct_exists(_c, "menu")
        ||
        !scr_controls_key_valid(_c.menu)
    )
    {
        _c.menu =
            _defaults.menu;
    }


    return _c;
}


// =========================================================
// OBTENER TECLA
// =========================================================

function scr_controls_get_key(_index)
{
    var _c =
        scr_controls_ensure();


    switch (_index)
    {
        case 0:
            return _c.down;

        case 1:
            return _c.right;

        case 2:
            return _c.up;

        case 3:
            return _c.left;

        case 4:
            return _c.confirm;

        case 5:
            return _c.cancel;

        case 6:
            return _c.menu;
    }


    return vk_nokey;
}


// =========================================================
// CAMBIAR TECLA SIN APLICAR
// =========================================================

function scr_controls_set_key_raw(_index, _key)
{
    var _c =
        scr_controls_ensure();


    switch (_index)
    {
        case 0:
            _c.down =
                _key;
            break;

        case 1:
            _c.right =
                _key;
            break;

        case 2:
            _c.up =
                _key;
            break;

        case 3:
            _c.left =
                _key;
            break;

        case 4:
            _c.confirm =
                _key;
            break;

        case 5:
            _c.cancel =
                _key;
            break;

        case 6:
            _c.menu =
                _key;
            break;
    }
}


// =========================================================
// APLICAR MAPA DE TECLADO
// =========================================================
//
// Ejemplo:
//
//     Confirmar = A
//
// GameMaker recibe:
//
//     A -> Z
//
// y todo el codigo existente que comprueba Z responde a A.
//
// Primero desactivamos las 7 teclas fisicas base para que,
// al cambiarlas, las anteriores dejen de realizar su accion.
//
// Despues aplicamos las asignaciones actuales.
// =========================================================

function scr_controls_apply()
{
    var _c =
        scr_controls_ensure();


    keyboard_unset_map();


    var _targets =
    [
        vk_down,
        vk_right,
        vk_up,
        vk_left,
        ord("Z"),
        ord("X"),
        ord("C")
    ];


    var _physical =
    [
        _c.down,
        _c.right,
        _c.up,
        _c.left,
        _c.confirm,
        _c.cancel,
        _c.menu
    ];


    // Desactivar las teclas base como entradas fisicas.
    for (
        var _i = 0;
        _i < 7;
        _i++
    )
    {
        keyboard_set_map(
            _targets[_i],
            vk_nokey
        );
    }


    // Mapear cada tecla elegida a la accion original.
    for (
        var _j = 0;
        _j < 7;
        _j++
    )
    {
        keyboard_set_map(
            _physical[_j],
            _targets[_j]
        );
    }


    return true;
}


// =========================================================
// CAMBIAR TECLA
// =========================================================
//
// Si la tecla nueva ya la usa otra accion, intercambiamos
// ambas asignaciones.
//
// Asi nunca quedan dos acciones con la misma tecla fisica.
// =========================================================

function scr_controls_set_key(_index, _new_key)
{
    if (
        _index < 0
        ||
        _index > 6
        ||
        !scr_controls_key_valid(_new_key)
    )
    {
        return false;
    }


    var _old_key =
        scr_controls_get_key(
            _index
        );


    for (
        var _i = 0;
        _i < 7;
        _i++
    )
    {
        if (
            _i != _index
            &&
            scr_controls_get_key(_i)
            ==
            _new_key
        )
        {
            scr_controls_set_key_raw(
                _i,
                _old_key
            );

            break;
        }
    }


    scr_controls_set_key_raw(
        _index,
        _new_key
    );


    scr_controls_apply();


    return true;
}


// =========================================================
// RESTAURAR
// =========================================================

function scr_controls_reset()
{
    if (
        !variable_global_exists("config_data")
        ||
        !is_struct(global.config_data)
    )
    {
        scr_config_data();
    }


    global.config_data.controls =
        scr_controls_defaults();


    scr_controls_apply();


    return true;
}


// =========================================================
// NOMBRE VISUAL
// =========================================================

function scr_controls_key_name(_key)
{
    if (
        _key >= ord("A")
        &&
        _key <= ord("Z")
    )
    {
        return chr(_key);
    }


    if (
        _key >= ord("0")
        &&
        _key <= ord("9")
    )
    {
        return chr(_key);
    }


    switch (_key)
    {
        case vk_left:
            return "Left";

        case vk_right:
            return "Right";

        case vk_up:
            return "Up";

        case vk_down:
            return "Down";

        case vk_space:
            return "Space";

        case vk_tab:
            return "Tab";

        case vk_backspace:
            return "Backspace";

        case vk_delete:
            return "Delete";

        case vk_insert:
            return "Insert";

        case vk_home:
            return "Home";

        case vk_end:
            return "End";

        case vk_pageup:
            return "PageUp";

        case vk_pagedown:
            return "PageDown";
    }


    return "?";
}
