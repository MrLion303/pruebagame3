/// =========================================================
/// OBJ_PLATFORMER_DASH_VISUAL
/// DRAW - NUEVO
/// =========================================================
///
/// SPRITES ESPERADOS:
///
///     spr_maya_platform_dash_izquierda
///     spr_maya_platform_dash_derecha
///
/// Si todavía no existen, usa salto/lateral como fallback.
/// =========================================================

if (
    owner_ref == noone
    ||
    !instance_exists(
        owner_ref
    )
)
{
    exit;
}


var _left =
    owner_ref.platform_dash_dir
    <
    0;


var _fallback =
    scr_platformer_ext_sprite(
        "spr_maya_platform_salto",
        (
            _left
            ?
            pendejo_izquierda
            :
            pendejo_derecha
        )
    );


var _spr =
    scr_platformer_ext_sprite(
        (
            _left
            ?
            "spr_maya_platform_dash_izquierda"
            :
            "spr_maya_platform_dash_derecha"
        ),
        _fallback
    );


if (
    _spr == -1
    ||
    !sprite_exists(
        _spr
    )
)
{
    exit;
}


var _frames =
    max(
        1,
        sprite_get_number(
            _spr
        )
    );


var _frame =
    floor(
        visual_frame
    )
    mod
    _frames;


draw_sprite_ext(
    _spr,
    _frame,
    owner_ref.x,
    owner_ref.y,
    abs(
        owner_ref.platform_saved_image_xscale
    ),
    owner_ref.platform_saved_image_yscale,
    0,
    c_white,
    1
);
