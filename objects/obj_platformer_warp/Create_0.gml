/// =========================================================
/// OBJ_PLATFORMER_WARP
/// CREATE COMPLETO
/// =========================================================
///
/// Este objeto usa directamente el sistema actual:
///
///     scr_platformer_warp_activate(id)
///
/// IMPORTANTE:
///
/// Los nombres de variables coinciden con los Creation Code
/// que YA existen en tus rooms:
//
///     platformer_enable
///     target_room
///     target_x
///     target_y
///     target_face
///     target_music
///     keep_music
///     platformer_start_facing
///
/// =========================================================


// =========================================================
// DESTINO
// =========================================================

if (
    !variable_instance_exists(
        id,
        "target_room"
    )
)
{
    target_room =
        noone;
}


if (
    !variable_instance_exists(
        id,
        "target_x"
    )
)
{
    target_x =
        0;
}


if (
    !variable_instance_exists(
        id,
        "target_y"
    )
)
{
    target_y =
        0;
}


if (
    !variable_instance_exists(
        id,
        "target_face"
    )
)
{
    target_face =
        DOWN;
}


if (
    !variable_instance_exists(
        id,
        "target_music"
    )
)
{
    target_music =
        -1;
}


if (
    !variable_instance_exists(
        id,
        "keep_music"
    )
)
{
    keep_music =
        false;
}


// =========================================================
// MODO PLATAFORMERO DEL DESTINO
// =========================================================
//
// true:
//     entra al modo plataformero al llegar.
//
// false:
//     sale del modo plataformero al llegar.
//
// =========================================================

if (
    !variable_instance_exists(
        id,
        "platformer_enable"
    )
)
{
    platformer_enable =
        true;
}


// Dirección horizontal inicial al entrar:
//
//     -1 = izquierda
//      1 = derecha
//
if (
    !variable_instance_exists(
        id,
        "platformer_start_facing"
    )
)
{
    platformer_start_facing =
        1;
}


// =========================================================
// INTERACCIÓN
// =========================================================

if (
    !variable_instance_exists(
        id,
        "active"
    )
)
{
    active =
        true;
}


// Se conserva también este nombre por compatibilidad con
// versiones anteriores del objeto.
if (
    !variable_instance_exists(
        id,
        "interaction_enabled"
    )
)
{
    interaction_enabled =
        true;
}


// Área FIJA alrededor del centro del objeto:
//
//     20 x 20 px
//
if (
    !variable_instance_exists(
        id,
        "interaction_size"
    )
)
{
    interaction_size =
        20;
}


if (
    !variable_instance_exists(
        id,
        "show_prompt"
    )
)
{
    show_prompt =
        true;
}


if (
    !variable_instance_exists(
        id,
        "prompt_text"
    )
)
{
    prompt_text =
        "[Z]";
}


interaction_locked =
    false;


prompt_visible =
    false;
