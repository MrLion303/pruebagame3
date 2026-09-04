/// =========================================================
/// OBJ_BARRERA_PUZZLE
/// CREATE
/// =========================================================
///
/// Ya NO necesita Parent = colision.
///
/// Crea automáticamente una colisión invisible real.
///
/// Creation Code:
///
///     puzzle_link_id = "puerta_1";
///
/// Debe coincidir con el obj_boton_caja que la destruye.
/// =========================================================

puzzle_link_id =
    "";

image_speed =
    0;


// =========================================================
// COLISIÓN REAL
// =========================================================

collision_proxy =
    scr_puzzle_collision_proxy_create(
        id
    );
