/// =========================================================
/// SCR_PLATFORMER_PARTY_DASH_EXT
/// NUEVO SCRIPT
/// =========================================================
///
/// Añade:
///
/// - Dash plataformero estilo Hollow Knight.
/// - Sprite propio de Dash para Maya.
/// - Seguimiento plataformero propio de Silicio.
/// - Silicio NO colisiona con Maya.
/// - Silicio reproduce salto / sentón / dash / run / idle.
/// =========================================================


// =========================================================
// UTILIDAD: SPRITE OPCIONAL
// =========================================================

function scr_platformer_ext_sprite(_name, _fallback)
{
    var _spr =
        asset_get_index(
            _name
        );


    if (
        _spr != -1
        &&
        sprite_exists(
            _spr
        )
    )
    {
        return _spr;
    }


    return _fallback;
}


// =========================================================
// DASH - PREPARAR
// =========================================================

function scr_platformer_dash_prepare(_p)
{
    if (
        _p == noone
        ||
        !instance_exists(
            _p
        )
    )
    {
        return false;
    }


    if (
        !variable_instance_exists(
            _p,
            "platform_dash_ready"
        )
    )
    {
        _p.platform_dash_ready =
            true;


        _p.platform_dash_active =
            false;


        _p.platform_dash_timer =
            0;


        // 6 frames a 30 FPS = ~0.20 s.
        _p.platform_dash_duration =
            6;


        // 10 px por frame = 60 px por Dash completo.
        _p.platform_dash_speed =
            10;


        _p.platform_dash_dir =
            1;


        // Pequeño cooldown tras terminar.
        _p.platform_dash_cooldown =
            0;


        _p.platform_dash_cooldown_max =
            8;


        // Un Dash aéreo hasta volver a tocar suelo.
        _p.platform_dash_air_available =
            true;


        _p.platform_dash_saved_alpha =
            _p.image_alpha;


        // Silicio permanece oculto si el Dash se inició en el
        // aire y después Maya sigue cayendo.
        _p.platform_dash_started_in_air =
            false;


        _p.platform_dash_wait_silicio_ground =
            false;
    }


    return true;
}


// =========================================================
// DASH - ¿DESBLOQUEADO?
// =========================================================
//
// En plataformero NO requiere rango de peligro.
//
// Basta con:
//
//     Habilidad Dash
//          O
//     Zapatos Rápidos
//
// =========================================================

function scr_platformer_dash_unlocked(_p)
{
    if (
        _p == noone
        ||
        !instance_exists(
            _p
        )
    )
    {
        return false;
    }


    return
        scr_habilidad_tiene(
            "dash"
        )
        ||
        scr_player_has_dash_armor(
            _p
        );
}


// =========================================================
// DASH - DESTRUIR VISUAL
// =========================================================

function scr_platformer_dash_visual_destroy(_p)
{
    if (!instance_exists(obj_platformer_dash_visual))
    {
        return;
    }


    with (obj_platformer_dash_visual)
    {
        if (
            owner_ref
            ==
            _p
        )
        {
            instance_destroy();
        }
    }
}


// =========================================================
// DASH - TERMINAR
// =========================================================

function scr_platformer_dash_finish(_p)
{
    if (
        _p == noone
        ||
        !instance_exists(
            _p
        )
    )
    {
        return;
    }


    scr_platformer_dash_prepare(
        _p
    );


    _p.platform_dash_active =
        false;


    _p.platform_dash_timer =
        0;


    _p.platform_hsp =
        0;


    _p.platform_vsp =
        0;


    _p.platform_x_rem =
        0;


    _p.platform_y_rem =
        0;


    _p.image_alpha =
        _p.platform_dash_saved_alpha;


    if (_p.platform_dash_started_in_air)
    {
        _p.platform_dash_wait_silicio_ground =
            true;
    }


    scr_platformer_dash_visual_destroy(
        _p
    );
}


// =========================================================
// DASH - CANCELAR AL SALIR DEL MODO
// =========================================================

function scr_platformer_dash_cancel(_p)
{
    if (
        _p == noone
        ||
        !instance_exists(
            _p
        )
    )
    {
        return;
    }


    scr_platformer_dash_prepare(
        _p
    );


    if (_p.platform_dash_active)
    {
        scr_platformer_dash_finish(
            _p
        );
    }


    _p.platform_dash_cooldown =
        0;


    _p.platform_dash_air_available =
        true;


    _p.platform_dash_started_in_air =
        false;


    _p.platform_dash_wait_silicio_ground =
        false;
}


// =========================================================
// DASH - UPDATE
// =========================================================
//
// Devuelve TRUE cuando el Dash consumió la física de este
// frame.
//
// Mientras devuelve TRUE:
//
//     NO debe ejecutarse scr_platformer_player_update()
//
// De esa forma:
//
//     - no hay gravedad;
//     - no hay salto;
//     - no hay ataque;
//     - Maya mantiene exactamente su altura;
//     - solo se mueve horizontalmente hacia donde mira.
// =========================================================

