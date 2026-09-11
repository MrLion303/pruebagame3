/// =========================================================
/// OBJ_PLATFORMER_ATTACK_FX
/// STEP
/// =========================================================

if (
    owner == noone
    ||
    !instance_exists(owner)
)
{
    instance_destroy();

    exit;
}


x =
    owner.x;


y =
    owner.y;


depth =
    owner.depth - 1;


life--;


if (life <= 0)
{
    instance_destroy();
}
