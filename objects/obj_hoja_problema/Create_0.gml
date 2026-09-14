/// =========================================================
/// OBJ_HOJA_PROBLEMA - CREATE
/// =========================================================
///
/// Creation Code disponible:
///
///     sheet_config_id = "figuras_1";
///     sheet_world_sprite = spr_mi_hoja;
///
/// =========================================================

if (
    !variable_instance_exists(
        id,
        "sheet_config_id"
    )
)
{
    sheet_config_id =
        "matematicas_1";
}


if (
    !variable_instance_exists(
        id,
        "sheet_world_sprite"
    )
)
{
    sheet_world_sprite =
        -1;
}


if (
    !variable_instance_exists(
        id,
        "interaction_distance"
    )
)
{
    interaction_distance =
        34;
}


if (
    !variable_instance_exists(
        id,
        "interaction_axis_tolerance"
    )
)
{
    interaction_axis_tolerance =
        16;
}


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
