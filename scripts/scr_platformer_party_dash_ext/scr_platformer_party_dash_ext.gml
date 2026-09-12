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


    // Separación mínima al quedar ambos en suelo.
    if (
        !variable_global_exists(
            "platform_party_ground_gap"
        )
    )
    {
        global.platform_party_ground_gap =
            30;
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
                        "spr_silicio_platform_salto",
                        _fallback_side
                    )
                );

            break;


        case "jump":

            _spr =
                scr_platformer_ext_sprite(
                    "spr_silicio_platform_salto",
                    _fallback_side
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


    // =====================================================
    // NUEVA ROOM / PRIMER FRAME
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


            platform_sil_prev_x =
                x;


            platform_sil_prev_y =
                y;
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

    var _snapshot =
        scr_platformer_party_snapshot(
            _p
        );


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
    // EVITAR QUE TERMINE ENCIMA DE MAYA EN SUELO
    // =====================================================
    //
    // Esto NO es una colisión con el jugador.
    //
    // Solo modificamos el punto de formación cuando ambos ya
    // están en suelo y el historial los haría terminar casi
    // exactamente superpuestos.
    // =====================================================

    if (
        _target.grounded
        &&
        _snapshot.grounded
    )
    {
        var _player_feet_x =
            _snapshot.x;


        var _player_feet_y =
            _snapshot.y;


        var _horizontal_gap =
            abs(
                _sil_feet_x
                -
                _player_feet_x
            );


        if (
            _horizontal_gap
            <
            global.platform_party_ground_gap
        )
        {
            var _behind_x =
                _player_feet_x
                -
                (
                    _snapshot.facing
                    *
                    global.platform_party_ground_gap
                );


            // Comprobar SOLO escenario.
            //
            // Nunca obj_player.
            var _origin_y =
                _player_feet_y
                -
                _sil.platform_sil_hit_bottom;


            if (
                !scr_platformer_collision_at(
                    _behind_x,
                    _origin_y,
                    _sil.platform_sil_hit_left,
                    _sil.platform_sil_hit_top,
                    _sil.platform_sil_hit_right,
                    _sil.platform_sil_hit_bottom
                )
            )
            {
                _target.x =
                    _behind_x;


                _target.y =
                    _player_feet_y;


                _target.state =
                    "idle";


                _target.facing =
                    _snapshot.facing;
            }
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
