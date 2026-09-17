/// =========================================================
/// OBJ_SETTINGS
/// BEGIN STEP COMPLETO
/// =========================================================
///
/// NUEVO EVENTO: Begin Step.
///
/// 1) Actualiza el stock ANTES del Step de la tienda.
/// 2) Evita que W/A/S/D naveguen interfaces.
///    Las flechas siguen funcionando normalmente.
///
/// El movimiento normal del overworld NO se altera cuando
/// ninguna interfaz está abierta.
/// =========================================================


// =========================================================
// BLOQUEAR WASD EN INTERFACES
// =========================================================

var _ui_blocks_wasd =
    false;


// Diálogos / cajas de texto.
if (instance_exists(obj_textbox))
{
    _ui_blocks_wasd =
        true;
}


// Pausa auxiliar.
if (instance_exists(obj_pauser))
{
    _ui_blocks_wasd =
        true;
}


// Tienda.
if (instance_exists(obj_shop_controller))
{
    _ui_blocks_wasd =
        true;
}


// Menú de guardado.
if (instance_exists(obj_save_menu))
{
    _ui_blocks_wasd =
        true;
}


// Cofre / inventario del cofre.
if (instance_exists(obj_cofre_ui))
{
    _ui_blocks_wasd =
        true;
}


// Game Over con opciones.
if (instance_exists(obj_game_over_texto))
{
    _ui_blocks_wasd =
        true;
}


// Batalla / UI de batalla.
if (instance_exists(obj_batalla_controller))
{
    _ui_blocks_wasd =
        true;
}


// Menú de pausa principal y todos sus submenús.
if (instance_exists(obj_menu_manager))
{
    var _ui_menu =
        instance_find(
            obj_menu_manager,
            0
        );


    if (
        _ui_menu != noone
        &&
        instance_exists(_ui_menu)
        &&
        variable_instance_exists(
            _ui_menu,
            "state"
        )
        &&
        _ui_menu.state != MENU_STATE.CLOSED
    )
    {
        _ui_blocks_wasd =
            true;
    }
}


if (_ui_blocks_wasd)
{
    keyboard_clear(ord("W"));
    keyboard_clear(ord("A"));
    keyboard_clear(ord("S"));
    keyboard_clear(ord("D"));
}


// =========================================================
// STOCK DE TIENDA
// =========================================================
//
// Begin Step garantiza que una fila agotada quede bloqueada
// antes de que obj_shop_controller procese Z/Enter o flechas.
// =========================================================

scr_shop_stock_guard_update();
