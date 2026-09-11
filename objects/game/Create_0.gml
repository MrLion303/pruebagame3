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
// EXTENSIÓN STAD / HABIL
// =========================================================
//
// Se crea AQUÍ, desde el objeto persistente "game", para que
// no dependa de:
//     - tener una habilidad desbloqueada;
//     - que obj_player lo cree a tiempo;
//     - cambios de room.
//
// El objeto también es persistent y simplemente espera cuando
// obj_menu_manager no existe (rm_title, BBS, etc.).
// =========================================================

if (
    !instance_exists(
        obj_menu_habilidades_ext
    )
)
{
    instance_create_depth(
        0,
        0,
        -2000000,
        obj_menu_habilidades_ext
    );
}
