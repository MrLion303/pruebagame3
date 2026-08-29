/// =========================================================
/// OBJ_TRANSICION_BBS
/// ANIMATION END
/// =========================================================


// =========================================================
// TERMINÓ DE CERRARSE
// =========================================================

if (
    image_speed > 0
    &&
    !fase_salida
)
{
    fase_salida = true;


    // El cambio de habitación sucede únicamente
    // cuando la pantalla ya está cubierta.
    room_goto(bbs);


    // Ahora reproducimos la transición al revés
    // dentro de la batalla.
    image_speed = -0.5;


    image_index =
        sprite_get_number(sprite_index) - 1;


    exit;
}


// =========================================================
// TERMINÓ DE ABRIRSE
// =========================================================

if (image_speed < 0)
{
    persistent = false;

    instance_destroy();

    exit;
}