function scr_platformer_dash_update(_p)
{
    if (
        _p == noone
        ||
        !instance_exists(
            _p
        )
    )
    {
        return false;
    }


    scr_platformer_dash_prepare(
        _p
    );


    // =====================================================
    // COOLDOWN
    // =====================================================

    if (_p.platform_dash_cooldown > 0)
    {
        _p.platform_dash_cooldown--;
    }


    // =====================================================
    // SUELO REAL
    // =====================================================

    var _grounded_now =
        (
            _p.platform_vsp >= 0
            &&
            scr_platformer_floor_at(
                _p.x,
                _p.y + 1,
                _p.platform_hit_left,
                _p.platform_hit_top,
                _p.platform_hit_right,
                _p.platform_hit_bottom
            )
        );


    // El suelo restaura el Dash aéreo.
    //
    // NO hacerlo mientras el propio Dash está activo,
    // porque un Dash iniciado en suelo que abandone una cornisa
    // no debe regalar otro Dash inmediatamente.
    if (
        !_p.platform_dash_active
        &&
        _grounded_now
    )
    {
        _p.platform_dash_air_available =
            true;
    }


    // =====================================================
    // BLOQUEOS REALES DEL MUNDO
    // =====================================================

    var _world_blocked =
        false;


    if (
        variable_global_exists(
            "gameover_death_freeze_active"
        )
        &&
        global.gameover_death_freeze_active
    )
    {
        _world_blocked =
            true;
    }


    if (
        variable_global_exists(
            "cutscene_active"
        )
        &&
        global.cutscene_active
    )
    {
        _world_blocked =
            true;
    }


    if (
        instance_exists(
            obj_pauser
        )
        ||
        instance_exists(
            obj_textbox
        )
        ||
        instance_exists(
            obj_save_menu
        )
    )
    {
        _world_blocked =
            true;
    }


    if (_world_blocked)
    {
        if (_p.platform_dash_active)
        {
            scr_platformer_dash_finish(
                _p
            );
        }


        return false;
    }


    // =====================================================
    // DASH YA ACTIVO
    // =====================================================

    if (_p.platform_dash_active)
    {
        _p.movimiento =
            true;


        _p.puede_moverse =
            false;


        _p.platform_hsp =
            0;


        _p.platform_vsp =
            0;


        _p.platform_x_rem =
            0;


        _p.platform_y_rem =
            0;


        _p.platform_grounded =
            false;


        var _blocked_wall =
            false;


        // Movimiento píxel por píxel.
        for (
            var _px = 0;
            _px < _p.platform_dash_speed;
            _px++
        )
        {
            var _next_x =
                _p.x
                +
                _p.platform_dash_dir;


            if (
                scr_platformer_collision_at(
                    _next_x,
                    _p.y,
                    _p.platform_hit_left,
                    _p.platform_hit_top,
                    _p.platform_hit_right,
                    _p.platform_hit_bottom
                )
            )
            {
                _blocked_wall =
                    true;

                break;
            }


            _p.x =
                _next_x;
        }


        _p.platform_dash_timer--;


        if (
            _blocked_wall
            ||
            _p.platform_dash_timer <= 0
        )
        {
            scr_platformer_dash_finish(
                _p
            );


            _p.platform_dash_cooldown =
                _p.platform_dash_cooldown_max;
        }


        return true;
    }


    // =====================================================
    // ¿PUEDE COMENZAR?
    // =====================================================

    var _menu_open =
        (
            instance_exists(
                obj_menu_manager
            )
            &&
            obj_menu_manager.state
            !=
            MENU_STATE.CLOSED
        );


    if (_menu_open)
    {
        return false;
    }


    if (
        !keyboard_check_pressed(
            vk_space
        )
    )
    {
        return false;
    }


    if (
        !scr_platformer_dash_unlocked(
            _p
        )
    )
    {
        return false;
    }


    if (_p.platform_dash_cooldown > 0)
    {
        return false;
    }


    // En aire:
    // un solo Dash hasta tocar suelo.
    if (
        !_grounded_now
        &&
        !_p.platform_dash_air_available
    )
    {
        return false;
    }


    // =====================================================
    // INICIAR DASH
    // =====================================================

    _p.platform_dash_active =
        true;


    _p.platform_dash_started_in_air =
        !_grounded_now;


    _p.platform_dash_wait_silicio_ground =
        false;


    _p.platform_dash_timer =
        _p.platform_dash_duration;


    _p.platform_dash_dir =
        (
            _p.platform_facing < 0
            ?
            -1
            :
            1
        );


    // Cualquier Dash consume la disponibilidad aérea.
    // Se restaurará al volver a estar en suelo.
    _p.platform_dash_air_available =
        false;


    _p.platform_stomp_active =
        false;


    _p.platform_stomp_available =
        false;


    _p.platform_jump_buffer =
        0;


    _p.platform_coyote =
        0;


    _p.platform_hsp =
        0;


    _p.platform_vsp =
        0;


    _p.platform_x_rem =
        0;


    _p.platform_y_rem =
        0;


    _p.platform_dash_saved_alpha =
        _p.image_alpha;


    // Ocultar el sprite normal.
    // obj_platformer_dash_visual dibuja el sprite específico.
    _p.image_alpha =
        0;


    // Visual propio.
    var _visual =
        instance_create_depth(
            _p.x,
            _p.y,
            _p.depth - 100,
            obj_platformer_dash_visual
        );


    if (_visual != noone)
    {
        _visual.owner_ref =
            _p;
    }


    keyboard_clear(
        vk_space
    );


    // Mover ya en este mismo frame.
    return
        scr_platformer_dash_update(
            _p
        );
}


// =========================================================
// HISTORIAL PLATAFORMERO DE PARTY
// =========================================================

function scr_platformer_party_ext_init()
{
    if (
        !variable_global_exists(
            "platform_party_history"
        )
        ||
        !is_array(
            global.platform_party_history
        )
    )
    {
        global.platform_party_history =
            [];
    }


    if (
        !variable_global_exists(
            "platform_party_room"
        )
    )
    {
        global.platform_party_room =
            -1;
    }


    if (
        !variable_global_exists(
            "platform_party_was_active"
        )
    )
    {
        global.platform_party_was_active =
            false;
    }


    // Silicio reproduce a Maya unos frames después.
    if (
        !variable_global_exists(
            "platform_party_delay_frames"
        )
    )
    {
        global.platform_party_delay_frames =
            7;
    }


    // Compatibilidad con builds anteriores.
    // Ya NO forzamos separación mínima entre Maya y Silicio.
    if (
        !variable_global_exists(
            "platform_party_ground_gap"
        )
    )
    {
        global.platform_party_ground_gap =
            0;
    }
    else
    {
        global.platform_party_ground_gap =
            0;
    }


    if (
        !variable_global_exists(
            "platform_party_history_max"
        )
    )
    {
        global.platform_party_history_max =
            180;
    }
}


