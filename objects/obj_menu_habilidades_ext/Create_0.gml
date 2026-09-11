/// =========================================================
/// OBJ_MENU_HABILIDADES_EXT
/// CREATE COMPLETO
/// =========================================================
///
/// **PARENT: ninguno**
///
/// No se coloca manualmente.
/// El objeto persistente "game" lo crea automáticamente
/// cuando existe obj_menu_manager.
/// =========================================================

persistent =
    false;


// Muy al frente para que su Draw GUI quede encima del Draw GUI
// normal de obj_menu_manager.
depth =
    -100000000;


// =========================================================
// PESTAÑAS
// =========================================================
//
// 0 = STAD
// 1 = HABIL
// =========================================================

stad_tab =
    0;


// Animación igual que INV / EQUIP / CLAVE.
stad_tab_slide =
    0;

stad_tab_slide_speed =
    1 / 12;


// =========================================================
// HABIL
// =========================================================

habil_index =
    0;

habil_scroll =
    0;

habil_visible_rows =
    5;


habil_info_open =
    false;

habil_info_id =
    "";


// Para detectar cuándo entramos de nuevo a STAD.
last_info_active =
    false;
