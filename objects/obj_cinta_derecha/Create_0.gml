/// =========================================================
/// OBJ_CINTA_DERECHA
/// CREATE
/// =========================================================
///
/// IMPORTANTE:
///
/// - Asigna el sprite manualmente desde el Object Editor.
/// - NO se invierte el sprite.
/// - NO se rota el objeto.
/// - La dirección del movimiento está fijada en el Step.
/// =========================================================

image_angle =
    0;


// Conservar SIEMPRE escalas positivas.
// Esto mantiene la misma detección que funciona correctamente
// en obj_cinta_derecha.
image_xscale =
    abs(
        image_xscale
    );


image_yscale =
    abs(
        image_yscale
    );


conveyor_speed =
    4.5;


conveyor_enabled =
    true;


conveyor_respect_collisions =
    true;


image_speed =
    1;
