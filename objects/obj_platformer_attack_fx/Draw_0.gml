/// =========================================================
/// OBJ_PLATFORMER_ATTACK_FX
/// DRAW
/// =========================================================
///
/// Si existe:
///
///     spr_platformer_ataque
///
/// se utiliza como slash.
///
/// Si todavía no existe, dibuja un efecto simple provisional.
/// =========================================================

if (
    owner == noone
    ||
    !instance_exists(owner)
)
{
    exit;
}


var _alpha =
    clamp(
        life
        /
        max(
            1,
            life_max
        ),
        0,
        1
    );


var _slash =
    asset_get_index(
        "spr_platformer_ataque"
    );


var _cx =
    (
        owner.bbox_left
        +
        owner.bbox_right
    )
    *
    0.5;


var _cy =
    (
        owner.bbox_top
        +
        owner.bbox_bottom
    )
    *
    0.5;


if (
    _slash != -1
    &&
    sprite_exists(_slash)
)
{
    draw_sprite_ext(
        _slash,
        0,
        _cx
        +
        (
            facing
            *
            24
        ),
        _cy,
        (
            facing < 0
            ?
            -1
            :
            1
        ),
        1,
        0,
        c_white,
        _alpha
    );
}
else
{
    // Slash provisional.
    draw_set_alpha(
        _alpha
    );


    draw_set_color(
        c_white
    );


    var _x1 =
        _cx
        +
        (
            facing
            *
            10
        );


    var _x2 =
        _cx
        +
        (
            facing
            *
            34
        );


    draw_line_width(
        _x1,
        _cy - 13,
        _x2,
        _cy,
        3
    );


    draw_line_width(
        _x1,
        _cy + 13,
        _x2,
        _cy,
        3
    );


    draw_set_alpha(
        1
    );
}
