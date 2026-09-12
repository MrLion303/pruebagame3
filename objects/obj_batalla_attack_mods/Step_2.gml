/// =========================================================
/// OBJ_BATALLA_ATTACK_MODS
/// END STEP COMPLETO
/// =========================================================

if (room != bbs)
    exit;


// Captura el timing que obj_batalla_ui pudo haber iniciado
// durante su propio Step en este mismo frame.
f_prepare_attack();


if (!f_refresh_refs())
    exit;


var _ui =
    ui_ref;


// =========================================================
// ATAQUE LINEAL NORMAL / ESPADA CERTERA
// =========================================================
//
// Los modos multi y circular resuelven sus propios golpes.
// =========================================================

if (
    action_active
    &&
    custom_mode == ""
    &&
    _ui.attack_feedback_active
    &&
    !action_feedback_seen
)
{
    action_total_damage +=
        max(
            0,
            _ui.attack_feedback_damage
        );


    action_feedback_seen =
        true;

    action_feedback_started =
        true;


    f_update_total_result_text();


    _ui.attack_feedback_damage =
        max(
            0,
            action_total_damage
        );


    _ui.attack_feedback_miss =
        action_total_damage <= 0;
}


// =========================================================
// TERMINÓ EL POPUP FINAL
// =========================================================

if (
    action_active
    &&
    action_feedback_started
    &&
    !_ui.attack_feedback_active
    &&
    _ui.en_resultado_ataque
)
{
    f_finish_action();
}
