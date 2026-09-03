// =========================================================
// OBJETO "game" - CREATE
// =========================================================
//
// Profundidad muy baja para que su Draw GUI sea de los
// últimos en dibujarse.
// =========================================================

depth =
    -10000001;


// Interruptor para mostrar las coordenadas
// Inicia en false para que esté oculto por defecto
mostrar_info = false;

// =========================================================
// CONSOLA DE DESARROLLADOR
// =========================================================

global.dev_console_open = false;

if (!instance_exists(obj_dev_console))
{
    instance_create_depth(
        0,
        0,
        -10000000,
        obj_dev_console
    );
}

