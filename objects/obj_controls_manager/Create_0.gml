/// =========================================================
/// OBJ_CONTROLS_MANAGER
/// CREATE
/// =========================================================
///
/// Gestor visual y de captura del apartado:
///
///     CONFIG -> Controles
///
/// No reemplaza obj_menu_manager.
/// Se dibuja encima de la zona "Proximamente..." existente.
/// =========================================================


// =========================================================
// ESTADO DE LA LISTA
// =========================================================

control_index =
    0;


control_scroll =
    0;


controls_visible_rows =
    6;


// =========================================================
// CAPTURA DE TECLA
// =========================================================

controls_listening =
    false;


controls_wait_release =
    false;


// =========================================================
// MENSAJE INFERIOR
// =========================================================

controls_message =
    "";


controls_message_timer =
    0;


// =========================================================
// DETECTAR ENTRADA A CONFIG_ACTION
// =========================================================

controls_last_state =
    -1;


// =========================================================
// DIBUJAR DELANTE DE OBJ_MENU_MANAGER
// =========================================================

depth =
    -1000000;


// =========================================================
// ASEGURAR / APLICAR CONFIG
// =========================================================

scr_config_data();

scr_controls_apply();
