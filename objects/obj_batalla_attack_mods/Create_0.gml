/// =========================================================
/// OBJ_BATALLA_ATTACK_MODS
/// CREATE COMPLETO
/// =========================================================
/// PARENT: ninguno
///
/// Cambios:
/// - Multi-hit usa UN SOLO target/diana.
/// - Las barras/cargas pasan inmediatamente una tras otra.
/// - Aro cargado corregido.
/// - Espada Certera ensancha la barra móvil REAL.
/// - Eliminada por completo la confirmación tardía.
/// =========================================================

persistent = false;

// Debe quedar por encima de la UI de batalla.
// Un depth muy bajo se dibuja al frente.
depth = -1000000000;

controller_ref = noone;
ui_ref = noone;


// =========================================================
// CADENA DE GOLPES
// =========================================================

chain_active = false;
chain_total = 1;
chain_index = 0;
chain_target = -1;

chain_total_damage = 0;
chain_heal = 0;

chain_waiting_feedback = false;
feedback_seen = false;

hit_prepared = false;


// =========================================================
// MODIFICADORES DEL GOLPE ACTUAL
// =========================================================

weapon_mods = scr_battle_get_weapon_mods();

current_mode = "lineal";
current_force_miss = false;

// Solo afecta al dibujo adicional de la barra ensanchada.
// El target NO cambia de tamaño.
current_bar_xscale = 1.0;


// =========================================================
// ATAQUE CIRCULAR
// =========================================================

circle_active = false;
circle_started = false;
circle_timer = 0;

circle_limit = 24;

circle_radius = 4;
circle_radius_start = 4;
circle_radius_target = 64;
circle_radius_max = 90;

circle_speed = 5.5;
circle_perfect_tolerance = 5;


// =========================================================
// REFERENCIAS
// =========================================================

f_refresh_refs =
function()
{
    controller_ref =
        instance_exists(obj_batalla_controller)
        ? instance_find(obj_batalla_controller, 0)
        : noone;

    ui_ref =
        instance_exists(obj_batalla_ui)
        ? instance_find(obj_batalla_ui, 0)
        : noone;

    return
        controller_ref != noone
        &&
        ui_ref != noone
        &&
        instance_exists(controller_ref)
        &&
        instance_exists(ui_ref);
};


// =========================================================
// ¿SIGUE VIVO EL TARGET?
// =========================================================

f_target_alive =
function()
{
    if (!f_refresh_refs())
        return false;

    var _ui = ui_ref;

    if (
        chain_target < 0
        ||
        chain_target >= array_length(_ui.enemigos)
    )
    {
        return false;
    }

    var _en = _ui.enemigos[chain_target];

    if (!is_struct(_en))
        return false;

    if (
        variable_struct_exists(_en, "derrotado")
        &&
        _en.derrotado
    )
    {
        return false;
    }

    if (
        variable_struct_exists(_en, "vida_actual")
        &&
        _en.vida_actual <= 0
    )
    {
        return false;
    }

    return true;
};


// =========================================================
// TEXTO FINAL DE DAÑO TOTAL
// =========================================================

f_update_total_result_text =
function()
{
    if (!f_refresh_refs())
        return;

    var _ui = ui_ref;

    if (
        chain_target < 0
        ||
        chain_target >= array_length(_ui.enemigos)
    )
    {
        return;
    }

    var _en =
        _ui.enemigos[chain_target];

    var _dead =
        (
            variable_struct_exists(_en, "derrotado")
            &&
            _en.derrotado
        )
        ||
        (
            variable_struct_exists(_en, "vida_actual")
            &&
            _en.vida_actual <= 0
        );


    // Si murió, conservamos el texto de muerte creado por la UI.
    if (_dead)
        return;


    if (chain_total_damage > 0)
    {
        _ui.attack_result_text =
            scr_locf(
                "* Hiciste {damage} de daño a {enemy}!",
                {
                    damage: string(chain_total_damage),
                    enemy: scr_loc(_en.nombre)
                }
            );
    }
    else
    {
        _ui.attack_result_text =
            scr_loc_src(
                "* Fallaste el ataque."
            );
    }
};


// =========================================================
// APLICAR ENSANCHADO HORIZONTAL DE LA BARRA
// =========================================================

