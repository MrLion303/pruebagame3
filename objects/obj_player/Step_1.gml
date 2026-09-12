/// =========================================================
/// OBJ_PLAYER
/// BEGIN STEP COMPLETO
/// =========================================================
///
/// - Habilidades de mundo.
/// - Plataformero.
/// - snd_tensionhorn al entrar/salir.
/// - Dash plataformero estilo Hollow Knight.
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
    ability_prev_x =
        x;

    ability_prev_y =
        y;


    dash_used_this_frame =
        false;


    // =====================================================
    // SIGILO FX
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


    scr_sigilo_actualizar_rangos(
        sigilo_activo
    );
}


// =========================================================
// PLATAFORMERO
// =========================================================

scr_platformer_init();


// Estado anterior para detectar entrada/salida real.
if (
    !variable_instance_exists(
        id,
        "platformer_tension_prev_active"
    )
)
{
    platformer_tension_prev_active =
        global.platformer_active;
}


// Aplicar entrada/salida pendiente DESPUÉS del room_goto.
scr_platformer_apply_pending_mode();


// =========================================================
// SND_TENSIONHORN
// =========================================================

if (
    platformer_tension_prev_active
    !=
    global.platformer_active
)
{
    var _tensionhorn =
        asset_get_index(
            "snd_tensionhorn"
        );


    if (
        _tensionhorn != -1
        &&
        audio_exists(
            _tensionhorn
        )
    )
    {
        if (
            audio_is_playing(
                _tensionhorn
            )
        )
        {
            audio_stop_sound(
                _tensionhorn
            );
        }


        audio_play_sound(
            _tensionhorn,
            10,
            false
        );
    }


    platformer_tension_prev_active =
        global.platformer_active;
}


// =========================================================
// MODO PLATAFORMERO
// =========================================================

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


    // =====================================================
    // DASH PLATAFORMERO
    // =====================================================
    //
    // Si devuelve true, el Dash controla toda la física de
    // este frame y NO ejecutamos gravedad/movimiento normal.
    // =====================================================

    var _platform_dash_consumed =
        scr_platformer_dash_update(
            id
        );


    if (!_platform_dash_consumed)
    {
        scr_platformer_player_update();
    }
}
else
{
    // Seguridad:
    // restaurar alpha/visual si abandonamos la room durante Dash.
    scr_platformer_dash_cancel(
        id
    );


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
