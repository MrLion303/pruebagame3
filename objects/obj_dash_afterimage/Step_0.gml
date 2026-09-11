/// =========================================================
/// OBJ_DASH_AFTERIMAGE
/// STEP - NUEVO
/// =========================================================

ghost_alpha -=
    ghost_fade_speed;


if (
    ghost_alpha
    <=
    0
)
{
    instance_destroy();
}
