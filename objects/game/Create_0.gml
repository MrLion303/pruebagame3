/// =========================================================
/// OBJETO "game" - CREATE
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
