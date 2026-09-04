/// =========================================================
/// OBJ_BARRERA_PUZZLE
/// STEP
/// =========================================================
//
// Mantener la colisión invisible sincronizada por si la
// instancia tiene escala, ángulo o sprite personalizado.
// =========================================================

if (
    collision_proxy == noone
    ||
    !instance_exists(
        collision_proxy
    )
)
{
    collision_proxy =
        scr_puzzle_collision_proxy_create(
            id
        );
}


scr_puzzle_collision_proxy_sync(
    id,
    collision_proxy
);