f_apply_line_visual_mods =
function()
{
    if (!f_refresh_refs())
        return;

    var _ui = ui_ref;

    current_bar_xscale =
        max(
            1.0,
            weapon_mods.barra_ancho_mult
        );


    // Base normal del sistema.
    _ui.attack_perfect_radius =
        4.0;


    if (current_bar_xscale <= 1.0001)
        return;


    // El sprite spr_barra_bbs mide 14 px de ancho.
    // Calculamos cuánto crece SU MITAD al estirarlo.
    //
    // Ese mismo crecimiento se suma a la tolerancia real:
    // si visualmente la barra ancha alcanza el centro,
    // también cuenta mecánicamente.
    var _normal_half_w =
        sprite_get_width(spr_barra_bbs)
        *
        _ui.attack_bar_scale_base
        *
        0.5;


    var _extra_half_w =
        _normal_half_w
        *
        (current_bar_xscale - 1);


    _ui.attack_perfect_radius =
        4.0
        +
        _extra_half_w;


    // La barra ensanchada no debe salirse del target al
    // comenzar en ninguno de los extremos.
    var _new_min =
        _ui.attack_bar_min_x
        +
        _extra_half_w;


    var _new_max =
        _ui.attack_bar_max_x
        -
        _extra_half_w;


    if (_new_max > _new_min + 2)
    {
        _ui.attack_bar_min_x =
            _new_min;

        _ui.attack_bar_max_x =
            _new_max;

        _ui.attack_bar_center_x =
            (
                _ui.attack_bar_min_x
                +
                _ui.attack_bar_max_x
            )
            *
            0.5;


        _ui.attack_bar_x =
            (_ui.attack_bar_direction > 0)
            ?
            _ui.attack_bar_min_x
            :
            _ui.attack_bar_max_x;
    }
};


// =========================================================
// PREPARAR GOLPE
// =========================================================
// Se llama también desde End Step para capturar un timing que
// obj_batalla_ui haya iniciado durante su propio Step.
// =========================================================

f_prepare_attack =
function()
{
    if (!f_refresh_refs())
        return false;

    var _ui = ui_ref;
    var _ctrl = controller_ref;


    if (
        !_ui.attack_timing_active
        ||
        hit_prepared
        ||
        circle_active
    )
    {
        return false;
    }


    // -----------------------------------------------------
    // NUEVA ACCIÓN COMPLETA
    // -----------------------------------------------------

    if (!chain_active)
    {
        weapon_mods =
            scr_battle_get_weapon_mods();

        chain_active =
            true;

        chain_total =
            max(
                1,
                weapon_mods.golpes
            );

        chain_index =
            1;

        chain_target =
            _ui.attack_target_idx;

        chain_total_damage =
            0;

        chain_heal =
            max(
                0,
                weapon_mods.cura
            );

        chain_waiting_feedback =
            false;

        feedback_seen =
            false;
    }


    // -----------------------------------------------------
    // DAÑO: DEBUFF DEL JUGADOR + GUARDIA ENEMIGA
    // -----------------------------------------------------

    var _damage_mult =
        scr_battle_player_attack_multiplier(
            _ctrl
        );


    if (
        chain_target >= 0
        &&
        chain_target < array_length(_ui.enemigos)
    )
    {
        var _en =
            _ui.enemigos[chain_target];


        if (
            is_struct(_en)
            &&
            variable_struct_exists(
                _en,
                "guardia_activa"
            )
            &&
            _en.guardia_activa
        )
        {
            _damage_mult *=
                clamp(
                    variable_struct_exists(
                        _en,
                        "guardia_multiplicador"
                    )
                    ?
                    _en.guardia_multiplicador
                    :
                    0.50,
                    0.05,
                    1
                );
        }
    }


    _ui.attack_base_damage =
        max(
            1,
            round(
                _ui.attack_base_damage
                *
                _damage_mult
            )
        );


    current_mode =
        weapon_mods.modo;


    // Toy enemigo:
    // incluso un timing perfecto puede convertirse en MISS.
    current_force_miss =
        random(1.0)
        <
        clamp(
            _ctrl.player_precision_reducida,
            0,
            0.95
        );


    // -----------------------------------------------------
    // LINEAL
    // -----------------------------------------------------

    if (current_mode == "lineal")
    {
        f_apply_line_visual_mods();
    }


    // -----------------------------------------------------
    // CIRCULAR CARGABLE
    // -----------------------------------------------------

    else if (current_mode == "circular_carga")
    {
        current_bar_xscale =
            1.0;

        _ui.attack_perfect_radius =
            4.0;


        circle_active =
            true;

        circle_started =
            false;

        circle_timer =
            0;


        circle_limit =
            max(
                8,
                weapon_mods.carga_tiempo_frames
            );


        circle_radius_start =
            weapon_mods.carga_radio_inicial;

        circle_radius =
            circle_radius_start;


        circle_radius_target =
            weapon_mods.carga_radio_objetivo;

        circle_radius_max =
            weapon_mods.carga_radio_max;

        circle_speed =
            weapon_mods.carga_velocidad_radio;

        circle_perfect_tolerance =
            weapon_mods.carga_tolerancia_perfecta;


        // La UI normal no debe dibujar ni mover su barra.
        _ui.attack_timing_active =
            false;

        _ui.attack_timing_stopped =
            false;

        _ui.attack_stop_timer =
            0;
    }


    hit_prepared =
        true;

    feedback_seen =
        false;


    return true;
};


// =========================================================
// EMPEZAR SIGUIENTE GOLPE DE LA MISMA ACCIÓN
// =========================================================

