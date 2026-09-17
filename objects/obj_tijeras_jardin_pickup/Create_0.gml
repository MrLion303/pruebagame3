/// =========================================================
/// OBJ_TIJERAS_JARDIN_PICKUP
/// CREATE
/// =========================================================

pickup_room =
    room;


pickup_start_x =
    x;


pickup_start_y =
    y;


image_speed =
    0;


// Si existe este sprite, se usa automáticamente.
// Si no existe, conserva el sprite que hayas asignado al objeto.
var _pickup_sprite =
    asset_get_index(
        "spr_tijeras_jardin"
    );


if (
    _pickup_sprite != -1
    &&
    sprite_exists(_pickup_sprite)
)
{
    sprite_index =
        _pickup_sprite;
}


scr_depth_sort_register(
    id
);


// Si ya fue recogido en esta partida o ya tenemos las tijeras,
// no volver a mostrar el objeto.
if (
    scr_tijeras_pickup_was_taken(
        id
    )
    ||
    scr_itemclave_tiene(
        "tijeras_jardin"
    )
)
{
    instance_destroy();
}
