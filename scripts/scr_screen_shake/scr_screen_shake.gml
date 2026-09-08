/// =========================================================
/// SCR_SCREEN_SHAKE
/// =========================================================
///
/// Screen shake universal.
///
/// MAPA:
///     mueve la cámara DESPUÉS de su seguimiento automático.
///
/// BBS:
///     obj_screen_shake traslada temporalmente Draw GUI.
///
/// USO:
///
///     scr_screen_shake_start(3, 8);
///
/// fuerza:
///     píxeles de CÁMARA.
///
/// frames:
///     duración.
/// =========================================================


function scr_screen_shake_init()
{
    if (
        !variable_global_exists(
            "screen_shake_timer"
        )
    )
    {
        global.screen_shake_timer =
            0;
    }


    if (
        !variable_global_exists(
            "screen_shake_duration"
        )
    )
    {
        global.screen_shake_duration =
            1;
    }


    if (
        !variable_global_exists(
            "screen_shake_strength"
        )
    )
    {
        global.screen_shake_strength =
            0;
    }


    if (
        !variable_global_exists(
            "screen_shake_x"
        )
    )
    {
        global.screen_shake_x =
            0;
    }


    if (
        !variable_global_exists(
            "screen_shake_y"
        )
    )
    {
        global.screen_shake_y =
            0;
    }
}


// =========================================================
// INICIAR / REFRESCAR
// =========================================================

function scr_screen_shake_start(
    _strength = 3,
    _frames = 8
)
{
    scr_screen_shake_init();


    _strength =
        max(
            0,
            _strength
        );


    _frames =
        max(
            1,
            round(
                _frames
            )
        );


    global.screen_shake_strength =
        max(
            global.screen_shake_strength,
            _strength
        );


    global.screen_shake_duration =
        max(
            global.screen_shake_duration,
            _frames
        );


    global.screen_shake_timer =
        max(
            global.screen_shake_timer,
            _frames
        );


    // Offset inmediato.
    //
    // Si el golpe ocurre antes de dibujar este mismo frame,
    // la cámara/GUI ya podrá reaccionar sin esperar un Step.
    global.screen_shake_x =
        round(
            _strength
        );


    global.screen_shake_y =
        -round(
            _strength
            *
            0.5
        );
}


// =========================================================
// BEGIN SCRIPT DE LA CÁMARA
// =========================================================
//
// GameMaker actualiza primero el seguimiento automático de
// la cámara y DESPUÉS llama este begin script.
//
// Por eso podemos sumar el shake aquí sin que el seguimiento
// de obj_player lo sobrescriba antes de dibujar.
//
// En BBS no desplazamos la cámara:
// la batalla se sacude desde Draw GUI Begin.
/// =========================================================

function scr_screen_shake_camera_begin()
{
    scr_screen_shake_init();


    if (
        room == bbs
        ||
        room == game_over
    )
    {
        return;
    }


    if (
        global.screen_shake_x == 0
        &&
        global.screen_shake_y == 0
    )
    {
        return;
    }


    var _cam =
        view_camera[0];


    if (_cam == -1)
    {
        return;
    }


    var _base_x =
        camera_get_view_x(
            _cam
        );


    var _base_y =
        camera_get_view_y(
            _cam
        );


    var _view_w =
        camera_get_view_width(
            _cam
        );


    var _view_h =
        camera_get_view_height(
            _cam
        );


    var _max_x =
        max(
            0,
            room_width
            -
            _view_w
        );


    var _max_y =
        max(
            0,
            room_height
            -
            _view_h
        );


    camera_set_view_pos(
        _cam,

        clamp(
            _base_x
            +
            global.screen_shake_x,
            0,
            _max_x
        ),

        clamp(
            _base_y
            +
            global.screen_shake_y,
            0,
            _max_y
        )
    );
}