f_begin_next_hit =
function()
{
    if (!f_refresh_refs())
        return false;

    var _ui =
        ui_ref;


    if (!f_target_alive())
        return false;


    if (chain_index >= chain_total)
        return false;


    chain_index++;


    hit_prepared =
        false;

    feedback_seen =
        false;

    chain_waiting_feedback =
        false;


    circle_active =
        false;

    circle_started =
        false;

    circle_timer =
        0;


    _ui.attack_feedback_active =
        false;

    _ui.attack_feedback_timer =
        0;

    _ui.attack_feedback_damage =
        0;

    _ui.attack_feedback_miss =
        false;


    _ui.en_resultado_ataque =
        false;

    _ui.text_to_draw =
        "";

    _ui.text_length =
        0;

    _ui.draw_char =
        0;

    _ui.setup =
        false;


    // IMPORTANTE:
    //
    // Volvemos a lanzar SOLO LA BARRA/CARGA.
    // El target lógico sigue siendo EXACTAMENTE el mismo.
    //
    // Como esto ocurre antes del siguiente Draw GUI, el
    // target nunca desaparece entre un golpe y otro.
    _ui.f_iniciar_timing_ataque(
        chain_target
    );


    // Aplicar inmediatamente el modo del arma.
    f_prepare_attack();


    keyboard_clear(
        ord("Z")
    );

    keyboard_clear(
        vk_enter
    );


    return true;
};


// =========================================================
// FINALIZAR VISUALMENTE TODA LA CADENA
// =========================================================

f_start_final_feedback =
function()
{
    if (!f_refresh_refs())
        return;

    var _ui =
        ui_ref;


    f_update_total_result_text();


    _ui.attack_feedback_damage =
        max(
            0,
            chain_total_damage
        );


    _ui.attack_feedback_miss =
        chain_total_damage <= 0;


    _ui.attack_feedback_active =
        true;

    _ui.attack_feedback_timer =
        0;


    chain_waiting_feedback =
        true;

    feedback_seen =
        true;


    circle_active =
        false;

    circle_started =
        false;


    hit_prepared =
        false;


    keyboard_clear(
        ord("Z")
    );

    keyboard_clear(
        vk_enter
    );
};


// =========================================================
// RESOLVER UN GOLPE QUE AÚN NO RESOLVIÓ OBJ_BATALLA_UI
// =========================================================

f_resolve_current_hit =
function(_miss)
{
    if (!f_refresh_refs())
        return;

    var _ui =
        ui_ref;


    var _real_miss =
        _miss
        ||
        current_force_miss;


    _ui.attack_timing_active =
        false;

    _ui.attack_timing_stopped =
        false;

    _ui.attack_stop_timer =
        0;


    circle_active =
        false;

    circle_started =
        false;


    _ui.f_resolver_timing_ataque(
        _real_miss
    );


    chain_total_damage +=
        max(
            0,
            _ui.attack_damage_done
        );


    // Si aún queda enemigo + golpes:
    // la siguiente barra/carga aparece INMEDIATAMENTE.
    if (
        f_target_alive()
        &&
        chain_index < chain_total
    )
    {
        f_begin_next_hit();
        return;
    }


    f_start_final_feedback();
};


// =========================================================
// RESOLVER CÍRCULO
// =========================================================

f_resolve_circle =
function()
{
    if (!f_refresh_refs())
    {
        circle_active =
            false;

        return;
    }


    var _ui =
        ui_ref;


    var _miss =
        !circle_started
        ||
        current_force_miss;


    if (!_miss)
    {
        var _error =
            abs(
                circle_radius
                -
                circle_radius_target
            );


        var _quality =
            1;


        if (_error > circle_perfect_tolerance)
        {
            var _max_error =
                max(
                    circle_radius_target
                    -
                    circle_radius_start,

                    circle_radius_max
                    -
                    circle_radius_target,

                    circle_perfect_tolerance
                    +
                    1
                );


            _quality =
                1
                -
                (
                    (_error - circle_perfect_tolerance)
                    /
                    max(
                        1,
                        _max_error
                        -
                        circle_perfect_tolerance
                    )
                );
        }


        _quality =
            clamp(
                _quality,
                0,
                1
            );


        // Convertir la precisión circular a una posición
        // equivalente dentro del timing lineal para reutilizar
        // exactamente la misma fórmula de daño.
        var _half_range =
            max(
                1,
                _ui.attack_bar_max_x
                -
                _ui.attack_bar_center_x
            );


        var _perfect =
            clamp(
                _ui.attack_perfect_radius,
                0,
                _half_range
            );


        var _fake_distance =
            (_quality >= 1)
            ?
            0
            :
            _perfect
            +
            (
                (1 - _quality)
                *
                max(
                    0,
                    _half_range
                    -
                    _perfect
                )
            );


        _ui.attack_bar_x =
            _ui.attack_bar_center_x
            +
            _fake_distance;
    }


    f_resolve_current_hit(
        _miss
    );
};
