/// =========================================================
/// OBJ_TIJERAS_JARDIN_PICKUP
/// STEP
/// =========================================================


if (!instance_exists(obj_player))
{
    exit;
}


// No recoger durante diálogos, pausa o cinemáticas.
if (
    instance_exists(obj_textbox)
    ||
    instance_exists(obj_pauser)
    ||
    (
        variable_global_exists(
            "cutscene_active"
        )
        &&
        global.cutscene_active
    )
)
{
    exit;
}


var _player =
    instance_find(
        obj_player,
        0
    );


if (
    _player == noone
    ||
    !instance_exists(_player)
)
{
    exit;
}


var _close_enough =
    point_distance(
        x,
        y,
        _player.x,
        _player.y
    )
    <=
    30;


var _confirm =
    keyboard_check_pressed(ord("Z"))
    ||
    keyboard_check_pressed(vk_enter);


if (
    !_close_enough
    ||
    !_confirm
)
{
    exit;
}


// Ya existe: simplemente retirar el pickup duplicado.
if (
    scr_itemclave_tiene(
        "tijeras_jardin"
    )
)
{
    scr_tijeras_pickup_mark_taken(
        id
    );

    instance_destroy();
    exit;
}


if (
    scr_itemclave_dar(
        "tijeras_jardin"
    )
)
{
    scr_tijeras_pickup_mark_taken(
        id
    );


    keyboard_clear(
        ord("Z")
    );

    keyboard_clear(
        vk_enter
    );


    audio_play_sound(
        snd_shineselect,
        10,
        false
    );


    var _textbox =
        instance_create_layer(
            x,
            y,
            layer,
            obj_textbox
        );


    _textbox.text =
    [
        scr_loc(
            scr_loc_src(
                "* Obtuviste Tijeras Jardín."
            )
        )
    ];

    _textbox.page_number =
        array_length(
            _textbox.text
        );


    instance_destroy();
}
else
{
    if (audio_is_playing(snd_error))
    {
        audio_stop_sound(
            snd_error
        );
    }


    audio_play_sound(
        snd_error,
        10,
        false
    );
}
