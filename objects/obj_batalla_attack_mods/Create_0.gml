/// =========================================================
/// OBJ_BATALLA_ATTACK_MODS
/// CREATE - NUEVO OBJETO
/// =========================================================
/// **PARENT: ninguno**
///
/// El controller lo crea automáticamente dentro de BBS.
/// Añade modificadores sin reemplazar obj_batalla_ui.
/// =========================================================

persistent = false;
depth = -10000010;

controller_ref = noone;
ui_ref = noone;

chain_active = false;
chain_total = 1;
chain_index = 0;
chain_target = -1;
chain_total_damage = 0;
chain_heal = 0;

feedback_seen = false;
hit_prepared = false;

weapon_mods = scr_battle_get_weapon_mods();

current_mode = "lineal";
current_after_center = false;
current_force_miss = false;

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


// ---------------------------------------------------------
// REFERENCIAS
// ---------------------------------------------------------

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


// ---------------------------------------------------------
// PREPARAR GOLPE
// ---------------------------------------------------------
// Se llama también desde End Step para capturar un timing que
// obj_batalla_ui haya comenzado durante su propio Step.
// ---------------------------------------------------------

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


    // Nueva acción completa.
    if (!chain_active)
    {
        weapon_mods = scr_battle_get_weapon_mods();

        chain_active = true;
        chain_total = max(1, weapon_mods.golpes);
        chain_index = 1;
        chain_target = _ui.attack_target_idx;
        chain_total_damage = 0;
        chain_heal = max(0, weapon_mods.cura);
        feedback_seen = false;
    }


    // -----------------------------------------------------
    // DAÑO: DEBUFF DEL JUGADOR + GUARDIA ENEMIGA
    // -----------------------------------------------------

    var _damage_mult =
        scr_battle_player_attack_multiplier(_ctrl);

    if (
        chain_target >= 0
        &&
        chain_target < array_length(_ui.enemigos)
    )
    {
        var _en = _ui.enemigos[chain_target];

        if (
            is_struct(_en)
            &&
            variable_struct_exists(_en, "guardia_activa")
            &&
            _en.guardia_activa
        )
        {
            _damage_mult *=
                clamp(
                    variable_struct_exists(_en, "guardia_multiplicador")
                    ? _en.guardia_multiplicador
                    : 0.50,
                    0.05,
                    1
                );
        }
    }

    _ui.attack_base_damage =
        max(
            1,
            round(_ui.attack_base_damage * _damage_mult)
        );


    // Zona perfecta más ancha/estrecha.
    _ui.attack_perfect_radius =
        4.0
        *
        max(0.25, weapon_mods.ancho_centro_mult);


    current_mode = weapon_mods.modo;
    current_after_center =
        weapon_mods.confirmar_despues_centro;

    // Toy enemigo: incluso un timing perfecto puede fallar.
    current_force_miss =
        random(1.0)
        <
        clamp(
            _ctrl.player_precision_reducida,
            0,
            0.95
        );


    // -----------------------------------------------------
    // CIRCULAR CARGABLE
    // -----------------------------------------------------

    if (current_mode == "circular_carga")
    {
        circle_active = true;
        circle_started = false;
        circle_timer = 0;

        circle_limit =
            weapon_mods.carga_tiempo_frames;

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

        // No dibujar ni procesar el timing lineal.
        _ui.attack_timing_active = false;
        _ui.attack_timing_stopped = false;
    }


    hit_prepared = true;
    feedback_seen = false;

    return true;
};


// ---------------------------------------------------------
// RESOLVER CÍRCULO
// ---------------------------------------------------------

f_resolve_circle =
function()
{
    if (!f_refresh_refs())
    {
        circle_active = false;
        return;
    }

    var _ui = ui_ref;

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

        var _quality = 1;

        if (_error > circle_perfect_tolerance)
        {
            var _max_error =
                max(
                    circle_radius_target - circle_radius_start,
                    circle_radius_max - circle_radius_target,
                    circle_perfect_tolerance + 1
                );

            _quality =
                1
                -
                (
                    (_error - circle_perfect_tolerance)
                    /
                    max(
                        1,
                        _max_error - circle_perfect_tolerance
                    )
                );
        }

        _quality = clamp(_quality, 0, 1);


        // Convertir la calidad circular a una distancia
        // equivalente del target lineal para reutilizar:
        // daño, muerte, sonidos, popup y recompensas.
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
            ? 0
            : _perfect
              +
              (
                  (1 - _quality)
                  *
                  max(0, _half_range - _perfect)
              );

        _ui.attack_bar_x =
            _ui.attack_bar_center_x
            +
            _fake_distance;
    }


    _ui.f_resolver_timing_ataque(_miss);

    _ui.attack_feedback_active = true;
    _ui.attack_feedback_timer = 0;

    circle_active = false;

    keyboard_clear(ord("Z"));
    keyboard_clear(vk_enter);
};
