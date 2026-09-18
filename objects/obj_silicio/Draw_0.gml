/// =========================================================
/// OBJ_SILICIO
/// DRAW COMPLETO
/// =========================================================
///
/// - Conserva los sprites especiales de plataforma.
/// - Idle/Run/Dash/Sentón con varios frames se animan.
/// - Usa la velocidad configurada en el sprite.
/// - Si la velocidad configurada es 0, usa 6 FPS.
/// - Salto:
///       frame 0 = subiendo
///       frame 1 = cayendo
/// =========================================================


var _platformer =
    (
        variable_global_exists(
            "platformer_active"
        )
        &&
        global.platformer_active
    );


var _desired_name =
    "";


var _force_frame =
    -1;


// =========================================================
// PLATAFORMERO
// =========================================================

if (_platformer)
{
    var _fan_detached =
        (
            variable_instance_exists(
                id,
                "fan_detached"
            )
            &&
            fan_detached
        );


    // Mientras un abanico controla a Silicio, conservar el
    // sprite que ya dejó el sistema del viento.
    if (!_fan_detached)
    {
        var _left =
            false;


        if (
            variable_instance_exists(
                id,
                "platform_sil_facing"
            )
        )
        {
            _left =
                platform_sil_facing
                <
                0;
        }
        else
        {
            _left =
                facing_direction
                ==
                1;
        }


        var _state =
            "";


        if (
            variable_instance_exists(
                id,
                "platform_sil_visual_state"
            )
        )
        {
            _state =
                string(
                    platform_sil_visual_state
                );
        }


        var _airborne =
            (
                variable_instance_exists(
                    id,
                    "platform_sil_grounded"
                )
                &&
                !platform_sil_grounded
            );


        // =================================================
        // DASH
        // =================================================

        if (_state == "dash")
        {
            _desired_name =
                (
                    _left
                    ?
                    "spr_silicio_platform_dash_izquierda"
                    :
                    "spr_silicio_platform_dash_derecha"
                );
        }


        // =================================================
        // SENTÓN
        // =================================================

        else if (_state == "stomp")
        {
            _desired_name =
                (
                    _left
                    ?
                    "spr_silicio_platform_senton_izquierda"
                    :
                    "spr_silicio_platform_senton_derecha"
                );
        }


        // =================================================
        // SALTO / CAÍDA
        // =================================================

        else if (
            _state == "jump"
            ||
            _airborne
        )
        {
            _desired_name =
                (
                    _left
                    ?
                    "spr_silicio_platform_salto_izquierda"
                    :
                    "spr_silicio_platform_salto_derecha"
                );


            var _vertical_speed =
                0;


            if (
                variable_instance_exists(
                    id,
                    "platform_sil_vsp"
                )
            )
            {
                _vertical_speed =
                    platform_sil_vsp;
            }


            if (
                abs(_vertical_speed)
                <=
                0.01
                &&
                variable_instance_exists(
                    id,
                    "platform_sil_move_y"
                )
            )
            {
                _vertical_speed =
                    platform_sil_move_y;
            }


            _force_frame =
                (
                    _vertical_speed < 0
                    ?
                    0
                    :
                    1
                );
        }


        // =================================================
        // RUN
        // =================================================

        else if (
            _state == "run"
            ||
            (
                variable_instance_exists(
                    id,
                    "platform_sil_move_x"
                )
                &&
                abs(platform_sil_move_x)
                >
                0.20
            )
        )
        {
            _desired_name =
                (
                    _left
                    ?
                    "spr_silicio_platform_run_izquierda"
                    :
                    "spr_silicio_platform_run_derecha"
                );
        }


        // =================================================
        // IDLE
        // =================================================

        else
        {
            _desired_name =
                (
                    _left
                    ?
                    "spr_silicio_platform_idle_izquierda"
                    :
                    "spr_silicio_platform_idle_derecha"
                );
        }
    }
}


// =========================================================
// RPG - DESLIZAMIENTO HACIA ABAJO
// =========================================================

