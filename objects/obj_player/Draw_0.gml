/// =========================================================
/// OBJ_PLAYER
/// DRAW COMPLETO
/// =========================================================
///
/// ARREGLOS VISUALES:
///
/// - Maya pasa de 37 px aprox. a 39 px aprox. tomando como
///   referencia los sprites originales de 28 px:
///
///       39 / 28 = 1.392857... = 139.29%
///
/// - El crecimiento queda ANCLADO A LOS PIES.
///   La parte inferior del sprite no baja al escalarlo:
///   el crecimiento ocurre hacia arriba.
///
/// - Las poses agachadas se dibujan 15 px más abajo.
///
/// - Los sprites de plataforma con varios frames vuelven a
///   animarse usando la velocidad configurada en el propio
///   sprite. Si la velocidad del sprite es 0, usa 6 FPS.
///
/// - Salto:
///       frame 0 = subiendo
///       frame 1 = cayendo
///
/// - Guarda el sprite/posición/escala visual final de Maya
///   para que obj_mapa_combate_fx pueda dibujar exactamente
///   el mismo sprite en rojo.
/// =========================================================


// =========================================================
// BBS - NO DIBUJAR AL PLAYER DEL MAPA
// =========================================================

if (room == bbs)
{
    exit;
}


// =========================================================
// INVALIDAR CACHÉ VISUAL DEL FRAME
// =========================================================
//
// Durante un Dash plataformero, obj_platformer_dash_visual
// volverá a rellenar estos datos con el sprite del Dash.
// =========================================================

maya_visual_valid =
    false;


// =========================================================
// ESCALA VISUAL UNIVERSAL DE MAYA
// =========================================================
//
// 28 px originales -> 39 px visuales.
// =========================================================

var _maya_scale =
    39
    /
    28;


var _draw_xscale =
    image_xscale
    *
    _maya_scale;


var _draw_yscale =
    image_yscale
    *
    _maya_scale;


// =========================================================
// ESTADOS GENERALES
// =========================================================

var _platformer =
    (
        variable_global_exists(
            "platformer_active"
        )
        &&
        global.platformer_active
    );


var _cutscene_sprite =
    (
        variable_instance_exists(
            id,
            "cutscene_sprite_override_active"
        )
        &&
        cutscene_sprite_override_active
    );


var _cutscene_motion =
    (
        variable_instance_exists(
            id,
            "cutscene_motion_active"
        )
        &&
        cutscene_motion_active
    );


var _cutscene_locked =
    (
        _cutscene_sprite
        ||
        _cutscene_motion
    );


// =========================================================
// PELIGRO / RANGO DE ATAQUE
// =========================================================

var _target_active =
    false;


if (instance_exists(obj_mapa_combate_fx))
{
    var _fx =
        instance_find(
            obj_mapa_combate_fx,
            0
        );


    if (
        _fx != noone
        &&
        variable_instance_exists(
            _fx,
            "danger_active"
        )
    )
    {
        _target_active =
            _fx.danger_active;
    }
}


// =========================================================
// SPRITE A DIBUJAR
// =========================================================

var _desired_name =
    "";


var _force_frame =
    -1;


var _crouch_visual =
    false;


// =========================================================
// MODO PLATAFORMERO
// =========================================================

