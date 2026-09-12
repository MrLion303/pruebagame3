/// =========================================================
/// OBJ_BATALLA_ATTACK_MODS
/// CREATE COMPLETO
/// =========================================================
///
/// PARENT OBJECT:
///     ninguno
///
/// Este objeto controla únicamente la LÓGICA especial.
/// El dibujo especial se hace al final de:
///
///     obj_batalla_ui -> Draw GUI End
///
/// para garantizar que nunca quede debajo de la UI base.
/// =========================================================

persistent =
    false;


controller_ref =
    noone;

ui_ref =
    noone;


// =========================================================
// ACCIÓN ACTUAL
// =========================================================

action_active =
    false;

action_target =
    -1;

action_total_damage =
    0;

action_heal =
    0;

action_feedback_started =
    false;

action_feedback_seen =
    false;


weapon_mods =
    scr_battle_get_weapon_mods();


current_mode =
    "lineal";


// Escala X visual/mecánica de la barra normal.
current_bar_xscale =
    1.0;


// Precisión reducida del jugador para ataque lineal estándar.
single_force_miss =
    false;


// =========================================================
// MODO PERSONALIZADO
// =========================================================
//
// ""       = timing normal de obj_batalla_ui
// "multi"  = 2/3 barras simultáneas
// "circle" = diana cargada
// =========================================================

custom_mode =
    "";

custom_wait_release =
    false;

custom_accept_pressed =
    false;

custom_accept_held =
    false;


// Guardamos la velocidad real de la UI mientras la bloqueamos.
saved_ui_bar_speed =
    7;


// =========================================================
// MULTI-BARRA
// =========================================================

multi_count =
    0;

multi_next =
    0;

multi_direction =
    1;

multi_gap =
    38;

multi_min_x =
    0;

multi_max_x =
    0;

multi_center_x =
    0;

multi_positions =
    [];

multi_done =
    [];

multi_speed =
    7;


// =========================================================
// CÍRCULO CARGADO
// =========================================================

circle_active =
    false;

circle_total =
    1;

circle_index =
    0;

circle_started =
    false;

circle_timer =
    0;

circle_limit =
    24;

circle_radius =
    4;

circle_radius_start =
    4;

circle_radius_target =
    64;

circle_radius_max =
    90;

circle_speed =
    5.5;

circle_perfect_tolerance =
    5;


// =========================================================
// ENTRADA VISUAL DEL ATAQUE CARGADO
// =========================================================
//
// Primero el textbox horizontal se encoge suavemente hasta
// 128x128. SOLO al terminar esa animación aparece la diana y
// empieza la ventana real de tiempo del ataque.
// =========================================================

circle_intro_active =
    false;

circle_intro_timer =
    0;

circle_intro_frames =
    10;

circle_intro_progress =
    0;

circle_ready =
    false;

// Obliga a que el jugador pulse Z/Enter DE NUEVO después de
// que la diana ya apareció. Mantener el botón desde el diálogo
// anterior no inicia automáticamente la carga.
circle_input_armed =
    false;


// =========================================================
// REFERENCIAS
// =========================================================

f_refresh_refs =
function()
{
    controller_ref =
        instance_exists(
            obj_batalla_controller
        )
        ?
        instance_find(
            obj_batalla_controller,
            0
        )
        :
        noone;


    ui_ref =
        instance_exists(
            obj_batalla_ui
        )
        ?
        instance_find(
            obj_batalla_ui,
            0
        )
        :
        noone;


    return
        controller_ref != noone
        &&
        ui_ref != noone
        &&
        instance_exists(
            controller_ref
        )
        &&
        instance_exists(
            ui_ref
        );
};


// =========================================================
// TARGET VIVO
// =========================================================

f_target_alive =
function()
{
    if (!f_refresh_refs())
        return false;


    var _ui =
        ui_ref;


    if (
        action_target < 0
        ||
        action_target >= array_length(
            _ui.enemigos
        )
    )
    {
        return false;
    }


    var _en =
        _ui.enemigos[
            action_target
        ];


    if (!is_struct(_en))
        return false;


    if (
        variable_struct_exists(
            _en,
            "derrotado"
        )
        &&
        _en.derrotado
    )
    {
        return false;
    }


    if (
        variable_struct_exists(
            _en,
            "vida_actual"
        )
        &&
        _en.vida_actual <= 0
    )
    {
        return false;
    }


    return true;
};


// =========================================================
// ROLL DE FALLO POR TOY ENEMIGO
// =========================================================

