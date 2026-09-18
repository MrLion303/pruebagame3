/// =========================================================
/// OBJ_PLATFORMER_DASH_VISUAL
/// STEP - NUEVO
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
// AFTERIMAGE - MISMO EFECTO DEL DASH DEL MAPA RPG
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
    var _ghost =
        instance_create_depth(
            owner_ref.x,
            owner_ref.y,
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
            abs(
                owner_ref.platform_saved_image_xscale
            );


        _ghost.ghost_yscale =
            owner_ref.platform_saved_image_yscale;


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