// =========================================================
// SNAPSHOT DE MAYA
// =========================================================

function scr_platformer_party_snapshot(_p)
{
    var _state =
        "idle";


    if (
        variable_instance_exists(
            _p,
            "platform_dash_active"
        )
        &&
        _p.platform_dash_active
    )
    {
        _state =
            "dash";
    }
    else if (
        variable_instance_exists(
            _p,
            "platform_stomp_active"
        )
        &&
        _p.platform_stomp_active
    )
    {
        _state =
            "stomp";
    }
    else if (
        !variable_instance_exists(
            _p,
            "platform_grounded"
        )
        ||
        !_p.platform_grounded
    )
    {
        _state =
            "jump";
    }
    else if (
        abs(
            _p.platform_hsp
        )
        >
        0.20
    )
    {
        _state =
            "run";
    }


    return
    {
        // Pies físicos del plataformero.
        //
        // NO usamos bbox del sprite:
        // los sprites de plataforma pueden tener otros tamaños.
        x:
            _p.x
            +
            (
                (
                    _p.platform_hit_left
                    +
                    _p.platform_hit_right
                )
                *
                0.5
            ),

        y:
            _p.y
            +
            _p.platform_hit_bottom,

        facing:
            (
                _p.platform_facing < 0
                ?
                -1
                :
                1
            ),

        grounded:
            _p.platform_grounded,

        state:
            _state
    };
}


// =========================================================
// RESET DE PARTY PLATAFORMERO
// =========================================================

function scr_platformer_party_follow_leave()
{
    scr_platformer_party_ext_init();


    if (global.platform_party_was_active)
    {
        global.platform_party_history =
            [];


        global.platform_party_room =
            -1;


        global.platform_party_was_active =
            false;


        // El party RPG necesita construir historial nuevo.
        global.party_room_dirty =
            true;
    }
}


// =========================================================
// SPRITE PLATAFORMERO DE SILICIO
// =========================================================
//
// Estados equivalentes a Maya:
//
// idle:
//     spr_silicio_platform_idle_izquierda
//     spr_silicio_platform_idle_derecha
//
// run:
//     spr_silicio_platform_run_izquierda
//     spr_silicio_platform_run_derecha
//
// jump:
//     spr_silicio_platform_salto
//
// stomp:
//     spr_silicio_platform_senton
//
// dash:
//     spr_silicio_platform_dash_izquierda
//     spr_silicio_platform_dash_derecha
//
// Todos son opcionales: si todavía no existe el arte se usa
// un fallback seguro.
// =========================================================

function scr_platformer_silicio_apply_extended_sprite(
    _sil,
    _state,
    _facing
)
{
    if (
        _sil == noone
        ||
        !instance_exists(
            _sil
        )
    )
    {
        return;
    }


    var _left =
        _facing < 0;


    var _fallback_side =
        (
            _left
            ?
            spr_silicio_izquierda
            :
            spr_silicio_derecha
        );


    var _spr =
        _fallback_side;


    switch (_state)
    {
        case "dash":

            _spr =
                scr_platformer_ext_sprite(
                    (
                        _left
                        ?
                        "spr_silicio_platform_dash_izquierda"
                        :
                        "spr_silicio_platform_dash_derecha"
                    ),
                    scr_platformer_ext_sprite(
                        "spr_silicio_platform_salto",
                        _fallback_side
                    )
                );

            break;


        case "stomp":

            _spr =
                scr_platformer_ext_sprite(
                    "spr_silicio_platform_senton",
                    scr_platformer_ext_sprite(
                        (
                            _left
                            ?
                            "spr_silicio_platform_salto_izquierda"
                            :
                            "spr_silicio_platform_salto_derecha"
                        ),
                        scr_platformer_ext_sprite(
                            "spr_silicio_platform_salto",
                            _fallback_side
                        )
                    )
                );

            break;


        case "jump":

            _spr =
                scr_platformer_ext_sprite(
                    (
                        _left
                        ?
                        "spr_silicio_platform_salto_izquierda"
                        :
                        "spr_silicio_platform_salto_derecha"
                    ),
                    scr_platformer_ext_sprite(
                        "spr_silicio_platform_salto",
                        _fallback_side
                    )
                );

            break;


        case "run":

            _spr =
                scr_platformer_ext_sprite(
                    (
                        _left
                        ?
                        "spr_silicio_platform_run_izquierda"
                        :
                        "spr_silicio_platform_run_derecha"
                    ),
                    _fallback_side
                );

            break;


        default:

            _spr =
                scr_platformer_ext_sprite(
                    (
                        _left
                        ?
                        "spr_silicio_platform_idle_izquierda"
                        :
                        "spr_silicio_platform_idle_derecha"
                    ),
                    _fallback_side
                );

            break;
    }


    if (
        _spr != -1
        &&
        _sil.sprite_index != _spr
    )
    {
        _sil.sprite_index =
            _spr;


        _sil.image_index =
            0;
    }


    if (_state == "idle")
    {
        _sil.image_speed =
            0;
    }
    else
    {
        _sil.image_speed =
            1;
    }


    _sil.image_xscale =
        abs(
            _sil.platform_sil_saved_image_xscale
        );


    _sil.image_yscale =
        _sil.platform_sil_saved_image_yscale;


    _sil.platform_sil_facing =
        (
            _left
            ?
            -1
            :
            1
        );


    _sil.facing_direction =
        (
            _left
            ?
            1
            :
            0
        );


    _sil.direccion =
        (
            _left
            ?
            "izquierda"
            :
            "derecha"
        );
}


// =========================================================
// FOLLOW PLATAFORMERO DE SILICIO
// =========================================================
//
// IMPORTANTE:
//
// Durante el plataformero NO usamos scr_party_update().
//
// Silicio sigue un historial por FRAMES de la física ya
// validada de Maya.
//
// Por tanto:
//
// - no consulta colisión con obj_player;
// - no intenta empujar a Maya;
// - no se queda atorado contra ella;
// - un sentón de 18 px/frame NO se interpreta como teleport;
// - reproduce el mismo estado unos frames después.
// =========================================================