f_precision_force_miss =
function()
{
    if (!f_refresh_refs())
        return false;


    return
        random(1.0)
        <
        clamp(
            controller_ref.player_precision_reducida,
            0,
            0.95
        );
};


// =========================================================
// MULTIPLICADOR DE DAÑO DEL JUGADOR / GUARDIA
// =========================================================

f_apply_damage_multiplier =
function()
{
    if (!f_refresh_refs())
        return;


    var _ui =
        ui_ref;


    var _mult =
        scr_battle_player_attack_multiplier(
            controller_ref
        );


    if (
        action_target >= 0
        &&
        action_target < array_length(
            _ui.enemigos
        )
    )
    {
        var _en =
            _ui.enemigos[
                action_target
            ];


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
            _mult *=
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
                _mult
            )
        );
};


// =========================================================
// RESULTADO FINAL TOTAL
// =========================================================

f_update_total_result_text =
function()
{
    if (!f_refresh_refs())
        return;


    var _ui =
        ui_ref;


    if (
        action_target < 0
        ||
        action_target >= array_length(
            _ui.enemigos
        )
    )
    {
        return;
    }


    var _en =
        _ui.enemigos[
            action_target
        ];


    var _dead =
        (
            variable_struct_exists(
                _en,
                "derrotado"
            )
            &&
            _en.derrotado
        )
        ||
        (
            variable_struct_exists(
                _en,
                "vida_actual"
            )
            &&
            _en.vida_actual <= 0
        );


    // Si murió, conservar el texto de muerte que ya generó
    // f_resolver_timing_ataque().
    if (_dead)
        return;


    if (action_total_damage > 0)
    {
        _ui.attack_result_text =
            scr_locf(
                "* Hiciste {damage} de daño a {enemy}!",
                {
                    damage:
                        string(
                            action_total_damage
                        ),

                    enemy:
                        scr_loc(
                            _en.nombre
                        )
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
// RESTAURAR UI DESPUÉS DE MODO CUSTOM
// =========================================================

f_restore_ui_timing =
function()
{
    if (!f_refresh_refs())
        return;


    var _ui =
        ui_ref;


    _ui.attack_bar_speed =
        saved_ui_bar_speed;


    _ui.attack_timing_active =
        false;

    _ui.attack_timing_stopped =
        false;

    _ui.attack_stop_timer =
        0;
};


// =========================================================
// INICIAR POPUP FINAL
// =========================================================

f_start_final_feedback =
function()
{
    if (!f_refresh_refs())
        return;


    var _ui =
        ui_ref;


    f_restore_ui_timing();


    f_update_total_result_text();


    _ui.attack_feedback_damage =
        max(
            0,
            action_total_damage
        );


    _ui.attack_feedback_miss =
        action_total_damage <= 0;


    _ui.attack_feedback_active =
        true;

    _ui.attack_feedback_timer =
        0;


    action_feedback_started =
        true;

    action_feedback_seen =
        true;


    custom_mode =
        "";

    circle_active =
        false;

    circle_started =
        false;


    keyboard_clear(
        ord("Z")
    );

    keyboard_clear(
        vk_enter
    );
};


// =========================================================
// RESOLVER UN HIT CUSTOM
// =========================================================

f_resolve_custom_hit =
function(
    _bar_x,
    _miss
)
{
    if (!f_refresh_refs())
        return;


    var _ui =
        ui_ref;


    _ui.attack_target_idx =
        action_target;


    _ui.attack_bar_x =
        _bar_x;


    var _real_miss =
        _miss
        ||
        f_precision_force_miss();


    _ui.f_resolver_timing_ataque(
        _real_miss
    );


    action_total_damage +=
        max(
            0,
            _ui.attack_damage_done
        );
};


// =========================================================
// INICIAR MULTI-BARRA
// =========================================================

f_start_multi =
function()
{
    if (!f_refresh_refs())
        return;


    var _ui =
        ui_ref;


    custom_mode =
        "multi";


    multi_count =
        max(
            2,
            round(
                weapon_mods.golpes
            )
        );


    multi_next =
        0;


    multi_direction =
        _ui.attack_bar_direction;


    multi_min_x =
        _ui.attack_bar_min_x;

    multi_max_x =
        _ui.attack_bar_max_x;

    multi_center_x =
        _ui.attack_bar_center_x;


    saved_ui_bar_speed =
        max(
            0.1,
            _ui.attack_bar_speed
        );


    multi_speed =
        saved_ui_bar_speed;


    // Separación estilo Undertale/Deltarune:
    // las barras salen juntas del mismo lado, pero con bastante
    // aire entre ellas para que se lean como impactos distintos.
    var _side_space =
        max(
            20,
            abs(
                multi_center_x
                -
                multi_min_x
            )
        );


    multi_gap =
        min(
            38,
            max(
                26,
                _side_space
                /
                (multi_count + 0.5)
            )
        );


    multi_positions =
        array_create(
            multi_count,
            0
        );


    multi_done =
        array_create(
            multi_count,
            false
        );


    // =====================================================
    // TODAS APARECEN A LA VEZ DESDE EL MISMO LADO
    // =====================================================
    //
    // Índice 0 = barra líder.
    // Las demás vienen detrás separadas por multi_gap.
    // =====================================================

    for (
        var _i = 0;
        _i < multi_count;
        _i++
    )
    {
        var _behind =
            multi_count
            -
            1
            -
            _i;


        if (multi_direction > 0)
        {
            multi_positions[_i] =
                multi_min_x
                +
                (_behind * multi_gap);
        }
        else
        {
            multi_positions[_i] =
                multi_max_x
                -
                (_behind * multi_gap);
        }
    }


    custom_wait_release =
        true;


    // Mantener la UI bloqueada dentro del estado de timing,
    // pero ocultar su barra estándar fuera de pantalla.
    _ui.attack_bar_speed =
        0;

    _ui.attack_bar_x =
        -9999;

    _ui.attack_timing_active =
        true;

    _ui.attack_timing_stopped =
        false;
};


// =========================================================
// INICIAR CÍRCULO CARGADO
// =========================================================

f_start_circle =
function()
{
    if (!f_refresh_refs())
        return;


    var _ui =
        ui_ref;


    custom_mode =
        "circle";

    circle_active =
        true;


    circle_total =
        max(
            1,
            round(
                weapon_mods.golpes
            )
        );


    circle_index =
        0;


    // =====================================================
    // INTRO: CAJA HORIZONTAL -> 128x128
    // =====================================================

    circle_intro_active =
        true;

    circle_intro_timer =
        0;

    circle_intro_progress =
        0;

    circle_ready =
        false;


    // =====================================================
    // CARGA
    // =====================================================

    circle_started =
        false;

    circle_timer =
        0;

    circle_input_armed =
        false;


    circle_limit =
        max(
            8,
            round(
                weapon_mods.carga_tiempo_frames
            )
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


    saved_ui_bar_speed =
        max(
            0.1,
            _ui.attack_bar_speed
        );


    // El modo circle ya controla por sí mismo el input.
    // NO usamos custom_wait_release porque esa era la causa
    // de que hubiera que mantener Z desde el diálogo anterior.
    custom_wait_release =
        false;


    // Mantener la UI base bloqueada dentro del timing, pero
    // esconder su barra estándar.
    _ui.attack_bar_speed =
        0;

    _ui.attack_bar_x =
        -9999;

    _ui.attack_timing_active =
        true;

    _ui.attack_timing_stopped =
        false;
};


// =========================================================
// PREPARAR NUEVA ACCIÓN
// =========================================================

f_prepare_attack =
function()
{
    if (!f_refresh_refs())
        return false;


    var _ui =
        ui_ref;


    if (
        action_active
        ||
        !_ui.attack_timing_active
    )
    {
        return false;
    }


    weapon_mods =
        scr_battle_get_weapon_mods();


    action_active =
        true;


    action_target =
        _ui.attack_target_idx;


    action_total_damage =
        0;


    action_heal =
        max(
            0,
            weapon_mods.cura
        );


    action_feedback_started =
        false;

    action_feedback_seen =
        false;


    current_mode =
        weapon_mods.modo;


    current_bar_xscale =
        max(
            1.0,
            weapon_mods.barra_ancho_mult
        );


    f_apply_damage_multiplier();


    // =====================================================
    // CIRCULAR
    // =====================================================

    if (current_mode == "circular_carga")
    {
        _ui.attack_perfect_radius =
            4.0;


        current_bar_xscale =
            1.0;


        f_start_circle();

        return true;
    }


    // =====================================================
    // MULTI-BARRA
    // =====================================================

    if (weapon_mods.golpes > 1)
    {
        // Si alguna futura arma combina multi-hit + ancho,
        // todas sus barras usarán esta escala.
        if (current_bar_xscale > 1.0001)
        {
            var _normal_half =
                sprite_get_width(
                    spr_barra_bbs
                )
                *
                _ui.attack_bar_scale_base
                *
                0.5;


            _ui.attack_perfect_radius =
                4
                +
                (
                    _normal_half
                    *
                    (current_bar_xscale - 1)
                );
        }
        else
        {
            _ui.attack_perfect_radius =
                4;
        }


        f_start_multi();

        return true;
    }


    // =====================================================
    // LINEAL NORMAL / ESPADA CERTERA
    // =====================================================

    single_force_miss =
        f_precision_force_miss();


    _ui.attack_perfect_radius =
        4.0;


    if (current_bar_xscale > 1.0001)
    {
        // La barra se hace físicamente más ancha.
        // La mitad del ancho extra también cuenta como
        // tolerancia real para tocar el centro.
        var _normal_half_w =
            sprite_get_width(
                spr_barra_bbs
            )
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
    }


    return true;
};


// =========================================================
// RESOLVER BARRA MULTI
// =========================================================

f_resolve_multi_bar =
function(
    _idx,
    _miss
)
{
    if (
        _idx < 0
        ||
        _idx >= multi_count
        ||
        multi_done[_idx]
    )
    {
        return;
    }


    var _x =
        multi_positions[_idx];


    if (_miss)
    {
        _x =
            clamp(
                _x,
                multi_min_x,
                multi_max_x
            );


        multi_positions[_idx] =
            _x;
    }


    f_resolve_custom_hit(
        _x,
        _miss
    );


    multi_done[_idx] =
        true;


    multi_next =
        _idx
        +
        1;


    // Si murió antes de terminar la cadena:
    // finalizar inmediatamente.
    if (!f_target_alive())
    {
        f_start_final_feedback();
        return;
    }


    if (multi_next >= multi_count)
    {
        f_start_final_feedback();
    }
};


// =========================================================
// RESOLVER CARGA
// =========================================================

f_resolve_circle_hit =
function()
{
    if (!f_refresh_refs())
        return;


    var _ui =
        ui_ref;


    var _miss =
        !circle_started;


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


    f_resolve_custom_hit(
        _ui.attack_bar_x,
        _miss
    );


    circle_index++;


    if (!f_target_alive())
    {
        f_start_final_feedback();
        return;
    }


    if (circle_index >= circle_total)
    {
        f_start_final_feedback();
        return;
    }


    // Otra carga sobre LA MISMA DIANA.
    // No repetimos la animación de encogimiento. La diana se
    // queda en pantalla y empieza una NUEVA ventana de tiempo.
    circle_intro_active =
        false;

    circle_intro_progress =
        1;

    circle_ready =
        true;

    circle_started =
        false;

    circle_timer =
        0;

    circle_radius =
        circle_radius_start;

    // Exigir soltar y volver a pulsar para el siguiente aro.
    circle_input_armed =
        false;


    keyboard_clear(
        ord("Z")
    );

    keyboard_clear(
        vk_enter
    );
};


// =========================================================
// TERMINAR ACCIÓN DESPUÉS DEL POPUP
// =========================================================

f_finish_action =
function()
{
    if (!f_refresh_refs())
        return;


    var _ui =
        ui_ref;


    var _curado =
        0;


    if (
        action_heal > 0
        &&
        action_total_damage > 0
        &&
        instance_exists(
            obj_player
        )
    )
    {
        var _hp_before =
            obj_player.hp;


        obj_player.hp =
            min(
                obj_player.hp_max,
                obj_player.hp
                +
                action_heal
            );


        _curado =
            obj_player.hp
            -
            _hp_before;


        global.player_hp_current =
            obj_player.hp;
    }


    if (_curado > 0)
    {
        _ui.f_procesar_dialogo(
            _ui.attack_result_text
            +
            "\n* Recuperaste "
            +
            string(_curado)
            +
            " HP."
        );
    }


    _ui.attack_perfect_radius =
        4.0;


    _ui.attack_bar_speed =
        max(
            0.1,
            saved_ui_bar_speed
        );


    action_active =
        false;

    action_target =
        -1;

    action_total_damage =
        0;

    action_heal =
        0;

    action_feedback_started =
        false;

    action_feedback_seen =
        false;


    custom_mode =
        "";

    custom_wait_release =
        false;


    current_mode =
        "lineal";

    current_bar_xscale =
        1.0;

    single_force_miss =
        false;


    multi_count =
        0;

    multi_next =
        0;

    multi_positions =
        [];

    multi_done =
        [];


    circle_active =
        false;

    circle_started =
        false;

    circle_index =
        0;

    circle_timer =
        0;

    circle_intro_active =
        false;

    circle_intro_timer =
        0;

    circle_intro_progress =
        0;

    circle_ready =
        false;

    circle_input_armed =
        false;
};
