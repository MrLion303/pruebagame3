// =========================================================
/// OBJ_SAVE
/// CREATE
/// =========================================================

// Valor por defecto.
room_to_save =
    global.rm1;


// =========================================================
// DEPTH SORT AUTOMÁTICO
// =========================================================
//
// Ahora el punto de guardado puede quedar:
//
//     detrás de Maya si Maya está más abajo;
//
// y:
//
//     delante de Maya si Maya está más arriba.
//
scr_depth_sort_register(
    id
);
