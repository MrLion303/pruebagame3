/// =========================================================
/// OBJ_BARRERA_CORTABLE
/// DESTROY COMPLETO
/// =========================================================

if (
    variable_instance_exists(
        id,
        "collision_proxy"
    )
)
{
    scr_puzzle_collision_proxy_destroy(
        collision_proxy
    );
}
