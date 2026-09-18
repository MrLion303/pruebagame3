/// =========================================================
/// OBJ_PLATFORMER_DASH_VISUAL
/// STEP COMPLETO
/// =========================================================
///
/// ARREGLO:
///
/// El afterimage del Dash usa ahora EXACTAMENTE la misma
/// escala visual de Maya:
///
///     39 / 28 = 1.392857... = 139.29%
///
/// Además, cada copia fantasma se ancla al mismo pie físico
/// del modo plataforma que el sprite principal de Maya.
/// =========================================================


if (
    owner_ref == noone
    ||
    !instance_exists(
        owner_ref
    )
)
{
    instance_destroy();
    exit;
}


if (
    !variable_instance_exists(
        owner_ref,
        "platform_dash_active"
    )
    ||
    !owner_ref.platform_dash_active
)
{
    instance_destroy();
    exit;
}


x =
    owner_ref.x;


y =
    owner_ref.y;


// Dibujar por delante del sprite oculto de Maya.
depth =
    owner_ref.depth
    -
    100;


visual_frame +=
    visual_speed;


// =========================================================
// AFTERIMAGE
// =========================================================

var _left =
    owner_ref.platform_dash_dir
    <
    0;


var _jump_fallback =
    scr_platformer_ext_sprite(
        (
            _left
            ?
            "spr_maya_platform_salto_izquierda"
            :
            "spr_maya_platform_salto_derecha"
        ),
        scr_platformer_ext_sprite(
            "spr_maya_platform_salto",
            (
                _left
                ?
                spr_maya_izquierda
                :
                spr_maya_derecha
            )
        )
    );


var _dash_sprite =
    scr_platformer_ext_sprite(
        (
            _left
            ?
            "spr_maya_platform_dash_izquierda"
            :
            "spr_maya_platform_dash_derecha"
        ),
        _jump_fallback
    );


if (
    _dash_sprite != -1
    &&
    sprite_exists(
        _dash_sprite
    )
)
{
    // =====================================================
    // ESCALA VISUAL DE MAYA
    // =====================================================

    var _maya_scale =
        39
        /
        28;


    var _base_xscale =
        1;


    var _base_yscale =
        1;


    if (
        variable_instance_exists(
            owner_ref,
            "platform_saved_image_xscale"
        )
    )
    {
        _base_xscale =
            abs(
                owner_ref.platform_saved_image_xscale
            );
    }
    else
    {
        _base_xscale =
            abs(
                owner_ref.image_xscale
            );
    }


    if (
        variable_instance_exists(
            owner_ref,
            "platform_saved_image_yscale"
        )
    )
    {
        _base_yscale =
            owner_ref.platform_saved_image_yscale;
    }
    else
    {
        _base_yscale =
            owner_ref.image_yscale;
    }


    var _ghost_xscale =
        _base_xscale
        *
        _maya_scale;


    var _ghost_yscale =
        _base_yscale
        *
        _maya_scale;


    // =====================================================
    // MISMO ANCLAJE DE PIES QUE EL DASH PRINCIPAL
    // =====================================================

    var _foot_local_y =
        sprite_get_bbox_bottom(
            _dash_sprite
        )
        -
        sprite_get_yoffset(
            _dash_sprite
        );


    var _ghost_x =
        owner_ref.x;


    var _ghost_y =
        owner_ref.y;


    if (
        variable_instance_exists(
            owner_ref,
            "platform_hit_bottom"
        )
    )
    {
        var _platform_foot_world_y =
            owner_ref.y
            +
            owner_ref.platform_hit_bottom;


        _ghost_y =
            _platform_foot_world_y
            -
            (
                _foot_local_y
                *
                _ghost_yscale
            );
    }
    else
    {
        _ghost_y =
            owner_ref.y
            +
            (
                _foot_local_y
                *
                _base_yscale
                *
                (
                    1
                    -
                    _maya_scale
                )
            );
    }


    var _ghost =
        instance_create_depth(
            _ghost_x,
            _ghost_y,
            owner_ref.depth + 1,
            obj_dash_afterimage
        );


    if (_ghost != noone)
    {
        var _frame_count =
            max(
                1,
                sprite_get_number(
                    _dash_sprite
                )
            );


        _ghost.ghost_sprite =
            _dash_sprite;


        _ghost.ghost_frame =
            floor(
                visual_frame
            )
            mod
            _frame_count;


        _ghost.ghost_xscale =
            _ghost_xscale;


        _ghost.ghost_yscale =
            _ghost_yscale;


        // Este sistema ya calculó y aplicó 39/28, por lo que
        // obj_dash_afterimage no debe multiplicarlo otra vez.
        _ghost.ghost_already_maya_scaled =
            true;


        _ghost.ghost_angle =
            0;


        _ghost.ghost_blend =
            c_white;


        _ghost.ghost_dir_x =
            owner_ref.platform_dash_dir;


        _ghost.ghost_dir_y =
            0;
    }
}