function scr_platformer_party_follow_update()
{
    scr_platformer_party_ext_init();


    if (
        !variable_global_exists(
            "platformer_active"
        )
        ||
        !global.platformer_active
    )
    {
        scr_platformer_party_follow_leave();

        return false;
    }


    if (!instance_exists(obj_player))
    {
        return false;
    }


    scr_party_init();


    // Asegurar que Silicio exista si pertenece a la party.
    scr_party_ensure_instances();


    if (!scr_party_has("silicio"))
    {
        return false;
    }


    var _p =
        instance_find(
            obj_player,
            0
        );


    var _sil =
        scr_party_get_instance(
            "silicio"
        );


    if (
        _sil == noone
        ||
        !instance_exists(
            _sil
        )
    )
    {
        return false;
    }


    // Snapshot actual ANTES de inicializar el historial.
    var _snapshot =
        scr_platformer_party_snapshot(
            _p
        );


    // =====================================================
    // NUEVA ROOM / PRIMER FRAME
    // =====================================================
    //
    // El obj_silicio de la party es persistent. Al cambiar de
    // room podía conservar durante un frame las coordenadas de
    // la habitación anterior y después el antiguo bloque de
    // separación lo empujaba automáticamente detrás de Maya.
    // Eso producía el parpadeo + "teleport" visible.
    //
    // Ahora, ANTES del primer Draw del plataformero:
    //
    //     - Silicio se coloca exactamente sobre los pies de Maya;
    //     - se permite que ambos ocupen el mismo sitio;
    //     - sembramos el retraso con snapshots idénticos;
    //     - NO existe empuje automático para separarlos.
    // =====================================================

    if (
        global.platform_party_room
        !=
        room
        ||
        !global.platform_party_was_active
    )
    {
        global.platform_party_history =
            [];


        global.platform_party_room =
            room;


        global.platform_party_was_active =
            true;


        with (_sil)
        {
            scr_platformer_silicio_enter();
        }


        _sil.x =
            _snapshot.x;


        _sil.y =
            _snapshot.y
            -
            _sil.platform_sil_hit_bottom;


        _sil.platform_sil_prev_x =
            _sil.x;


        _sil.platform_sil_prev_y =
            _sil.y;


        // Sembrar el buffer para que el follower empiece desde
        // la misma posición sin esperar 7 frames ni hacer snap.
        for (
            var _seed = 0;
            _seed <= global.platform_party_delay_frames;
            _seed++
        )
        {
            array_push(
                global.platform_party_history,
                {
                    x: _snapshot.x,
                    y: _snapshot.y,
                    facing: _snapshot.facing,
                    grounded: _snapshot.grounded,
                    state: _snapshot.state
                }
            );
        }
    }


    // =====================================================
    // REGISTRAR MAYA TODOS LOS FRAMES
    // =====================================================
    //
    // A diferencia del party RPG:
    //
    // incluso un movimiento vertical de 18 px NO significa warp.
    //
    // Eso permite registrar íntegro el sentón.
    // =====================================================

    array_push(
        global.platform_party_history,
        _snapshot
    );


    var _over =
        array_length(
            global.platform_party_history
        )
        -
        global.platform_party_history_max;


    if (_over > 0)
    {
        array_delete(
            global.platform_party_history,
            0,
            _over
        );
    }


    // =====================================================
    // AÚN NO HAY SUFICIENTE RETRASO
    // =====================================================

    var _count =
        array_length(
            global.platform_party_history
        );


    if (
        _count
        <=
        global.platform_party_delay_frames
    )
    {
        with (_sil)
        {
            scr_platformer_silicio_enter();


            platform_sil_prev_x =
                x;


            platform_sil_prev_y =
                y;


            scr_platformer_silicio_apply_extended_sprite(
                id,
                "idle",
                platform_sil_facing
            );
        }


        return true;
    }


    var _target_index =
        _count
        -
        1
        -
        global.platform_party_delay_frames;


    _target_index =
        clamp(
            _target_index,
            0,
            _count - 1
        );


    var _target =
        global.platform_party_history[
            _target_index
        ];


    // =====================================================
    // PIES ACTUALES DE SILICIO
    // =====================================================

    with (_sil)
    {
        scr_platformer_silicio_enter();
    }


    var _sil_feet_x =
        _sil.x;


    var _sil_feet_y =
        _sil.y
        +
        _sil.platform_sil_hit_bottom;


    // =====================================================
    // MAYA Y SILICIO PUEDEN SUPERPONERSE
    // =====================================================
    //
    // No existe ninguna corrección de distancia contra Maya.
    // Si el historial coloca a Silicio justo encima del jugador,
    // se respeta exactamente esa posición.
    // =====================================================


    // =====================================================
    // CONSERVAR DISTANCIA AL DETENERSE HORIZONTALMENTE
    // =====================================================
    //
    // Si Maya venía caminando a izquierda/derecha y se queda
    // quieta EN SUELO, Silicio conserva la X que ya alcanzó.
    // No intenta terminar de juntarse con Maya.
    //
    // Esto NO empuja ni teletransporta a Silicio: únicamente
    // congela su objetivo X actual hasta que Maya vuelva a
    // desplazarse lateralmente.
    //
    // Si Maya salta sin desplazamiento horizontal, el hold se
    // libera. Así Silicio sí puede acomodarse con Maya durante
    // un salto vertical en la misma posición.
    // =====================================================

    if (
        !variable_instance_exists(
            _sil,
            "platform_follow_hold_x_active"
        )
    )
    {
        _sil.platform_follow_hold_x_active =
            false;

        _sil.platform_follow_hold_x =
            _sil_feet_x;

        _sil.platform_follow_was_lateral =
            false;
    }


    var _player_lateral_now =
        abs(
            _p.platform_hsp
        )
        >
        0.20;


    var _player_grounded_now =
        variable_instance_exists(
            _p,
            "platform_grounded"
        )
        &&
        _p.platform_grounded;


    var _jumping_in_place =
        !_player_grounded_now
        &&
        !_player_lateral_now
        &&
        _snapshot.state == "jump";


    if (_player_lateral_now)
    {
        _sil.platform_follow_hold_x_active =
            false;

        _sil.platform_follow_was_lateral =
            true;
    }
    else if (_jumping_in_place)
    {
        // Un salto vertical debe permitir que Silicio se alinee
        // con Maya; no conservar la distancia horizontal vieja.
        _sil.platform_follow_hold_x_active =
            false;

        _sil.platform_follow_was_lateral =
            false;
    }
    else if (_player_grounded_now)
    {
        if (
            _sil.platform_follow_was_lateral
            &&
            !_sil.platform_follow_hold_x_active
        )
        {
            _sil.platform_follow_hold_x =
                _sil_feet_x;

            _sil.platform_follow_hold_x_active =
                true;

            _sil.platform_follow_was_lateral =
                false;
        }


        if (_sil.platform_follow_hold_x_active)
        {
            _target.x =
                _sil.platform_follow_hold_x;
        }
    }


    // =====================================================
    // MOVIMIENTO REAL DE SILICIO
    // =====================================================
    //
    // Máximo 20 px/frame:
    //
    // suficiente para reproducir:
    //     salto,
    //     caída,
    //     sentón (máx. 18),
    //     dash (10),
    //
    // pero evita cualquier snap gigante si algo externo altera
    // el historial.
    // =====================================================

    var _dx =
        _target.x
        -
        _sil_feet_x;


    var _dy =
        _target.y
        -
        _sil_feet_y;


    var _distance =
        point_distance(
            _sil_feet_x,
            _sil_feet_y,
            _target.x,
            _target.y
        );


    var _max_follow_step =
        20;


    var _move_x =
        _dx;


    var _move_y =
        _dy;


    if (_distance > _max_follow_step)
    {
        var _ratio =
            _max_follow_step
            /
            _distance;


        _move_x *=
            _ratio;


        _move_y *=
            _ratio;
    }


    var _new_feet_x =
        _sil_feet_x
        +
        _move_x;


    var _new_feet_y =
        _sil_feet_y
        +
        _move_y;


    // =====================================================
    // COLOCAR SIN COLISIÓN CONTRA MAYA
    // =====================================================
    //
    // La trayectoria viene de una ruta que Maya YA recorrió.
    // No hace falta una segunda física que pueda pelearse con
    // el cuerpo del jugador.
    // =====================================================

    _sil.x =
        _new_feet_x;


    _sil.y =
        _new_feet_y
        -
        _sil.platform_sil_hit_bottom;


    _sil.platform_sil_move_x =
        _move_x;


    _sil.platform_sil_move_y =
        _move_y;


    _sil.platform_sil_grounded =
        _target.grounded;


    _sil.movimiento =
        (
            abs(_move_x) > 0.001
            ||
            abs(_move_y) > 0.001
        );


    // En plataformero Silicio siempre se dibuja detrás de Maya.
    _sil.depth =
        _p.depth
        +
        1;


    scr_platformer_silicio_apply_extended_sprite(
        _sil,
        _target.state,
        _target.facing
    );


    _sil.platform_sil_prev_x =
        _sil.x;


    _sil.platform_sil_prev_y =
        _sil.y;


    return true;
}


