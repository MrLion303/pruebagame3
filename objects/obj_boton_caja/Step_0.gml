/// =========================================================
/// OBJ_BOTON_CAJA
/// STEP
/// =========================================================


// Buscar una caja bloqueada que esté encima del botón.
box_on_button =
    noone;


var _count =
    instance_number(
        obj_caja_puzzle
    );


for (
    var _i = 0;
    _i < _count;
    _i++
)
{
    var _box =
        instance_find(
            obj_caja_puzzle,
            _i
        );


    // El centro del botón debe quedar dentro de la caja.
    if (
        _box != noone
        &&
        _box.locked
        &&
        point_in_rectangle(
            x,
            y,
            _box.bbox_left,
            _box.bbox_top,
            _box.bbox_right,
            _box.bbox_bottom
        )
    )
    {
        box_on_button =
            _box;

        break;
    }
}


pressed =
    (
        box_on_button
        !=
        noone
    );


// Frame visual.
var _frames =
    sprite_get_number(
        sprite_index
    );


if (
    pressed
    &&
    _frames > 1
)
{
    image_index =
        1;
}
else
{
    image_index =
        0;
}



// =========================================================
// ACTIVAR VÍNCULO DEL PUZZLE
// =========================================================
//
// pressed = false:
//     frame 0
//
// pressed = true:
//     frame 1
//
// Al activarse, destruye obj_barrera_puzzle que compartan:
//
//     puzzle_link_id
//
// =========================================================

if (
    pressed
    &&
    !puzzle_link_activated
)
{
    puzzle_link_activated =
        true;


    if (
        is_string(
            puzzle_link_id
        )
        &&
        puzzle_link_id
        !=
        ""
    )
    {
        var _cantidad_barreras =
            instance_number(
                obj_barrera_puzzle
            );


        // De atrás hacia adelante porque estamos destruyendo
        // instancias durante el recorrido.
        for (
            var _i = _cantidad_barreras - 1;
            _i >= 0;
            _i--
        )
        {
            var _barrera =
                instance_find(
                    obj_barrera_puzzle,
                    _i
                );


            if (
                _barrera != noone
                &&
                instance_exists(
                    _barrera
                )
                &&
                variable_instance_exists(
                    _barrera,
                    "puzzle_link_id"
                )
                &&
                _barrera.puzzle_link_id
                ==
                puzzle_link_id
            )
            {
                with (_barrera)
                {
                    instance_destroy();
                }
            }
        }
    }
}
