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


var _ctrl =
    controller_ref;


// =========================================================
// RECORDAR EL ÚLTIMO BOTÓN DE ACCIÓN
// =========================================================
//
// Solo capturamos mientras el jugador está REALMENTE en el menú
// principal de acciones. Cuando obj_batalla_ui pone temporalmente
// opcion_seleccionada = 0 al terminar una acción, la fase ya pasa
// a ENEMIGO_TURNO y por eso NO destruye esta memoria.
// =========================================================

var _phase_is_player =
    (
        _ctrl != noone
        &&
        instance_exists(_ctrl)
        &&
        _ctrl.fase_actual
        ==
        FASE_BATALLA.JUGADOR_MENU
    );


var _victory_dialog =
    variable_instance_exists(
        _ui,
        "en_dialogo_victoria_final"
    )
    &&
    _ui.en_dialogo_victoria_final;


var _main_action_ready =
    _phase_is_player
    &&
    !_victory_dialog
    &&
    !_ui.en_menu_fight
    &&
    !_ui.en_seleccion_enemigo
    &&
    !_ui.en_menu_inventario
    &&
    !_ui.en_menu_toys
    &&
    !_ui.en_resultado_ataque
    &&
    !_ui.attack_timing_active
    &&
    !_ui.attack_timing_stopped
    &&
    !_ui.attack_feedback_active;


// Acabamos de volver del turno enemigo al menú del jugador.
if (
    _phase_is_player
    &&
    !phase_was_player_menu
    &&
    !_victory_dialog
)
{
    _ui.opcion_seleccionada =
        clamp(
            last_action_button,
            0,
            3
        );
}


if (_main_action_ready)
{
    last_action_button =
        clamp(
            _ui.opcion_seleccionada,
            0,
            3
        );
}


phase_was_player_menu =
    _phase_is_player;


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