// =========================================================
// SILICIO - FADE POR SIGILO / DASH
// =========================================================
//
// RPG:
//     Sigilo (S)      -> desaparecer suavemente.
//     Dash del mapa   -> desaparecer suavemente.
//
// Plataformero:
//     Dash            -> desaparecer suavemente.
//     Si empezó en el aire, permanece oculto hasta aterrizar.
//
// Durante recuperación del vacío se fuerza visible porque
// Maya y Silicio son arrastrados juntos.
// =========================================================

function scr_silicio_visibility_update(_p)
{
    if (
        _p == noone
        ||
        !instance_exists(_p)
        ||
        !scr_party_has("silicio")
    )
    {
        return;
    }


    var _sil =
        scr_party_get_instance(
            "silicio"
        );


    if (
        _sil == noone
        ||
        !instance_exists(_sil)
    )
    {
        return;
    }


    if (
        !variable_instance_exists(
            _sil,
            "party_fx_alpha"
        )
    )
    {
        _sil.party_fx_alpha =
            clamp(
                _sil.image_alpha,
                0,
                1
            );


        _sil.party_fx_fade_speed =
            0.18;
    }


    var _platformer =
        variable_global_exists(
            "platformer_active"
        )
        &&
        global.platformer_active;


    var _force_visible_recovery =
        variable_instance_exists(
            _p,
            "platform_void_recover_active"
        )
        &&
        _p.platform_void_recover_active;


    var _hide =
        false;


    var _on_ice =
        (
            variable_instance_exists(
                _p,
                "ice_on_normal"
            )
            &&
            _p.ice_on_normal
        )
        ||
        (
            variable_instance_exists(
                _p,
                "ice_on_blue"
            )
            &&
            _p.ice_on_blue
        );


    if (_force_visible_recovery)
    {
        _hide =
            false;
    }
    else if (_on_ice)
    {
        // Ambos hielos del sistema actual:
        // obj_hielo y obj_hielo_azul.
        _hide =
            true;
    }
    else if (_platformer)
    {
        var _platform_dash =
            variable_instance_exists(
                _p,
                "platform_dash_active"
            )
            &&
            _p.platform_dash_active;


        if (_platform_dash)
        {
            _hide =
                true;
        }
        else if (
            variable_instance_exists(
                _p,
                "platform_dash_wait_silicio_ground"
            )
            &&
            _p.platform_dash_wait_silicio_ground
        )
        {
            var _landed =
                variable_instance_exists(
                    _p,
                    "platform_grounded"
                )
                &&
                _p.platform_grounded;


            if (_landed)
            {
                _p.platform_dash_wait_silicio_ground =
                    false;


                _p.platform_dash_started_in_air =
                    false;


                _hide =
                    false;
            }
            else
            {
                _hide =
                    true;
            }
        }
    }
    else
    {
        var _crouched =
            variable_instance_exists(
                _p,
                "sigilo_activo"
            )
            &&
            _p.sigilo_activo;


        var _map_dash =
            variable_instance_exists(
                _p,
                "dash_anim_active"
            )
            &&
            _p.dash_anim_active;


        _hide =
            _crouched
            ||
            _map_dash;
    }


    var _target_alpha =
        _hide
        ?
        0
        :
        1;


    _sil.party_fx_alpha +=
        clamp(
            _target_alpha
            -
            _sil.party_fx_alpha,
            -_sil.party_fx_fade_speed,
            _sil.party_fx_fade_speed
        );


    _sil.party_fx_alpha =
        clamp(
            _sil.party_fx_alpha,
            0,
            1
        );


    _sil.image_alpha =
        _sil.party_fx_alpha;
}