else
{
    if (
        variable_instance_exists(
            id,
            "party_special_mode"
        )
    )
    {
        var _special =
            string(
                party_special_mode
            );


        if (
            _special == "downslide_follow"
            ||
            _special == "downslide_exit"
        )
        {
            _desired_name =
                "spr_silicio_deslizamiento";
        }
    }
}


// =========================================================
// RESOLVER SPRITE CON FALLBACK
// =========================================================

var _draw_sprite =
    sprite_index;


if (_desired_name != "")
{
    var _candidate =
        asset_get_index(
            _desired_name
        );


    if (
        _candidate != -1
        &&
        sprite_exists(
            _candidate
        )
    )
    {
        _draw_sprite =
            _candidate;
    }
}


// =========================================================
// VALIDAR
// =========================================================

if (
    _draw_sprite == -1
    ||
    !sprite_exists(
        _draw_sprite
    )
)
{
    exit;
}


// =========================================================
// FRAME
// =========================================================

var _frame_count =
    max(
        1,
        sprite_get_number(
            _draw_sprite
        )
    );


var _draw_frame =
    floor(
        image_index
    );


// Salto/caída: frame fijo.
if (_force_frame >= 0)
{
    _draw_frame =
        clamp(
            _force_frame,
            0,
            _frame_count - 1
        );
}


// =========================================================
// ANIMACIÓN MANUAL PLATAFORMERA
// =========================================================

else if (
    _platformer
    &&
    _desired_name != ""
)
{
    if (
        !variable_instance_exists(
            id,
            "silicio_platform_visual_anim_sprite"
        )
    )
    {
        silicio_platform_visual_anim_sprite =
            -1;

        silicio_platform_visual_anim_frame =
            0;

        silicio_platform_visual_anim_accum =
            0;
    }


    if (
        silicio_platform_visual_anim_sprite
        !=
        _draw_sprite
    )
    {
        silicio_platform_visual_anim_sprite =
            _draw_sprite;

        silicio_platform_visual_anim_frame =
            0;

        silicio_platform_visual_anim_accum =
            0;
    }


    var _anim_speed =
        sprite_get_speed(
            _draw_sprite
        );


    var _anim_speed_type =
        sprite_get_speed_type(
            _draw_sprite
        );


    var _anim_fps =
        0;


    if (
        _anim_speed_type
        ==
        spritespeed_framespersecond
    )
    {
        _anim_fps =
            _anim_speed;
    }
    else
    {
        _anim_fps =
            _anim_speed
            *
            max(
                1,
                game_get_speed(
                    gamespeed_fps
                )
            );
    }


    if (_anim_fps <= 0)
    {
        _anim_fps =
            6;
    }


    var _dt_seconds =
        min(
            delta_time,
            100000
        )
        /
        1000000;


    silicio_platform_visual_anim_accum +=
        _anim_fps
        *
        _dt_seconds;


    while (
        silicio_platform_visual_anim_accum
        >=
        1
    )
    {
        silicio_platform_visual_anim_accum -=
            1;


        silicio_platform_visual_anim_frame =
            (
                silicio_platform_visual_anim_frame
                +
                1
            )
            mod
            _frame_count;
    }


    _draw_frame =
        clamp(
            silicio_platform_visual_anim_frame,
            0,
            _frame_count - 1
        );
}


// =========================================================
// RESTO DE ESTADOS: image_index NORMAL
// =========================================================

else
{
    if (
        variable_instance_exists(
            id,
            "silicio_platform_visual_anim_sprite"
        )
        &&
        !_platformer
    )
    {
        silicio_platform_visual_anim_sprite =
            -1;

        silicio_platform_visual_anim_frame =
            0;

        silicio_platform_visual_anim_accum =
            0;
    }


    _draw_frame =
        _draw_frame
        mod
        _frame_count;


    if (_draw_frame < 0)
    {
        _draw_frame +=
            _frame_count;
    }
}


// =========================================================
// DIBUJAR
// =========================================================

draw_sprite_ext(
    _draw_sprite,
    _draw_frame,
    x,
    y,
    image_xscale,
    image_yscale,
    image_angle,
    image_blend,
    image_alpha
);
