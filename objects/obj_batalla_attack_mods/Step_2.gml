/// =========================================================
/// OBJ_BATALLA_ATTACK_MODS
/// END STEP COMPLETO
/// =========================================================

if (room != bbs)
    exit;


// Capturar un timing iniciado por obj_batalla_ui este frame.
f_prepare_attack();


if (!f_refresh_refs())
    exit;


var _ui =
    ui_ref;


// =========================================================
// MULTI-HIT LINEAL:
// DETENER UNA BARRA INTERMEDIA = LANZAR LA SIGUIENTE
// =========================================================
//
// No esperamos el segundo completo entre barras.
//
// Resultado:
//
//      [TARGET ÚNICO]
//          barra 1
//          barra 2
//          barra 3
//
// El target no desaparece ni vuelve a "aparecer".
// =========================================================

if (
    chain_active
    &&
    hit_prepared
    &&
    current_mode == "lineal"
    &&
    chain_index < chain_total
    &&
    _ui.attack_timing_stopped
)
{
    f_resolve_current_hit(
        false
    );

    exit;
}


// =========================================================
// LA UI RESOLVIÓ EL GOLPE POR SU CUENTA
// =========================================================
//
// Casos:
// - la barra llegó al borde = MISS;
// - golpe final lineal;
// - golpe único lineal.
//
// Registramos el daño una sola vez.
// =========================================================

if (
    chain_active
    &&
    _ui.attack_feedback_active
    &&
    !feedback_seen
)
{
    chain_total_damage +=
        max(
            0,
            _ui.attack_feedback_damage
        );


    feedback_seen =
        true;


    // -----------------------------------------------------
    // ERA UN GOLPE INTERMEDIO
    // -----------------------------------------------------
    //
    // Esto ocurre principalmente si una barra intermedia llegó
    // hasta el borde y la UI la resolvió como MISS.
    // No mostramos popup todavía: pasamos a la siguiente barra.
    // -----------------------------------------------------

    if (
        f_target_alive()
        &&
        chain_index < chain_total
    )
    {
        f_begin_next_hit();
        exit;
    }


    // -----------------------------------------------------
    // GOLPE FINAL / ÚNICO
    // -----------------------------------------------------

    f_update_total_result_text();


    _ui.attack_feedback_damage =
        max(
            0,
            chain_total_damage
        );


    _ui.attack_feedback_miss =
        chain_total_damage <= 0;


    chain_waiting_feedback =
        true;
}


// =========================================================
// TERMINÓ EL POPUP FINAL
// =========================================================

if (
    chain_active
    &&
    chain_waiting_feedback
    &&
    !_ui.attack_feedback_active
    &&
    _ui.en_resultado_ataque
)
{
    // -----------------------------------------------------
    // CURACIÓN AL FINAL DE TODA LA ACCIÓN
    // -----------------------------------------------------

    var _curado =
        0;


    if (
        chain_heal > 0
        &&
        chain_total_damage > 0
        &&
        instance_exists(obj_player)
    )
    {
        var _hp_antes =
            obj_player.hp;


        obj_player.hp =
            min(
                obj_player.hp_max,
                obj_player.hp
                +
                chain_heal
            );


        _curado =
            obj_player.hp
            -
            _hp_antes;


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


        _ui.f_procesar_dialogo(
            _texto_final
        );
    }


    // -----------------------------------------------------
    // RESTAURAR ESTÁNDAR
    // -----------------------------------------------------

    _ui.attack_perfect_radius =
        4.0;


    current_bar_xscale =
        1.0;


    chain_active =
        false;

    chain_total =
        1;

    chain_index =
        0;

    chain_target =
        -1;

    chain_total_damage =
        0;

    chain_heal =
        0;

    chain_waiting_feedback =
        false;


    feedback_seen =
        false;

    hit_prepared =
        false;


    current_mode =
        "lineal";

    current_force_miss =
        false;


    circle_active =
        false;

    circle_started =
        false;

    circle_timer =
        0;
}
