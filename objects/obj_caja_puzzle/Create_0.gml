/// =========================================================
/// OBJ_CAJA_PUZZLE
/// CREATE
/// =========================================================
///
/// frame 0 = caja normal
/// frame 1 = caja resuelta / ya no se puede mover
///
/// YA NO NECESITA:
///
///     Parent = colision
///
/// El objeto crea automáticamente una colisión invisible
/// real de tipo "colision".
/// =========================================================

image_speed =
    0;

image_index =
    0;


// =========================================================
// ESTADO
// =========================================================

locked =
    false;


// Posición original colocada en el Room Editor.
// Se usa solamente para generar una ID automática estable.
puzzle_start_x =
    x;

puzzle_start_y =
    y;


// ID opcional.
//
// Normalmente déjala vacía.
// El sistema genera:
// room + x inicial + y inicial.
puzzle_state_id =
    "";


// Se resuelve en el primer Step para permitir que Creation
// Code pueda sobrescribir puzzle_state_id si alguna vez
// necesitas hacerlo manualmente.
puzzle_initialized =
    false;


// =========================================================
// RUTA
// =========================================================
//
// Un push siempre avanza EXACTAMENTE el tamaño de la caja.
//
// obj_caja_camino únicamente autoriza qué celda existe.
// =========================================================

// Tolerancia para reconocer un nodo/botón colocado en la
// celda esperada.
path_alignment_tolerance =
    4;


// =========================================================
// INTERACCIÓN
// =========================================================

// Distancia máxima entre el borde de Maya y el borde de la caja.
// Usamos bordes, no centros, para que funcione aunque la caja
// tenga un sprite grande.
interaction_gap =
    8;


// Cuánto pueden desalinearse lateralmente Maya y la caja.
interaction_alignment_tolerance =
    18;


// =========================================================
// COLISIÓN REAL
// =========================================================

collision_proxy =
    scr_puzzle_collision_proxy_create(
        id
    );


// =========================================================
// DEPTH SORT
// =========================================================

scr_depth_sort_register(
    id
);
