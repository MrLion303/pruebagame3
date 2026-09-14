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
// ESPERA FINAL DE 1 SEGUNDO
// =========================================================

if (custom_hold_active)
{
    custom_accept_pressed =
        false;

    custom_accept_held =
        false;


    keyboard_clear(
        ord("Z")
    );

    keyboard_clear(
        vk_enter
    );


    // Mantener la interfaz custom congelada y visible.
    _ui.attack_timing_active =
        true;

    _ui.attack_timing_stopped =
        false;

    _ui.attack_bar_speed =
        0;

    _ui.attack_bar_x =
        -9999;


    exit;
}


// =========================================================
// INPUT PARA MODOS CUSTOM
// =========================================================
//
// IMPORTANTE:
//
// obj_batalla_ui también lee Z/Enter durante su Step.
// Necesitamos seguir limpiando la tecla VIRTUAL para que esa UI
// no detenga su barra invisible.
//
// Pero para el Aro Cargado usamos keyboard_check_direct(), que
// sigue leyendo el estado FÍSICO real mientras mantienes Z.
//
// Resultado:
//     pulsas Z -> comienza carga
//     mantienes Z -> NO deja de cargar
//     sueltas Z -> se resuelve
// =========================================================

if (custom_mode != "")
{
    var _direct_held =
        keyboard_check_direct(
            ord("Z")
        )
        ||
        keyboard_check_direct(
            vk_enter
        );


    custom_accept_pressed =
        (
            _direct_held
            &&
            !custom_accept_prev_direct_held
        );


    custom_accept_held =
        _direct_held;


    custom_accept_prev_direct_held =
        _direct_held;


    // =====================================================
    // MULTI-BARRA
    // =====================================================
    // La Z que confirmó "Atacar" no cuenta para la primera
    // barra. Primero debe soltarse.
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
        }
    }


    // =====================================================
    // ARO CARGADO
    // =====================================================
    // Durante el encogimiento ignoramos input.
    //
    // Cuando la diana aparece y el tiempo empieza:
    //     1) si venías sosteniendo Z, primero debes soltar;
    //     2) después haces una NUEVA pulsación;
    //     3) desde ahí la carga continúa mientras Z siga
    //        FÍSICAMENTE mantenida;
    //     4) solo se resuelve al soltar o agotar el tiempo.
    // =====================================================

    else if (custom_mode == "circle")
    {
        if (!circle_ready)
        {
            custom_accept_pressed =
                false;
        }
        else if (!circle_input_armed)
        {
            if (!custom_accept_held)
            {
                circle_input_armed =
                    true;
            }


            custom_accept_pressed =
                false;
        }
    }


    // Bloquear únicamente la lectura VIRTUAL de la UI base.
    // keyboard_check_direct() seguirá viendo el HOLD real.
    keyboard_clear(
        ord("Z")
    );

    keyboard_clear(
        vk_enter
    );


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
