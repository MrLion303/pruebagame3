/// =========================================================
/// OBJ_PLAYER
/// DRAW - NUEVO
/// =========================================================
///
/// Parent:
///     no aplica; es evento del obj_player existente.
///
/// Solo cambia el DIBUJO del salto plataformero.
/// El sprite_index real sigue gestionado por el sistema actual.
/// =========================================================

var _drawn =
    false;


if (
    variable_global_exists(
        "platformer_active"
    )
    &&
    global.platformer_active
    &&
    variable_instance_exists(
        id,
        "platform_grounded"
    )
    &&
    !platform_grounded
    &&
    !platform_stomp_active
    &&
    (
        !variable_instance_exists(
            id,
            "platform_dash_active"
        )
        ||
        !platform_dash_active
    )
)
{
    var _jump_left =
        platform_facing
        <
        0;


    var _jump_sprite =
        asset_get_index(
            (
                _jump_left
                ?
                "spr_maya_platform_salto_izquierda"
                :
                "spr_maya_platform_salto_derecha"
            )
        );


    if (
        _jump_sprite != -1
        &&
        sprite_exists(
            _jump_sprite
        )
    )
    {
        var _frames =
            max(
                1,
                sprite_get_number(
                    _jump_sprite
                )
            );


        var _frame =
            floor(
                image_index
            )
            mod
            _frames;


        draw_sprite_ext(
            _jump_sprite,
            _frame,
            x,
            y,
            image_xscale,
            image_yscale,
            image_angle,
            image_blend,
            image_alpha
        );


        _drawn =
            true;
    }
}


if (!_drawn)
{
    draw_self();
}
