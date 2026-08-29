/// =========================================================
/// OBJ_TRANSICION_BBS
/// STEP
/// =========================================================

var _ultimo_frame =
    sprite_get_number(sprite_index) - 1;


// =========================================================
// SEGURIDAD
// =========================================================
//
// Mientras todavía estamos en el mapa y la transición
// se está cerrando, el jugador permanece bloqueado.
//
// Antes este objeto podía volver a habilitar el movimiento,
// cosa que no queremos durante una cinemática.
// =========================================================

if (
    room != bbs
    &&
    image_speed > 0
)
{
    if (instance_exists(obj_player))
    {
        if (
            variable_instance_exists(
                obj_player,
                "puede_moverse"
            )
        )
        {
            obj_player.puede_moverse = false;
        }


        if (
            variable_instance_exists(
                obj_player,
                "can_move"
            )
        )
        {
            obj_player.can_move = false;
        }
    }
}


// =========================================================
// SEGURIDAD AL ABRIRSE DENTRO DE BBS
// =========================================================

if (
    room == bbs
    &&
    image_speed < 0
    &&
    image_index <= 0
)
{
    persistent = false;
    instance_destroy();
}