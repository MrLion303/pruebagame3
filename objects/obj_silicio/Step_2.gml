/// =========================================================
/// OBJ_SILICIO
/// END STEP
/// =========================================================
///
/// V7 - VIENTO AUTORITATIVO EN RPG + PLATAFORMERO
/// =========================================================

scr_platformer_init();


if (global.platformer_active)
{
    var _fan_detached_platform =
        (
            variable_instance_exists(
                id,
                "fan_detached"
            )
            &&
            fan_detached
        );


    if (_fan_detached_platform)
    {
        party_follow_suspended =
            true;


        movimiento =
            false;


        if (
            variable_instance_exists(
                id,
                "platform_sil_move_x"
            )
        )
        {
            platform_sil_move_x =
                0;
        }


        if (
            variable_instance_exists(
                id,
                "platform_sil_move_y"
            )
        )
        {
            platform_sil_move_y =
                0;
        }


        if (
            variable_instance_exists(
                id,
                "platform_sil_vsp"
            )
        )
        {
            platform_sil_vsp =
                0;
        }


        var _allow_rejoin_run =
            (
                variable_instance_exists(
                    id,
                    "fan_rejoin_active"
                )
                &&
                fan_rejoin_active
                &&
                variable_instance_exists(
                    id,
                    "platform_sil_grounded"
                )
                &&
                platform_sil_grounded
            );


        if (!_allow_rejoin_run)
        {
            image_speed =
                0;
        }
    }
    else
    {
        party_follow_suspended =
            false;


        scr_platformer_silicio_update();
    }
}
else
{
    if (
        variable_instance_exists(
            id,
            "platformer_silicio_applied"
        )
        &&
        platformer_silicio_applied
    )
    {
        scr_platformer_silicio_leave();
    }


    // =====================================================
    // RPG: NO BORRAR EL ESTADO DEL VIENTO
    // =====================================================
    //
    // Este era uno de los fallos reales de la versión anterior:
    // fuera del plataformero este End Step hacía siempre:
    //
    //     party_follow_suspended = false;
    //     fan_detached = false;
    //
    // por lo que el viento de Silicio no podía conservar
    // autoridad durante varios frames.
    // =====================================================

    var _fan_rpg_special =
        (
            variable_instance_exists(
                id,
                "fan_rpg_mode"
            )
            &&
            fan_rpg_mode
            !=
            "none"
        );


    if (_fan_rpg_special)
    {
        fan_detached =
            true;


        var _fan_rpg_following_inside_air =
            (
                fan_rpg_mode
                ==
                "wind_follow"
            );


        // CLAVE:
        // mientras todavía está DENTRO del aire, Silicio sigue
        // usando el follower normal. El viento se suma como un
        // desplazamiento físico independiente.
        party_follow_suspended =
            !_fan_rpg_following_inside_air;


        var _fan_rpg_rejoining =
            (
                variable_instance_exists(
                    id,
                    "fan_rejoin_active"
                )
                &&
                fan_rejoin_active
            );


        if (!_fan_rpg_rejoining)
        {
            movimiento =
                false;

            // Mantener el sprite ACTUAL, pero siempre en frame 0
            // mientras el efecto del aire tenga autoridad visual.
            image_index =
                0;

            image_speed =
                0;
        }
    }
    else
    {
        party_follow_suspended =
            false;


        if (
            variable_instance_exists(
                id,
                "fan_detached"
            )
        )
        {
            fan_detached =
                false;
        }


        if (
            variable_instance_exists(
                id,
                "fan_rejoin_active"
            )
        )
        {
            fan_rejoin_active =
                false;
        }


        if (
            variable_instance_exists(
                id,
                "fan_rejoin_walk_armed"
            )
        )
        {
            fan_rejoin_walk_armed =
                false;
        }
    }
}
