/// =========================================================
/// OBJ_BOTON_CAJA
/// CREATE
/// =========================================================
///
/// SPRITE RECOMENDADO:
///
///     frame 0 = botón levantado
///     frame 1 = botón aplastado
///
/// "pressed" queda disponible para otros objetos de puzzle.
/// =========================================================

pressed =
    false;

box_on_button =
    noone;

image_speed =
    0;

image_index =
    0;



// =========================================================
// VÍNCULO DEL PUZZLE
// =========================================================
//
// Creation Code del botón:
//
//     puzzle_link_id = "puerta_1";
//
// Toda obj_barrera_puzzle con la misma ID desaparecerá al
// quedar este botón presionado por una caja.
//
puzzle_link_id =
    "";


// Evita ejecutar la destrucción más de una vez.
puzzle_link_activated =
    false;
