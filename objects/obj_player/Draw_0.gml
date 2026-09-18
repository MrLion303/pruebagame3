/// =========================================================
/// OBJ_PLAYER
/// DRAW COMPLETO
/// =========================================================
///
/// SISTEMA VISUAL MAYA
///
/// - Usa los nuevos nombres spr_maya_*.
/// - Conserva el sprite actual si el sprite nuevo no existe.
/// - Escala visual de Maya: 37 / 28 = 1.321428571...
/// - Soporta target, sigilo/agachada, deslizamiento.
/// - Soporta todos los estados visuales de plataforma.
/// - El salto usa frame 0 subiendo y frame 1 cayendo.
/// - El Dash plataformero lo dibuja obj_platformer_dash_visual.
/// - Las cinemáticas conservan su sprite propio.
/// =========================================================


// =========================================================
// BBS - NO DIBUJAR AL PLAYER DEL MAPA
// =========================================================

if (room == bbs)
{
    exit;
}


// =========================================================
// ESCALA VISUAL UNIVERSAL DE MAYA
// =========================================================

var _maya_scale =
    37
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
//
// obj_mapa_combate_fx.danger_active se activa cuando al menos
// un enemigo del mapa tiene a Maya dentro de su rango real
// de ataque.
//
// De esta forma TARGET usa exactamente el mismo estado de
// peligro que ya usa el resto del proyecto.
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
//
// IMPORTANTE:
//
// Nunca sustituimos el sprite actual por -1.
// Si el recurso solicitado no existe, se conserva visualmente
// sprite_index tal como estaba antes.
// =========================================================

var _desired_name =
    "";


var _force_frame =
    -1;


var _freeze_visual =
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
    // Durante el Dash el propio sistema vuelve transparente
    // a Maya y obj_platformer_dash_visual dibuja la pose.
    // Aquí no la duplicamos.
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
    //
    // También funciona al simplemente caer desde una cornisa,
    // porque depende de platform_vsp, no de haber saltado.
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


        _freeze_visual =
            true;
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
    // CORRER
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
    // AGACHADA / SIGILO CON S
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
    //
    // Sustituyen visualmente:
    //
    // pendejo_arriba    -> spr_maya_arriba
    // pendejo_derecha   -> spr_maya_derecha
    // pendejo_abajo     -> spr_maya_abajo
    // pendejo_izquierda -> spr_maya_izquierda
    //
    // Los antiguos pueden seguir existiendo como fallback
    // interno del código actual. Ya no se dibujan si el nuevo
    // recurso correspondiente existe.
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
// VALIDAR SPRITE ACTUAL
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


if (_force_frame >= 0)
{
    _draw_frame =
        clamp(
            _force_frame,
            0,
            _frame_count - 1
        );
}
else
{
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
    _draw_xscale,
    _draw_yscale,
    image_angle,
    image_blend,
    image_alpha
);
