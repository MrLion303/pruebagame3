/// =========================================================
/// OBJ_TEXTBOX
/// END STEP
/// =========================================================
//
// PLAYER ABAJO  -> cuadro arriba.
// PLAYER ARRIBA -> cuadro abajo.
//
// Se calcula usando la posición REAL dentro de la cámara,
// así que también funciona si la cámara se movió en cinemática.
//
// No se aplica en bbs porque la batalla tiene su propia UI.
// =========================================================

if (
    room != bbs
    &&
    instance_exists(obj_player)
)
{
    var _cam =
        view_camera[0];

    if (_cam != -1)
    {
        var _cam_y =
            camera_get_view_y(_cam);

        var _cam_h =
            camera_get_view_height(_cam);

        var _player_screen_y =
            obj_player.y
            -
            _cam_y;

        // Altura aproximada del cuadro en coordenadas de room.
        // Tu cámara es 320x240 y el textbox ocupa alrededor de 70 px.
        var _textbox_h =
            70;

        var _margin =
            12;


        // =================================================
        // PLAYER EN LA MITAD INFERIOR
        // -> TEXTBOX ARRIBA
        // =================================================

        if (
            _player_screen_y
            >=
            _cam_h * 0.5
        )
        {
            y =
                _cam_y
                +
                _margin;
        }


        // =================================================
        // PLAYER EN LA MITAD SUPERIOR
        // -> TEXTBOX ABAJO
        // =================================================

        else
        {
            y =
                _cam_y
                +
                _cam_h
                -
                _textbox_h
                -
                _margin;
        }
    }
}
