/// =========================================================
/// OBJ_DASH_AFTERIMAGE
/// DRAW COMPLETO
/// =========================================================
///
/// Copia principal + dos ecos débiles hacia atrás.
///
/// Todos los afterimages de Maya usan la misma escala:
///
///     39 / 28 = 139.29%
///
/// excepto cuando el creador ya entregó esa escala final.
/// =========================================================

if (
    ghost_sprite == -1
    ||
    !sprite_exists(
        ghost_sprite
    )
)
{
    exit;
}


var _draw_xscale =
    ghost_xscale;


var _draw_yscale =
    ghost_yscale;


var _draw_y =
    y;


if (!ghost_already_maya_scaled)
{
    var _maya_scale =
        39
        /
        28;


    _draw_xscale *=
        _maya_scale;


    _draw_yscale *=
        _maya_scale;


    // Crecer desde los pies también en el Dash RPG.
    var _foot_local_y =
        sprite_get_bbox_bottom(
            ghost_sprite
        )
        -
        sprite_get_yoffset(
            ghost_sprite
        );


    _draw_y +=
        _foot_local_y
        *
        ghost_yscale
        *
        (
            1
            -
            _maya_scale
        );
}


var _back_x =
    -ghost_dir_x;


var _back_y =
    -ghost_dir_y;


// Eco lejano.
draw_sprite_ext(
    ghost_sprite,
    ghost_frame,
    x + (_back_x * 5),
    _draw_y + (_back_y * 5),
    _draw_xscale,
    _draw_yscale,
    ghost_angle,
    ghost_blend,
    ghost_alpha * 0.12
);


// Eco medio.
draw_sprite_ext(
    ghost_sprite,
    ghost_frame,
    x + (_back_x * 2),
    _draw_y + (_back_y * 2),
    _draw_xscale,
    _draw_yscale,
    ghost_angle,
    ghost_blend,
    ghost_alpha * 0.28
);


// Copia principal.
draw_sprite_ext(
    ghost_sprite,
    ghost_frame,
    x,
    _draw_y,
    _draw_xscale,
    _draw_yscale,
    ghost_angle,
    ghost_blend,
    ghost_alpha
);
