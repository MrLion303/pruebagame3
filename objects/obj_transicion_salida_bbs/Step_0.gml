/// =========================================================
/// OBJ_TRANSICION_SALIDA_BBS
/// STEP
/// =========================================================

var _ultimo_frame =
    sprite_get_number(sprite_index) - 1;


// =========================================================
// CERRAR EN BBS
// =========================================================

if (
    image_speed > 0
    &&
    !fase_salida
    &&
    image_index >= _ultimo_frame
)
{
    fase_salida =
        true;


    if (instance_exists(obj_batalla_ui))
    {
        instance_destroy(
            obj_batalla_ui
        );
    }


    if (instance_exists(obj_batalla_controller))
    {
        instance_destroy(
            obj_batalla_controller
        );
    }


    if (variable_global_exists("return_room"))
    {
        room_goto(
            global.return_room
        );
    }
    else
    {
        room_goto(
            pasillo_school
        );
    }


    image_speed =
        -0.5;


    image_index =
        _ultimo_frame;


    exit;
}


// =========================================================
// FALLBACK AL REPRODUCIR HACIA ATRÁS
// =========================================================

if (
    fase_salida
    &&
    image_speed < 0
    &&
    image_index <= 0
)
{
    f_finalizar_retorno();
}
