/// =========================================================
/// OBJ_MENU_HABILIDADES_EXT
/// CREATE - NUEVO
/// =========================================================
///
/// **PARENT: ninguno**
///
/// No se coloca manualmente en la room.
/// scr_habilidades_system lo crea automáticamente.
///
/// Extiende INFO_MENU sin reemplazar los archivos enormes de
/// obj_menu_manager.
/// =========================================================

persistent = false;

// Menor depth = se dibuja encima del menú de pausa.
depth = -2000000;


// 0 = STAD
// 1 = HABIL
stad_tab = 0;


// Lista.
habil_index = 0;
habil_scroll = 0;
habil_visible_rows = 5;


// Modal de información.
habil_info_open = false;
habil_info_id = "";


// Detectar entradas nuevas a STAD.
last_menu_state = -1;