// =========================================================
// VACÍO - PREPARAR CHECKPOINT
// =========================================================

function scr_platformer_void_prepare(_p)
{
    if (
        _p == noone
        ||
        !instance_exists(_p)
    )
    {
        return false;
    }


    if (
        !variable_instance_exists(
            _p,
            "platform_void_ready"
        )
    )
    {
        _p.platform_void_ready =
            true;


        _p.platform_void_room =
            -1;


        _p.platform_void_safe_valid =
            false;


        _p.platform_void_safe_x =
            _p.x;


        _p.platform_void_safe_y =
            _p.y;


        _p.platform_void_safe_feet_x =
            _p.x;


        _p.platform_void_safe_feet_y =
            _p.y;


        _p.platform_void_recover_active =
            false;


        _p.platform_void_recover_timer =
            0;


        _p.platform_void_recover_duration =
            24;


        _p.platform_void_start_x =
            _p.x;


        _p.platform_void_start_y =
            _p.y;


        _p.platform_void_saved_blend =
            _p.image_blend;


        _p.platform_void_saved_alpha =
            _p.image_alpha;


        _p.platform_void_saved_puede_moverse =
            true;


        _p.platform_void_silicio =
            noone;


        _p.platform_void_sil_start_x =
            0;


        _p.platform_void_sil_start_y =
            0;


        _p.platform_void_sil_target_x =
            0;


        _p.platform_void_sil_target_y =
            0;


        _p.platform_void_sil_saved_blend =
            c_white;
    }


    return true;
}


// =========================================================
// VACÍO - GUARDAR ÚLTIMO PISO PISADO
// =========================================================

function scr_platformer_void_store_safe(_p)
{
    if (!scr_platformer_void_prepare(_p))
        return;


    var _center_x =
        (
            _p.platform_hit_left
            +
            _p.platform_hit_right
        )
        *
        0.5;


    _p.platform_void_safe_x =
        _p.x;


    _p.platform_void_safe_y =
        _p.y;


    _p.platform_void_safe_feet_x =
        _p.x
        +
        _center_x;


    _p.platform_void_safe_feet_y =
        _p.y
        +
        _p.platform_hit_bottom;


    _p.platform_void_safe_valid =
        true;
}


// =========================================================
// VACÍO - RESEMILLAR HISTORIAL DE SILICIO
// =========================================================

function scr_platformer_void_seed_party(_p)
{
    if (
        !variable_global_exists(
            "platform_party_history"
        )
        ||
        !is_array(
            global.platform_party_history
        )
    )
    {
        return;
    }


    var _snap =
        scr_platformer_party_snapshot(
            _p
        );


    global.platform_party_history =
        [];


    global.platform_party_room =
        room;


    global.platform_party_was_active =
        true;


    for (
        var _i = 0;
        _i <= global.platform_party_delay_frames;
        _i++
    )
    {
        array_push(
            global.platform_party_history,
            {
                x: _snap.x,
                y: _snap.y,
                facing: _snap.facing,
                grounded: true,
                state: "idle"
            }
        );
    }
}


// =========================================================
// VACÍO - COMENZAR RESCATE
// =========================================================

function scr_platformer_void_begin(_p)
{
    if (
        !scr_platformer_void_prepare(_p)
        ||
        !_p.platform_void_safe_valid
    )
    {
        return false;
    }


    // Si cayó mientras todavía hacía Dash, cerrar ese estado
    // antes de empezar a arrastrarlo de vuelta.
    if (
        variable_instance_exists(
            _p,
            "platform_dash_active"
        )
        &&
        _p.platform_dash_active
    )
    {
        scr_platformer_dash_finish(
            _p
        );
    }


    _p.platform_dash_wait_silicio_ground =
        false;


    _p.platform_dash_started_in_air =
        false;


    _p.platform_void_recover_active =
        true;


    _p.platform_void_recover_timer =
        0;


    _p.platform_void_start_x =
        _p.x;


    _p.platform_void_start_y =
        _p.y;


    _p.platform_void_saved_blend =
        _p.image_blend;


    _p.platform_void_saved_alpha =
        _p.image_alpha;


    _p.platform_void_saved_puede_moverse =
        variable_instance_exists(
            _p,
            "puede_moverse"
        )
        ?
        _p.puede_moverse
        :
        true;


    var _distance =
        point_distance(
            _p.platform_void_start_x,
            _p.platform_void_start_y,
            _p.platform_void_safe_x,
            _p.platform_void_safe_y
        );


    _p.platform_void_recover_duration =
        clamp(
            round(
                _distance
                /
                10
            ),
            18,
            36
        );


    _p.platform_hsp =
        0;


    _p.platform_vsp =
        0;


    _p.platform_x_rem =
        0;


    _p.platform_y_rem =
        0;


    _p.platform_stomp_active =
        false;


    _p.platform_stomp_available =
        false;


    // -----------------------------------------------------
    // SILICIO
    // -----------------------------------------------------

    _p.platform_void_silicio =
        noone;


    if (scr_party_has("silicio"))
    {
        var _sil =
            scr_party_get_instance(
                "silicio"
            );


        if (
            _sil != noone
            &&
            instance_exists(_sil)
        )
        {
            with (_sil)
            {
                scr_platformer_silicio_enter();
            }


            _p.platform_void_silicio =
                _sil;


            _p.platform_void_sil_start_x =
                _sil.x;


            _p.platform_void_sil_start_y =
                _sil.y;


            _p.platform_void_sil_target_x =
                _p.platform_void_safe_feet_x;


            _p.platform_void_sil_target_y =
                _p.platform_void_safe_feet_y
                -
                _sil.platform_sil_hit_bottom;


            _p.platform_void_sil_saved_blend =
                _sil.image_blend;


            // Durante el rescate ambos deben verse.
            _sil.image_alpha =
                1;


            if (
                variable_instance_exists(
                    _sil,
                    "party_fx_alpha"
                )
            )
            {
                _sil.party_fx_alpha =
                    1;
            }
        }
    }


    return true;
}


