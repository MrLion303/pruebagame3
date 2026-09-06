// =========================================================
// OBJ_COFRE
// DESTROY
// =========================================================
//
// El proxy existe únicamente mientras exista este cofre.
// =========================================================

if (
    variable_instance_exists(
        id,
        "cofre_collision_proxy"
    )
    &&
    cofre_collision_proxy != noone
    &&
    instance_exists(cofre_collision_proxy)
)
{
    with (cofre_collision_proxy)
    {
        instance_destroy();
    }
}
