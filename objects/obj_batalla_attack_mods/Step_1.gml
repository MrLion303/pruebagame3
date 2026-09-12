/// =========================================================
/// OBJ_BATALLA_ATTACK_MODS
/// BEGIN STEP COMPLETO
/// =========================================================

if (room != bbs)
{
    instance_destroy();
    exit;
}


f_prepare_attack();


if (!f_refresh_refs())
    exit;


var _ui =
    ui_ref;


// =========================================================
// INPUT PARA MODOS CUSTOM
// =========================================================

if (custom_mode != "")
{
    custom_accept_pressed =
        keyboard_check_pressed(
            ord("Z")
        )
        ||
        keyboard_check_pressed(
            vk_enter
        );


    custom_accept_held =
        keyboard_check(
            ord("Z")
        )
        ||
        keyboard_check(
            vk_enter
        );


    // =====================================================
    // MULTI-BARRA
    // =====================================================
    // La pulsación que eligió Atacar no debe detener la
    // primera barra. Esperamos únicamente a que se suelte.
    // =====================================================

    if (custom_mode == "multi")
    {
        if (custom_wait_release)
        {
            if (!custom_accept_held)
            {
                custom_wait_release =
                    false;
            }


            custom_accept_pressed =
                false;

            custom_accept_held =
                false;
        }
    }


    // =====================================================
    // ARO CARGADO
    // =====================================================
    // Durante la animación de encogimiento no aceptamos input.
    //
    // Cuando la DIANA ya apareció:
    //     - el cronómetro ya está corriendo;
    //     - primero debe existir un frame con Z/Enter suelto;
    //     - después se exige una pulsación NUEVA.
    //
    // Así mantener Z desde el diálogo anterior NO sirve.
    // =====================================================

    else if (custom_mode == "circle")
    {
        if (!circle_ready)
        {
            custom_accept_pressed =
                false;

            custom_accept_held =
                false;
        }
        else
        {
            if (!circle_input_armed)
            {
                if (!custom_accept_held)
                {
                    circle_input_armed =
                        true;
                }


                custom_accept_pressed =
                    false;

                custom_accept_held =
                    false;
            }
        }
    }


    // Consumir input ANTES del Step de obj_batalla_ui.
    keyboard_clear(
        ord("Z")
    );

    keyboard_clear(
        vk_enter
    );


    // Mantener a la UI base bloqueada en estado de timing.
    attack_timing_active =
        true;

    _ui.attack_timing_active =
        true;

    _ui.attack_timing_stopped =
        false;

    _ui.attack_stop_timer =
        0;

    _ui.attack_bar_speed =
        0;

    _ui.attack_bar_x =
        -9999;


    exit;
}


// =========================================================
// ATAQUE LINEAL NORMAL:
// PRECISIÓN REDUCIDA PUEDE FORZAR MISS
// =========================================================

if (
    action_active
    &&
    single_force_miss
    &&
    _ui.attack_timing_stopped
    &&
    _ui.attack_stop_timer <= 1
)
{
    _ui.attack_timing_stopped =
        false;

    _ui.attack_stop_timer =
        0;


    _ui.f_resolver_timing_ataque(
        true
    );


    _ui.attack_feedback_active =
        true;

    _ui.attack_feedback_timer =
        0;
}