// =========================================================
// VACÍO - UPDATE
// =========================================================
//
// Devuelve TRUE mientras el rescate consume completamente la
// física del jugador.
// =========================================================

function scr_platformer_void_recovery_update(_p)
{
    if (!scr_platformer_void_prepare(_p))
        return false;


    // Nueva room: el punto seguro anterior NO es válido aquí.
    if (_p.platform_void_room != room)
    {
        _p.platform_void_room =
            room;


        _p.platform_void_recover_active =
            false;


        _p.platform_void_safe_valid =
            false;


        // La posición de entrada sirve como fallback hasta que
        // realmente pise un suelo.
        scr_platformer_void_store_safe(
            _p
        );
    }


    // =====================================================
    // FUERA DEL RESCATE
    // =====================================================

    if (!_p.platform_void_recover_active)
    {
        var _grounded =
            (
                variable_instance_exists(
                    _p,
                    "platform_grounded"
                )
                &&
                _p.platform_grounded
            )
            ||
            (
                _p.platform_vsp >= 0
                &&
                scr_platformer_floor_at(
                    _p.x,
                    _p.y + 1,
                    _p.platform_hit_left,
                    _p.platform_hit_top,
                    _p.platform_hit_right,
                    _p.platform_hit_bottom
                )
            );


        if (
            _grounded
            &&
            !(
                variable_instance_exists(
                    _p,
                    "platform_dash_active"
                )
                &&
                _p.platform_dash_active
            )
            &&
            !(
                variable_instance_exists(
                    _p,
                    "platform_stomp_active"
                )
                &&
                _p.platform_stomp_active
            )
        )
        {
            // Esto hace que "última ubicación donde pisó" sea
            // literalmente el último punto estable del suelo.
            scr_platformer_void_store_safe(
                _p
            );
        }


        // Consideramos vacío cuando todo el cuerpo ya cayó por
        // debajo del room. También cubrimos salidas laterales
        // extremas por un Dash sin pared.
        var _body_top =
            _p.y
            +
            _p.platform_hit_top;


        var _body_right =
            _p.x
            +
            _p.platform_hit_right;


        var _body_left =
            _p.x
            +
            _p.platform_hit_left;


        var _outside =
            (
                _body_top
                >
                room_height
                +
                24
            )
            ||
            (
                _body_right
                <
                -64
            )
            ||
            (
                _body_left
                >
                room_width
                +
                64
            );


        if (_outside)
        {
            if (
                scr_platformer_void_begin(
                    _p
                )
            )
            {
                return true;
            }
        }


        return false;
    }


    // =====================================================
    // RESCATE ACTIVO
    // =====================================================

    _p.platform_void_recover_timer++;


    var _t =
        clamp(
            _p.platform_void_recover_timer
            /
            max(
                1,
                _p.platform_void_recover_duration
            ),
            0,
            1
        );


    // Ease-out cúbico: acelera al empezar y llega suave.
    var _ease =
        1
        -
        power(
            1 - _t,
            3
        );


    // Pequeño bamboleo que hace que parezca arrastrado/llevado.
    var _drag_wave =
        sin(
            _t
            *
            pi
            *
            6
        )
        *
        (1 - _t)
        *
        2.5;


    _p.x =
        lerp(
            _p.platform_void_start_x,
            _p.platform_void_safe_x,
            _ease
        )
        +
        _drag_wave;


    _p.y =
        lerp(
            _p.platform_void_start_y,
            _p.platform_void_safe_y,
            _ease
        )
        -
        abs(_drag_wave)
        *
        0.35;


    _p.platform_hsp =
        0;


    _p.platform_vsp =
        0;


    _p.platform_x_rem =
        0;


    _p.platform_y_rem =
        0;


    if (
        variable_instance_exists(
            _p,
            "puede_moverse"
        )
    )
    {
        _p.puede_moverse =
            false;
    }


    _p.movimiento =
        false;


    _p.image_alpha =
        1;


    _p.image_blend =
        make_color_rgb(
            165,
            165,
            165
        );


    // -----------------------------------------------------
    // SILICIO VIAJA CON MAYA
    // -----------------------------------------------------

    var _sil =
        _p.platform_void_silicio;


    if (
        _sil != noone
        &&
        instance_exists(_sil)
    )
    {
        _sil.x =
            lerp(
                _p.platform_void_sil_start_x,
                _p.platform_void_sil_target_x,
                _ease
            )
            -
            (_drag_wave * 0.55);


        _sil.y =
            lerp(
                _p.platform_void_sil_start_y,
                _p.platform_void_sil_target_y,
                _ease
            )
            -
            abs(_drag_wave)
            *
            0.20;


        _sil.image_alpha =
            1;


        _sil.image_blend =
            make_color_rgb(
                165,
                165,
                165
            );
    }


    // =====================================================
    // FIN DEL ARRASTRE
    // =====================================================

    if (_t >= 1)
    {
        _p.x =
            _p.platform_void_safe_x;


        _p.y =
            _p.platform_void_safe_y;


        _p.image_blend =
            _p.platform_void_saved_blend;


        _p.image_alpha =
            _p.platform_void_saved_alpha;


        if (
            variable_instance_exists(
                _p,
                "puede_moverse"
            )
        )
        {
            _p.puede_moverse =
                _p.platform_void_saved_puede_moverse;
        }


        _p.platform_grounded =
            true;


        _p.platform_vsp =
            0;


        _p.platform_hsp =
            0;


        _p.platform_stomp_active =
            false;


        _p.platform_stomp_available =
            true;


        _p.platform_dash_air_available =
            true;


        _p.platform_dash_wait_silicio_ground =
            false;


        _p.platform_dash_started_in_air =
            false;


        if (
            _sil != noone
            &&
            instance_exists(_sil)
        )
        {
            _sil.x =
                _p.platform_void_sil_target_x;


            _sil.y =
                _p.platform_void_sil_target_y;


            _sil.image_blend =
                _p.platform_void_sil_saved_blend;


            _sil.image_alpha =
                1;


            if (
                variable_instance_exists(
                    _sil,
                    "party_fx_alpha"
                )
            )
            {
                _sil.party_fx_alpha =
                    1;
            }
        }


        _p.platform_void_recover_active =
            false;


        scr_platformer_void_seed_party(
            _p
        );


        // Actualizar otra vez el mismo punto seguro ya colocado.
        scr_platformer_void_store_safe(
            _p
        );
    }


    return true;
}




