/// =========================================================
/// OBJ_PLAYER
/// BEGIN STEP COMPLETO
/// =========================================================
///
/// Modo plataformero actual + habilidades de mundo.
///
/// IMPORTANTE:
/// La lógica de habilidades se ejecuta DIRECTAMENTE aquí para
/// no volver a llamar la versión vieja de
/// scr_player_abilities_begin_step(), que todavía contenía una
/// referencia a obj_menu_habilidades_ext.
///
/// obj_menu_habilidades_ext YA NO EXISTE NI SE NECESITA.
/// =========================================================


// =========================================================
// HABILIDADES - INICIALIZAR RUNTIME
// =========================================================

if (
    scr_player_abilities_init(
        id
    )
)
{
    // Guardar posición previa para que End Step pueda aplicar
    // correctamente la reducción de velocidad de Sigilo.
    ability_prev_x =
        x;

    ability_prev_y =
        y;


    // Cada frame empieza sin Dash realizado.
    dash_used_this_frame =
        false;


    // =====================================================
    // SIGILO FX
    // =====================================================
    //
    // El único objeto auxiliar que sí sigue siendo válido es
    // obj_sigilo_fx.
    // =====================================================

    if (
        scr_habilidad_tiene(
            "sigilo"
        )
        &&
        !instance_exists(
            obj_sigilo_fx
        )
    )
    {
        instance_create_depth(
            0,
            0,
            -1500000,
            obj_sigilo_fx
        );
    }


    // =====================================================
    // CONDICIONES DEL MUNDO
    // =====================================================

    var _platformer =
        variable_global_exists(
            "platformer_active"
        )
        &&
        global.platformer_active;


    var _pause_menu_open =
        (
            instance_exists(
                obj_menu_manager
            )
            &&
            obj_menu_manager.state
            !=
            MENU_STATE.CLOSED
        );


    var _world_ok =
        (
            room != bbs
            &&
            room != game_over
            &&
            !_platformer
            &&
            !_pause_menu_open
            &&
            !instance_exists(
                obj_save_menu
            )
            &&
            !scr_cutscene_world_locked()
            &&
            !instance_exists(
                obj_pauser
            )
        );


    // =====================================================
    // SIGILO
    // =====================================================

    sigilo_activo =
        (
            _world_ok
            &&
            scr_habilidad_tiene(
                "sigilo"
            )
            &&
            keyboard_check(
                ord("S")
            )
        );


    // Begin Step ocurre antes del Step normal de los enemigos,
    // por lo que sus rangos ya llegan reducidos/restaurados.
    scr_sigilo_actualizar_rangos(
        sigilo_activo
    );
}


// =========================================================
// PLATAFORMERO - CÓDIGO ACTUAL CONSERVADO
// =========================================================

scr_platformer_init();


// Aplicar entrada/salida pendiente DESPUÉS del room_goto.
scr_platformer_apply_pending_mode();


if (global.platformer_active)
{
    if (
        !variable_instance_exists(
            id,
            "platformer_mode_applied"
        )
        ||
        !platformer_mode_applied
    )
    {
        scr_platformer_player_enter();
    }


    // Pogo = misma física vertical que un salto normal.
    if (
        variable_instance_exists(
            id,
            "platform_jump_speed"
        )
        &&
        variable_instance_exists(
            id,
            "platform_pogo_bounce_speed"
        )
    )
    {
        platform_pogo_bounce_speed =
            platform_jump_speed;
    }


    scr_platformer_player_update();
}
else
{
    if (
        variable_instance_exists(
            id,
            "platformer_mode_applied"
        )
        &&
        platformer_mode_applied
    )
    {
        scr_platformer_player_leave();
    }
}
