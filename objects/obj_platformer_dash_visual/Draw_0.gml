/// =========================================================
/// OBJ_PLATFORMER_DASH_VISUAL
/// DRAW COMPLETO
/// =========================================================
///
/// - Maya usa 39/28 = 139.29% de escala visual.
/// - El crecimiento queda anclado a los pies.
/// - El sprite visual final se comunica al FX rojo.
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


// Sprites izquierda/derecha separados:
// nunca hacemos mirror automático.
_base_xscale =
    abs(
        _base_xscale
    );


var _draw_xscale =
    _base_xscale
    *
    _maya_scale;


var _draw_yscale =
    _base_yscale
    *
    _maya_scale;


// =========================================================
// ANCLAR AL PIE FÍSICO DEL PLATAFORMERO
// =========================================================
//
// Igual que obj_player Draw:
// el pie visual del Dash debe coincidir con:
//
//     owner_ref.y + owner_ref.platform_hit_bottom
//
// y NO con el bbox normal del obj_player.
// =========================================================

var _foot_local_y =
    sprite_get_bbox_bottom(
        _spr
    )
    -
    sprite_get_yoffset(
        _spr
    );


var _draw_x =
    owner_ref.x;


var _draw_y =
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


    _draw_y =
        _platform_foot_world_y
        -
        (
            _foot_local_y
            *
            _draw_yscale
        );
}
else
{
    // Fallback seguro si por cualquier razón el estado
    // plataformero todavía no terminó de inicializarse.
    _draw_y =
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


// =========================================================
// CACHÉ PARA EL EFECTO ROJO
// =========================================================

owner_ref.maya_visual_valid =
    true;


owner_ref.maya_visual_sprite =
    _spr;


owner_ref.maya_visual_frame =
    _frame;


owner_ref.maya_visual_world_x =
    _draw_x;


owner_ref.maya_visual_world_y =
    _draw_y;


owner_ref.maya_visual_xscale =
    _draw_xscale;


owner_ref.maya_visual_yscale =
    _draw_yscale;


owner_ref.maya_visual_angle =
    0;


owner_ref.maya_visual_blend =
    c_white;


owner_ref.maya_visual_alpha =
    1;


// =========================================================
// DIBUJAR
// =========================================================

draw_sprite_ext(
    _spr,
    _frame,
    _draw_x,
    _draw_y,
    _draw_xscale,
    _draw_yscale,
    0,
    c_white,
    1
);
