/// =========================================================
/// OBJ_PLATFORMER_DASH_VISUAL
/// STEP - NUEVO
/// =========================================================

if (
    owner_ref == noone
    ||
    !instance_exists(
        owner_ref
    )
)
{
    instance_destroy();
    exit;
}


if (
    !variable_instance_exists(
        owner_ref,
        "platform_dash_active"
    )
    ||
    !owner_ref.platform_dash_active
)
{
    instance_destroy();
    exit;
}


x =
    owner_ref.x;


y =
    owner_ref.y;


// Dibujar por delante del sprite oculto de Maya.
depth =
    owner_ref.depth
    -
    100;


visual_frame +=
    visual_speed;
