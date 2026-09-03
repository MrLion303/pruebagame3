/// =========================================================
/// SCR_UI_BOX_ANIM
/// =========================================================
///
/// Devuelve el frame que debe dibujarse para cualquier
/// sprite de cuadro / textbox.
///
/// - 1 frame  -> siempre frame 0.
/// - 2+ frames -> reproduce la animación en bucle.
///
/// Respeta la velocidad configurada en el Sprite Editor.
/// Si el sprite tiene velocidad 0, usa 8 FPS como fallback.
/// =========================================================

function scr_ui_box_frame(_sprite)
{
    if (
        _sprite == noone
        ||
        _sprite == -1
        ||
        !sprite_exists(_sprite)
    )
    {
        return 0;
    }


    var _frames =
        sprite_get_number(_sprite);


    if (_frames <= 1)
    {
        return 0;
    }


    var _speed =
        sprite_get_speed(_sprite);


    if (_speed <= 0)
    {
        _speed = 8;
    }
    else
    {
        var _speed_type =
            sprite_get_speed_type(_sprite);


        if (
            _speed_type
            ==
            spritespeed_framespergameframe
        )
        {
            _speed *=
                game_get_speed(
                    gamespeed_fps
                );
        }
    }


    var _frame =
        floor(
            (current_time / 1000)
            *
            _speed
        )
        mod
        _frames;


    return clamp(
        _frame,
        0,
        _frames - 1
    );
}
