/// =========================================================
/// OBJ_PLAYER
/// BEGIN STEP COMPLETO
/// =========================================================
///
/// - Habilidades de mundo.
/// - Plataformero.
/// - snd_tensionhorn al entrar/salir.
/// - Dash plataformero estilo Hollow Knight.
/// - Ataque horizontal en plataforma bloquea X solamente
///   mientras dura su animación.
/// - El último frame del ataque horizontal dura más.
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


    // Mientras obj_deslizamiento_abajo controla a Maya,
    // S / Sigilo queda completamente bloqueado.
    var _downslide_blocks_sigilo =
        (
            variable_instance_exists(
                id,
                "downslide_active"
            )
            &&
            downslide_active
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
            !_downslide_blocks_sigilo
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


// =========================================================
// RUNTIME DEL ATAQUE HORIZONTAL BLOQUEADO
// =========================================================
//
// Esta duración es independiente del timer de daño.
// El golpe sigue ocurriendo exactamente como antes.
// Solo controla:
//
//     - pose horizontal;
//     - bloqueo del movimiento horizontal;
//     - duración extra del último frame.
// =========================================================

if (
    !variable_instance_exists(
        id,
        "platform_horizontal_attack_visual_timer"
    )
)
{
    platform_horizontal_attack_visual_timer =
        0;


    platform_horizontal_attack_visual_total =
        0;
}


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
// SONIDO DE ENTRADA / SALIDA DEL PLATAFORMERO
// =========================================================

if (
    platformer_tension_prev_active
    !=
    global.platformer_active
)
{
    var _sound_name =
        (
            global.platformer_active
            ?
            "snd_entrar_platformer"
            :
            "snd_salir_platformer"
        );


    var _platform_transition_sound =
        asset_get_index(
            _sound_name
        );


    if (
        _platform_transition_sound == -1
        &&
        !global.platformer_active
    )
    {
        _platform_transition_sound =
            asset_get_index(
                "snd_entrar_platformer"
            );
    }


    if (
        _platform_transition_sound != -1
        &&
        audio_exists(
            _platform_transition_sound
        )
    )
    {
        audio_play_sound(
            _platform_transition_sound,
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


    var _platform_void_consumed =
        scr_platformer_void_recovery_update(
            id
        );


    if (!_platform_void_consumed)
    {
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


        var _platform_dash_consumed =
            scr_platformer_dash_update(
                id
            );


        if (!_platform_dash_consumed)
        {
            // =================================================
            // ¿EMPIEZA UN ATAQUE HORIZONTAL EN SUELO?
            // =================================================
            //
            // NO se aplica si:
            //     - Maya está saltando/cayendo;
            //     - ataque es arriba;
            //     - ataque es abajo;
            //     - está haciendo sentón.
            // =================================================

            var _horizontal_attack_started =
                false;


            // Si dejó el suelo por cualquier causa, el bloqueo
            // horizontal especial se cancela inmediatamente.
            if (
                platform_horizontal_attack_visual_timer > 0
                &&
                variable_instance_exists(
                    id,
                    "platform_grounded"
                )
                &&
                !platform_grounded
            )
            {
                platform_horizontal_attack_visual_timer =
                    0;


                platform_horizontal_attack_visual_total =
                    0;
            }


            var _attack_pressed_now =
                scr_platformer_attack_pressed();


            var _attack_up_now =
                keyboard_check(
                    vk_up
                );


            var _attack_down_now =
                keyboard_check(
                    vk_down
                );


            var _attack_vertical_now =
                (
                    _attack_up_now
                    !=
                    _attack_down_now
                );


            var _grounded_now =
                (
                    variable_instance_exists(
                        id,
                        "platform_grounded"
                    )
                    &&
                    platform_grounded
                );


            var _attack_ready_now =
                (
                    !variable_instance_exists(
                        id,
                        "platform_attack_cooldown"
                    )
                    ||
                    platform_attack_cooldown <= 0
                );


            var _stomp_now =
                (
                    variable_instance_exists(
                        id,
                        "platform_stomp_active"
                    )
                    &&
                    platform_stomp_active
                );


            if (
                _attack_pressed_now
                &&
                !_attack_vertical_now
                &&
                _grounded_now
                &&
                _attack_ready_now
                &&
                !_stomp_now
            )
            {
                // Si mantiene izquierda/derecha al atacar,
                // esa dirección decide hacia dónde mira antes
                // de congelar el movimiento.
                var _attack_left_now =
                    keyboard_check(
                        vk_left
                    );


                var _attack_right_now =
                    keyboard_check(
                        vk_right
                    );


                if (
                    _attack_left_now
                    &&
                    !_attack_right_now
                )
                {
                    platform_facing =
                        -1;
                }
                else if (
                    _attack_right_now
                    &&
                    !_attack_left_now
                )
                {
                    platform_facing =
                        1;
                }


                var _attack_sprite_name =
                    (
                        platform_facing < 0
                        ?
                        "spr_maya_ataque_platform_izquierda"
                        :
                        "spr_maya_ataque_platform_derecha"
                    );


                var _attack_sprite =
                    asset_get_index(
                        _attack_sprite_name
                    );


                var _attack_frames =
                    1;


                if (
                    _attack_sprite != -1
                    &&
                    sprite_exists(
                        _attack_sprite
                    )
                )
                {
                    _attack_frames =
                        max(
                            1,
                            sprite_get_number(
                                _attack_sprite
                            )
                        );
                }


                // Cada frame previo dura 1 frame y el último
                // se mantiene 4 frames en total.
                platform_horizontal_attack_visual_total =
                    max(
                        5,
                        _attack_frames + 3
                    );


                platform_horizontal_attack_visual_timer =
                    platform_horizontal_attack_visual_total;


                _horizontal_attack_started =
                    true;
            }


            // =================================================
            // BLOQUEAR MOVIMIENTO HORIZONTAL SOLO DURANTE
            // ESTE ATAQUE EN SUELO
            // =================================================

            var _horizontal_attack_locked =
                (
                    platform_horizontal_attack_visual_timer > 0
                    &&
                    _grounded_now
                );


            // =================================================
            // NO LIMPIAR LAS FLECHAS DEL TECLADO
            // =================================================
            //
            // keyboard_clear(vk_left / vk_right) obligaba al
            // jugador a soltar físicamente la tecla y volverla
            // a pulsar después del ataque.
            //
            // Ahora dejamos que scr_platformer_player_update()
            // siga leyendo normalmente la flecha mantenida y
            // congelamos ÚNICAMENTE el desplazamiento X final
            // mientras dura el ataque horizontal.
            //
            // Resultado:
            //     mantener DERECHA -> atacar -> Maya se para
            //     -> termina ataque -> sigue andando DERECHA
            //
            // sin soltar la tecla.
            // =================================================

            var _horizontal_lock_x =
                x;


            if (_horizontal_attack_locked)
            {
                platform_hsp =
                    0;


                platform_x_rem =
                    0;
            }


            scr_platformer_attack_los_prepare(
                id
            );


            scr_platformer_player_update();


            scr_platformer_attack_los_restore();


            // Blindaje posterior:
            // permitimos que el update lea la flecha, cambie
            // facing y procese el resto de física, pero Maya no
            // puede desplazarse horizontalmente hasta acabar la
            // pose de ataque.
            if (
                platform_horizontal_attack_visual_timer > 0
                &&
                platform_grounded
            )
            {
                x =
                    _horizontal_lock_x;


                platform_hsp =
                    0;


                platform_x_rem =
                    0;
            }


            // El frame en el que empieza conserva el timer
            // completo para que el primer frame sí se vea.
            if (
                platform_horizontal_attack_visual_timer > 0
                &&
                !_horizontal_attack_started
            )
            {
                platform_horizontal_attack_visual_timer--;
            }
        }
    }
}
else
{
    platform_horizontal_attack_visual_timer =
        0;


    platform_horizontal_attack_visual_total =
        0;


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
