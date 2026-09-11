/// =========================================================
/// OBJ_DASH_AFTERIMAGE
/// DRAW - NUEVO
/// =========================================================
///
/// Copia principal + dos ecos débiles hacia atrás.
/// Funciona también en diagonal.
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


var _back_x =
    -ghost_dir_x;

var _back_y =
    -ghost_dir_y;


// Eco lejano.
draw_sprite_ext(
    ghost_sprite,
    ghost_frame,
    x + (_back_x * 5),
    y + (_back_y * 5),
    ghost_xscale,
    ghost_yscale,
    ghost_angle,
    ghost_blend,
    ghost_alpha * 0.12
);


// Eco medio.
draw_sprite_ext(
    ghost_sprite,
    ghost_frame,
    x + (_back_x * 2),
    y + (_back_y * 2),
    ghost_xscale,
    ghost_yscale,
    ghost_angle,
    ghost_blend,
    ghost_alpha * 0.28
);


// Copia principal.
draw_sprite_ext(
    ghost_sprite,
    ghost_frame,
    x,
    y,
    ghost_xscale,
    ghost_yscale,
    ghost_angle,
    ghost_blend,
    ghost_alpha
);
