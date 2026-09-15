/// =========================================================
/// OBJ_SILICIO
/// END STEP
/// =========================================================
///
/// V6 - VIENTO AUTORITATIVO
///
/// Mientras fan_detached == true:
///
///     - NO llama scr_platformer_silicio_update();
///     - NO permite que este evento reactive follow;
///     - NO permite animación residual por movimiento;
///     - obj_settings tiene autoridad total sobre su expulsión
///       y posterior reincorporación.
///
/// =========================================================

scr_platformer_init();


if (global.platformer_active)
{
    var _fan_detached =
        (
            variable_instance_exists(
                id,
                "fan_detached"
            )
            &&
            fan_detached
        );


    if (_fan_detached)
    {
        party_follow_suspended =
            true;


        // El viento no es caminar.
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


        // Durante una reincorporación EN SUELO sí puede usar la
        // animación de correr elegida por obj_settings.
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


    if (
        variable_instance_exists(
            id,
            "fan_detach_push_accum"
        )
    )
    {
        fan_detach_push_accum =
            0;
    }
}