if (
    _platformer
    &&
    !_cutscene_locked
)
{
    var _left =
        false;


    if (
        variable_instance_exists(
            id,
            "platform_facing"
        )
    )
    {
        _left =
            platform_facing
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


    // =====================================================
    // DASH
    // =====================================================
    //
    // El sprite lo dibuja obj_platformer_dash_visual.
    // =====================================================

    var _platform_dash =
        (
            variable_instance_exists(
                id,
                "platform_dash_active"
            )
            &&
            platform_dash_active
        );


    if (_platform_dash)
    {
        exit;
    }


    // =====================================================
    // ATAQUE
    // =====================================================

    var _attacking =
        (
            variable_instance_exists(
                id,
                "platform_attack_timer"
            )
            &&
            platform_attack_timer
            >
            0
        );


    if (_attacking)
    {
        var _attack_dir =
            (
                variable_instance_exists(
                    id,
                    "platform_attack_direction"
                )
                ?
                platform_attack_direction
                :
                "horizontal"
            );


        if (_attack_dir == "up")
        {
            _desired_name =
                (
                    _left
                    ?
                    "spr_maya_ataque_platform_arriba_izquierda"
                    :
                    "spr_maya_ataque_platform_arriba_derecha"
                );
        }
        else if (_attack_dir == "down")
        {
            _desired_name =
                (
                    _left
                    ?
                    "spr_maya_ataque_platform_abajo_izquierda"
                    :
                    "spr_maya_ataque_platform_abajo_derecha"
                );
        }
        else
        {
            _desired_name =
                (
                    _left
                    ?
                    "spr_maya_ataque_platform_izquierda"
                    :
                    "spr_maya_ataque_platform_derecha"
                );
        }
    }


    // =====================================================
    // SENTÓN
    // =====================================================

    else if (
        variable_instance_exists(
            id,
            "platform_stomp_active"
        )
        &&
        platform_stomp_active
    )
    {
        _desired_name =
            (
                _left
                ?
                "spr_maya_platform_senton_izquierda"
                :
                "spr_maya_platform_senton_derecha"
            );
    }


    // =====================================================
    // SALTO / CAÍDA
    // =====================================================
    //
    // frame 0 = subiendo
    // frame 1 = cayendo
    // =====================================================

    else if (
        variable_instance_exists(
            id,
            "platform_grounded"
        )
        &&
        !platform_grounded
    )
    {
        _desired_name =
            (
                _left
                ?
                "spr_maya_platform_salto_izquierda"
                :
                "spr_maya_platform_salto_derecha"
            );


        var _vsp =
            (
                variable_instance_exists(
                    id,
                    "platform_vsp"
                )
                ?
                platform_vsp
                :
                0
            );


        _force_frame =
            (
                _vsp < 0
                ?
                0
                :
                1
            );
    }


    // =====================================================
    // TARGET EN PLATAFORMA
    // =====================================================

    else if (_target_active)
    {
        switch (facing_direction)
        {
            case 0:
                _desired_name =
                    "spr_maya_target_platform_derecha";
                break;

            case 1:
                _desired_name =
                    "spr_maya_target_platform_izquierda";
                break;

            case 2:
                _desired_name =
                    "spr_maya_target_platform_abajo";
                break;

            case 3:
                _desired_name =
                    "spr_maya_target_platform_arriba";
                break;

            default:
                _desired_name =
                    (
                        _left
                        ?
                        "spr_maya_target_platform_izquierda"
                        :
                        "spr_maya_target_platform_derecha"
                    );
                break;
        }
    }


    // =====================================================
    // RUN
    // =====================================================

    else if (
        variable_instance_exists(
            id,
            "platform_hsp"
        )
        &&
        abs(platform_hsp)
        >
        0.20
    )
    {
        _desired_name =
            (
                _left
                ?
                "spr_maya_platform_run_izquierda"
                :
                "spr_maya_platform_run_derecha"
            );
    }


    // =====================================================
    // IDLE
    // =====================================================

    else
    {
        _desired_name =
            (
                _left
                ?
                "spr_maya_platform_idle_izquierda"
                :
                "spr_maya_platform_idle_derecha"
            );
    }
}


// =========================================================
// MODO RPG / NORMAL
// =========================================================

else if (!_cutscene_locked)
{
    // =====================================================
    // DESLIZAMIENTO
    // =====================================================

    if (
        variable_instance_exists(
            id,
            "downslide_active"
        )
        &&
        downslide_active
    )
    {
        _desired_name =
            "spr_maya_deslizamiento";
    }


    // =====================================================
    // AGACHADA / SIGILO
    // =====================================================

    else if (
        variable_instance_exists(
            id,
            "sigilo_activo"
        )
        &&
        sigilo_activo
    )
    {
        _crouch_visual =
            true;


        switch (facing_direction)
        {
            case 0:
                _desired_name =
                    "spr_maya_agachada_derecha";
                break;

            case 1:
                _desired_name =
                    "spr_maya_agachada_izquierda";
                break;

            case 2:
                _desired_name =
                    "spr_maya_agachada_abajo";
                break;

            case 3:
                _desired_name =
                    "spr_maya_agachada_arriba";
                break;
        }
    }


    // =====================================================
    // TARGET NORMAL
    // =====================================================

    else if (_target_active)
    {
        switch (facing_direction)
        {
            case 0:
                _desired_name =
                    "spr_maya_target_derecha";
                break;

            case 1:
                _desired_name =
                    "spr_maya_target_izquierda";
                break;

            case 2:
                _desired_name =
                    "spr_maya_target_abajo";
                break;

            case 3:
                _desired_name =
                    "spr_maya_target_arriba";
                break;
        }
    }


    // =====================================================
    // SPRITES BASE NUEVOS
    // =====================================================

    else
    {
        switch (facing_direction)
        {
            case 0:
                _desired_name =
                    "spr_maya_derecha";
                break;

            case 1:
                _desired_name =
                    "spr_maya_izquierda";
                break;

            case 2:
                _desired_name =
                    "spr_maya_abajo";
                break;

            case 3:
                _desired_name =
                    "spr_maya_arriba";
                break;
        }
    }
}


// =========================================================
// RESOLVER SPRITE CON FALLBACK SEGURO
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
// VALIDAR SPRITE
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


// =========================================================
// SALTO: FRAME FIJO SEGÚN DIRECCIÓN VERTICAL
// =========================================================

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
// ANIMACIÓN MANUAL DE SPRITES DE PLATAFORMA
// =========================================================
//
// El sprite visual puede ser distinto de sprite_index.
// Por eso image_index del objeto no basta para animarlo.
//
// Se usa la velocidad configurada en el sprite.
// Si esa velocidad es 0, fallback = 6 FPS.
// =========================================================

else if (_platformer)
{
    if (
        !variable_instance_exists(
            id,
            "maya_platform_visual_anim_sprite"
        )
    )
    {
        maya_platform_visual_anim_sprite =
            -1;

        maya_platform_visual_anim_frame =
            0;

        maya_platform_visual_anim_accum =
            0;
    }


    if (
        maya_platform_visual_anim_sprite
        !=
        _draw_sprite
    )
    {
        maya_platform_visual_anim_sprite =
            _draw_sprite;

        maya_platform_visual_anim_frame =
            0;

        maya_platform_visual_anim_accum =
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


    maya_platform_visual_anim_accum +=
        _anim_fps
        *
        _dt_seconds;


    while (
        maya_platform_visual_anim_accum
        >=
        1
    )
    {
        maya_platform_visual_anim_accum -=
            1;


        maya_platform_visual_anim_frame =
            (
                maya_platform_visual_anim_frame
                +
                1
            )
            mod
            _frame_count;
    }


    _draw_frame =
        clamp(
            maya_platform_visual_anim_frame,
            0,
            _frame_count - 1
        );
}


// =========================================================
// RPG: CONSERVAR image_index NORMAL
// =========================================================

else
{
    if (
        variable_instance_exists(
            id,
            "maya_platform_visual_anim_sprite"
        )
    )
    {
        maya_platform_visual_anim_sprite =
            -1;

        maya_platform_visual_anim_frame =
            0;

        maya_platform_visual_anim_accum =
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
// ANCLAR EL CRECIMIENTO A LOS PIES
// =========================================================
//
// draw_sprite_ext escala alrededor del origen del sprite.
// Para que el crecimiento NO empuje los pies hacia abajo,
// compensamos exactamente la diferencia de escala usando la
// parte inferior real del bounding box.
//
// Resultado:
//     el punto de los pies queda donde estaba sin escalar;
//     todo el crecimiento extra se dirige hacia arriba.
// =========================================================

var _foot_local_y =
    sprite_get_bbox_bottom(
        _draw_sprite
    )
    -
    sprite_get_yoffset(
        _draw_sprite
    );


var _draw_x =
    x;


var _draw_y =
    y
    +
    (
        _foot_local_y
        *
        image_yscale
        *
        (
            1
            -
            _maya_scale
        )
    );


// =========================================================
// AGACHADA: 15 PX MÁS ABAJO
// =========================================================

if (_crouch_visual)
{
    _draw_y +=
        15;
}


// =========================================================
// GUARDAR VISUAL FINAL PARA EL EFECTO ROJO
// =========================================================

maya_visual_valid =
    true;


maya_visual_sprite =
    _draw_sprite;


maya_visual_frame =
    _draw_frame;


maya_visual_world_x =
    _draw_x;


maya_visual_world_y =
    _draw_y;


maya_visual_xscale =
    _draw_xscale;


maya_visual_yscale =
    _draw_yscale;


maya_visual_angle =
    image_angle;


maya_visual_blend =
    image_blend;


maya_visual_alpha =
    image_alpha;


// =========================================================
// DIBUJAR
// =========================================================

draw_sprite_ext(
    _draw_sprite,
    _draw_frame,
    _draw_x,
    _draw_y,
    _draw_xscale,
    _draw_yscale,
    image_angle,
    image_blend,
    image_alpha
);
