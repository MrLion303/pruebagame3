/// =========================================================
/// OBJETO "game" - CREATE COMPLETO
/// =========================================================

// Interfaz de debug oculta al iniciar.
mostrar_info =
    false;


// La consola de desarrollador ya NO se utiliza.
//
// Si quedaron guards antiguos que comprueban esta variable,
// permanecerán siempre desactivados.
global.dev_console_open =
    false;



// =========================================================
// GAME OVER UNIVERSAL
// =========================================================
//
// Este flag congela la lógica durante el segundo posterior
// a que Maya llegue a 0 HP.
//
global.gameover_death_freeze_active =
    false;


// Contador LOCAL del objeto persistente "game".
death_freeze_timer =
    0;


// =========================================================
// STAD / HABIL
// =========================================================
//
// Ya NO se crea ningún objeto auxiliar.
//
// Las pestañas STAD / HABIL viven directamente en:
//
//     obj_menu_manager > End Step
//     obj_menu_manager > Draw GUI End
//
// Por eso obj_menu_habilidades_ext ya no debe aparecer aquí.
// =========================================================
