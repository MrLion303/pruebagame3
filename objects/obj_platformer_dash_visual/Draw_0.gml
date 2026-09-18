/// =========================================================
/// OBJ_PLATFORMER_DASH_VISUAL
/// DRAW COMPLETO
/// =========================================================
///
/// SPRITES ESPERADOS:
///
///     spr_maya_platform_dash_izquierda
///     spr_maya_platform_dash_derecha
///
/// Si el sprite de Dash no existe, se conserva visualmente el
/// sprite que Maya ya tenía antes del Dash.
///
/// Maya se dibuja a escala:
///
///     37 / 28 = 1.321428571...
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


var _desired_name =
    (
        _left
        ?
        "spr_maya_platform_dash_izquierda"
        :
        "spr_maya_platform_dash_derecha"
    );


var _spr =
    asset_get_index(
        _desired_name
    );


// =========================================================
// FALLBACK: SPRITE ACTUAL DE MAYA
// =========================================================

if (
    _spr == -1
    ||
    !sprite_exists(
        _spr
    )
)
{
    _spr =
        owner_ref.sprite_index;
}


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


// =========================================================
// FRAME
// =========================================================

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


if (_frame < 0)
{
    _frame +=
        _frames;
}


// =========================================================
// ESCALA MAYA
// =========================================================

var _maya_scale =
    37
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
        owner_ref.platform_saved_image_xscale;
}
else
{
    _base_xscale =
        owner_ref.image_xscale;
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


// Sprites separados para izquierda/derecha:
// no hacemos mirror horizontal.
_base_xscale =
    abs(
        _base_xscale
    );


draw_sprite_ext(
    _spr,
    _frame,
    owner_ref.x,
    owner_ref.y,
    _base_xscale * _maya_scale,
    _base_yscale * _maya_scale,
    0,
    c_white,
    1
);
