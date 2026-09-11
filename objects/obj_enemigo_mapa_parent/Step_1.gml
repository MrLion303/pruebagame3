/// =========================================================
/// OBJ_ENEMIGO_MAPA_PARENT
/// BEGIN STEP
/// =========================================================
///
/// VIDA PARA EL MODO PLATAFORMERO.
///
/// No modifica la IA normal del enemigo.
/// No inicia batalla.
///
/// DEFAULT:
///
///     3 HP
///
/// Puedes cambiar la vida de una instancia desde Creation
/// Code:
//
///     platform_hp_max = 8;
///     platform_hp = platform_hp_max;
//
/// Si el hijo ya creó estos valores, este evento los respeta.
/// =========================================================

if (
    !variable_instance_exists(
        id,
        "platform_hp_max"
    )
)
{
    platform_hp_max =
        3;
}


platform_hp_max =
    max(
        1,
        round(
            platform_hp_max
        )
    );


if (
    !variable_instance_exists(
        id,
        "platform_hp"
    )
)
{
    platform_hp =
        platform_hp_max;
}


if (
    !variable_instance_exists(
        id,
        "platform_can_be_attacked"
    )
)
{
    platform_can_be_attacked =
        true;
}


if (
    !variable_instance_exists(
        id,
        "platform_last_attack_serial"
    )
)
{
    platform_last_attack_serial =
        -1;
}
