/// =========================================================
/// OBJ_SCREEN_SHAKE
/// STEP
/// =========================================================

scr_screen_shake_init();


// =========================================================
// VINCULAR AL BEGIN SCRIPT DE LA CÁMARA
// =========================================================
//
// Se vuelve a asignar de forma segura:
// al cambiar de room, view_camera[0] puede ser otra cámara.
// =========================================================

var _cam =
    view_camera[0];


if (_cam != -1)
{
    camera_set_begin_script(
        _cam,
        scr_screen_shake_camera_begin
    );


    bound_camera =
        _cam;
}
else
{
    bound_camera =
        -1;
}


// =========================================================
// ACTUALIZAR PATRÓN DEL SHAKE
// =========================================================

if (global.screen_shake_timer > 0)
{
    var _ratio =
        clamp(
            global.screen_shake_timer
            /
            max(
                1,
                global.screen_shake_duration
            ),
            0,
            1
        );


    var _amp =
        max(
            1,
            round(
                global.screen_shake_strength
                *
                _ratio
            )
        );


    // Patrón alternante deliberado.
    //
    // No usamos random puro porque varios ceros seguidos
    // podían hacer que un shake corto casi no se percibiera.
    var _phase =
        global.screen_shake_timer
        mod
        4;


    switch (_phase)
    {
        case 0:
            global.screen_shake_x =
                _amp;

            global.screen_shake_y =
                round(
                    _amp
                    *
                    0.35
                );
            break;


        case 1:
            global.screen_shake_x =
                -_amp;

            global.screen_shake_y =
                -round(
                    _amp
                    *
                    0.5
                );
            break;


        case 2:
            global.screen_shake_x =
                round(
                    _amp
                    *
                    0.5
                );

            global.screen_shake_y =
                -_amp;
            break;


        case 3:
            global.screen_shake_x =
                -round(
                    _amp
                    *
                    0.5
                );

            global.screen_shake_y =
                _amp;
            break;
    }


    global.screen_shake_timer--;


    if (global.screen_shake_timer <= 0)
    {
        global.screen_shake_timer =
            0;
    }
}
else
{
    global.screen_shake_x =
        0;


    global.screen_shake_y =
        0;


    global.screen_shake_strength =
        0;


    global.screen_shake_duration =
        1;
}
