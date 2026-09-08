/// =========================================================
/// OBJ_SCREEN_SHAKE
/// DRAW GUI BEGIN
/// =========================================================
///
/// En BBS casi todo se dibuja en Draw GUI.
///
/// La cámara no puede mover esos elementos, así que
/// trasladamos temporalmente la matriz de Draw GUI.
/// =========================================================

gui_shake_active =
    false;


if (room != bbs)
{
    exit;
}


scr_screen_shake_init();


if (
    global.screen_shake_x == 0
    &&
    global.screen_shake_y == 0
)
{
    exit;
}


var _gui_scale_x =
    1;


var _gui_scale_y =
    1;


var _cam =
    view_camera[0];


if (_cam != -1)
{
    var _view_w =
        camera_get_view_width(
            _cam
        );


    var _view_h =
        camera_get_view_height(
            _cam
        );


    if (_view_w > 0)
    {
        _gui_scale_x =
            display_get_gui_width()
            /
            _view_w;
    }


    if (_view_h > 0)
    {
        _gui_scale_y =
            display_get_gui_height()
            /
            _view_h;
    }
}


// Guardar la matriz que existía antes de nuestro efecto.
gui_matrix_previous =
    matrix_get(
        matrix_world
    );


var _translation =
    matrix_build(
        global.screen_shake_x
        *
        _gui_scale_x,

        global.screen_shake_y
        *
        _gui_scale_y,

        0,

        0,
        0,
        0,

        1,
        1,
        1
    );


// Aplicar primero la matriz previa y luego el desplazamiento.
var _combined =
    matrix_multiply(
        gui_matrix_previous,
        _translation
    );


matrix_set(
    matrix_world,
    _combined
);


gui_shake_active =
    true;