// =========================================================
// ATAQUE PLATAFORMERO - BLOQUEO POR PARED
// =========================================================
//
// scr_platformer_system usa una hitbox rectangular para dañar
// enemigos. Eso permitía que la hitbox atravesara una pared.
//
// Antes de ejecutar la física/ataque del frame deshabilitamos
// temporalmente enemigos y warps cuyo centro no tenga línea de
// visión limpia desde el centro físico de Maya.
//
// Al terminar scr_platformer_player_update() restauramos todos
// los valores exactamente como estaban.
// =========================================================

function scr_platformer_attack_los_blocked(
    _x1,
    _y1,
    _x2,
    _y2
)
{
    if (
        collision_line(
            _x1,
            _y1,
            _x2,
            _y2,
            colision,
            false,
            true
        )
        !=
        noone
    )
    {
        return true;
    }


    if (
        collision_line(
            _x1,
            _y1,
            _x2,
            _y2,
            colision_rampa,
            false,
            true
        )
        !=
        noone
    )
    {
        return true;
    }


    return false;
}


function scr_platformer_attack_los_prepare(_p)
{
    if (
        _p == noone
        ||
        !instance_exists(_p)
        ||
        !variable_global_exists(
            "platformer_active"
        )
        ||
        !global.platformer_active
    )
    {
        return;
    }


    var _sx =
        _p.x
        +
        (
            (
                _p.platform_hit_left
                +
                _p.platform_hit_right
            )
            *
            0.5
        );


    var _sy =
        _p.y
        +
        (
            (
                _p.platform_hit_top
                +
                _p.platform_hit_bottom
            )
            *
            0.5
        );


    // -----------------------------------------------------
    // ENEMIGOS
    // -----------------------------------------------------

    with (obj_enemigo_mapa_parent)
    {
        los_restore_pending =
            true;


        los_prev_can_attack =
            variable_instance_exists(
                id,
                "platform_can_be_attacked"
            )
            ?
            platform_can_be_attacked
            :
            true;


        var _tx =
            (bbox_left + bbox_right)
            *
            0.5;


        var _ty =
            (bbox_top + bbox_bottom)
            *
            0.5;


        if (
            scr_platformer_attack_los_blocked(
                other._sx,
                other._sy,
                _tx,
                _ty
            )
        )
        {
            platform_can_be_attacked =
                false;
        }
    }


    // -----------------------------------------------------
    // TRIGGERS DE SALIDA GOLPEABLES
    // -----------------------------------------------------

    var _warp_obj =
        asset_get_index(
            "obj_platformer_warp"
        );


    if (_warp_obj != -1)
    {
        var _n =
            instance_number(
                _warp_obj
            );


        for (
            var _i = 0;
            _i < _n;
            _i++
        )
        {
            var _w =
                instance_find(
                    _warp_obj,
                    _i
                );


            if (
                _w == noone
                ||
                !instance_exists(_w)
            )
            {
                continue;
            }


            _w.los_restore_pending =
                true;


            _w.los_prev_active =
                variable_instance_exists(
                    _w,
                    "active"
                )
                ?
                _w.active
                :
                true;


            var _blocked =
                scr_platformer_attack_los_blocked(
                    _sx,
                    _sy,
                    _w.x,
                    _w.y
                );


            if (_blocked)
            {
                _w.active =
                    false;
            }
        }
    }
}


function scr_platformer_attack_los_restore()
{
    with (obj_enemigo_mapa_parent)
    {
        if (
            variable_instance_exists(
                id,
                "los_restore_pending"
            )
            &&
            los_restore_pending
        )
        {
            platform_can_be_attacked =
                los_prev_can_attack;


            los_restore_pending =
                false;
        }
    }


    var _warp_obj =
        asset_get_index(
            "obj_platformer_warp"
        );


    if (_warp_obj != -1)
    {
        var _n =
            instance_number(
                _warp_obj
            );


        for (
            var _i = 0;
            _i < _n;
            _i++
        )
        {
            var _w =
                instance_find(
                    _warp_obj,
                    _i
                );


            if (
                _w == noone
                ||
                !instance_exists(_w)
            )
            {
                continue;
            }


            if (
                variable_instance_exists(
                    _w,
                    "los_restore_pending"
                )
                &&
                _w.los_restore_pending
            )
            {
                _w.active =
                    _w.los_prev_active;


                _w.los_restore_pending =
                    false;
            }
        }
    }
}
