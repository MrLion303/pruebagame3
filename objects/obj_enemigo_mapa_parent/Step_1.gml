/// =========================================================
/// OBJ_ENEMIGO_MAPA_PARENT
/// BEGIN STEP
/// =========================================================
///
/// VIDA + MUERTE DEL MODO PLATAFORMERO.
///
/// DEFAULT V4:
///
///     12 HP
///
/// Puedes sobrescribirlo desde Creation Code:
//
///     platform_hp_max = 20;
///     platform_hp = platform_hp_max;
//
/// También puedes forzar si cuenta como flotante:
//
///     platform_floating = true;
//
///     platform_floating = false;
// =========================================================


// =========================================================
// VIDA
// =========================================================

if (
    !variable_instance_exists(
        id,
        "platform_hp_max"
    )
)
{
    platform_hp_max =
        12;
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


// =========================================================
// ESTADO DE MUERTE
// =========================================================

if (
    !variable_instance_exists(
        id,
        "platform_dying"
    )
)
{
    platform_dying =
        false;
}


if (
    !variable_instance_exists(
        id,
        "platform_death_duration"
    )
)
{
    platform_death_duration =
        15;
}


if (
    !variable_instance_exists(
        id,
        "platform_death_timer"
    )
)
{
    platform_death_timer =
        0;
}


if (
    !variable_instance_exists(
        id,
        "platform_death_alpha_start"
    )
)
{
    platform_death_alpha_start =
        image_alpha;
}


// =========================================================
// DESVANECIMIENTO
// =========================================================

if (platform_dying)
{
    platform_can_be_attacked =
        false;


    platform_hp =
        0;


    if (
        variable_instance_exists(
            id,
            "en_alerta"
        )
    )
    {
        en_alerta =
            false;
    }


    if (
        variable_instance_exists(
            id,
            "puede_moverse"
        )
    )
    {
        puede_moverse =
            false;
    }


    if (
        variable_instance_exists(
            id,
            "rango_ataque"
        )
    )
    {
        rango_ataque =
            -1;
    }


    if (
        variable_instance_exists(
            id,
            "timer_ataque"
        )
    )
    {
        timer_ataque =
            999999;
    }


    speed =
        0;


    hspeed =
        0;


    vspeed =
        0;


    image_speed =
        0;


    platform_death_timer--;


    image_alpha =
        platform_death_alpha_start
        *
        clamp(
            platform_death_timer
            /
            max(
                1,
                platform_death_duration
            ),
            0,
            1
        );


    if (platform_death_timer <= 0)
    {
        instance_destroy();

        exit;
    }


    exit;
}
