/// =========================================================
/// OBJ_TRANSICION_BBS
/// CREATE
/// =========================================================

// Debe dibujarse por encima de absolutamente todo.
depth = -1000000;

// Tiene que sobrevivir al room_goto(bbs)
// para poder reproducirse al revés dentro de la batalla.
persistent = true;


// =========================================================
// ANIMACIÓN
// =========================================================

image_index = 0;
image_speed = 0.5;


// Evita ejecutar el cambio de room más de una vez.
fase_salida = false;


// =========================================================
// BLOQUEAR JUGADOR
// =========================================================
//
// Tanto las batallas normales como las iniciadas por
// cinemáticas deben impedir que el Player se mueva mientras
// la pantalla se está cerrando.
// =========================================================

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