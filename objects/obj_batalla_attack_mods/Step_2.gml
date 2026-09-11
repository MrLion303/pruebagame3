/// =========================================================
/// OBJ_BATALLA_ATTACK_MODS
/// END STEP - NUEVO
/// =========================================================

if (room != bbs)
    exit;


// Capturar un timing iniciado por obj_batalla_ui este frame.
f_prepare_attack();

if (!f_refresh_refs())
    exit;

var _ui = ui_ref;


// Registrar una vez el daño del popup actual.
if (
    chain_active
    &&
    _ui.attack_feedback_active
    &&
    !feedback_seen
)
{
    chain_total_damage +=
        max(0, _ui.attack_feedback_damage);

    feedback_seen = true;
}


// El popup terminó y UI ya generó el texto de resultado.
if (
    chain_active
    &&
    feedback_seen
    &&
    !_ui.attack_feedback_active
    &&
    _ui.en_resultado_ataque
)
{
    var _enemigo_vivo =
        (
            chain_target >= 0
            &&
            chain_target < array_length(_ui.enemigos)
            &&
            _ui.enemigos[chain_target].vida_actual > 0
        );


    // -----------------------------------------------------
    // SIGUIENTE GOLPE
    // -----------------------------------------------------

    if (
        _enemigo_vivo
        &&
        chain_index < chain_total
    )
    {
        chain_index++;

        feedback_seen = false;
        hit_prepared = false;

        _ui.en_resultado_ataque = false;
        _ui.text_to_draw = "";
        _ui.text_length = 0;
        _ui.draw_char = 0;
        _ui.setup = false;

        _ui.f_iniciar_timing_ataque(chain_target);

        // Si es circular, convertirlo antes de Draw GUI.
        f_prepare_attack();

        exit;
    }


    // -----------------------------------------------------
    // CURACIÓN AL FINAL DE TODA LA ACCIÓN
    // -----------------------------------------------------

    var _curado = 0;

    if (
        chain_heal > 0
        &&
        chain_total_damage > 0
        &&
        instance_exists(obj_player)
    )
    {
        var _hp_antes = obj_player.hp;

        obj_player.hp =
            min(
                obj_player.hp_max,
                obj_player.hp + chain_heal
            );

        _curado =
            obj_player.hp - _hp_antes;

        global.player_hp_current =
            obj_player.hp;
    }


    if (_curado > 0)
    {
        var _texto_final =
            _ui.attack_result_text
            +
            "\n* Recuperaste "
            +
            string(_curado)
            +
            " HP.";

        _ui.f_procesar_dialogo(_texto_final);
    }


    // Restaurar estándar.
    _ui.attack_perfect_radius = 4.0;

    chain_active = false;
    chain_total = 1;
    chain_index = 0;
    chain_target = -1;
    chain_total_damage = 0;
    chain_heal = 0;

    feedback_seen = false;
    hit_prepared = false;

    current_mode = "lineal";
    current_after_center = false;
    current_force_miss = false;
}
