/// =========================================================
/// OBJ_PLATFORMER_ATTACK_FX
/// DRAW
/// =========================================================
///
/// Soporta ataque:
///
///     horizontal
///     arriba
///     abajo
///
/// Si existe spr_platformer_ataque, reutiliza ese mismo
/// sprite rotándolo.
///
/// Si no existe, dibuja un slash provisional.
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


var _dir =
    (
        variable_instance_exists(
            id,
            "attack_direction"
        )
        ?
        attack_direction
        :
        "horizontal"
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


var _draw_x =
    _cx;


var _draw_y =
    _cy;


var _angle =
    0;


var _scale_x =
    1;


if (_dir == "up")
{
    _draw_y =
        _cy - 28;


    _angle =
        90;
}
else if (_dir == "down")
{
    _draw_y =
        _cy + 28;


    _angle =
        -90;
}
else
{
    _draw_x =
        _cx
        +
        (
            facing
            *
            24
        );


    _scale_x =
        (
            facing < 0
            ?
            -1
            :
            1
        );
}


if (
    _slash != -1
    &&
    sprite_exists(_slash)
)
{
    draw_sprite_ext(
        _slash,
        0,
        _draw_x,
        _draw_y,
        _scale_x,
        1,
        _angle,
        c_white,
        _alpha
    );
}
else
{
    draw_set_alpha(
        _alpha
    );


    draw_set_color(
        c_white
    );


    // =====================================================
    // ARRIBA
    // =====================================================

    if (_dir == "up")
    {
        draw_line_width(
            _cx - 13,
            _cy - 10,
            _cx,
            _cy - 34,
            3
        );


        draw_line_width(
            _cx + 13,
            _cy - 10,
            _cx,
            _cy - 34,
            3
        );
    }

    // =====================================================
    // ABAJO
    // =====================================================

    else if (_dir == "down")
    {
        draw_line_width(
            _cx - 13,
            _cy + 10,
            _cx,
            _cy + 34,
            3
        );


        draw_line_width(
            _cx + 13,
            _cy + 10,
            _cx,
            _cy + 34,
            3
        );
    }

    // =====================================================
    // HORIZONTAL
    // =====================================================

    else
    {
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
    }


    draw_set_alpha(
        1
    );
}
