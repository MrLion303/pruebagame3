/// =========================================================
/// OBJ_PLATFORMER_WARP
/// CREATE
/// =========================================================
///
/// Objeto de entrada / salida del modo plataformero.
///
/// Se activa con:
///
///     Z
///     Enter
///
/// Usa obj_warp para conservar la transición universal.
/// =========================================================


// =========================================================
// DESTINO
// =========================================================

target_room =
    noone;


target_x =
    0;


target_y =
    0;


target_face =
    DOWN;


target_music =
    -1;


keep_music =
    false;


// =========================================================
// MODO
// =========================================================
//
// true:
//     al usarlo ENTRA al plataformero.
//
// false:
//     al usarlo SALE del plataformero.
// =========================================================

platformer_enable =
    true;


// Dirección horizontal con la que Maya empieza:
//
//     1  = derecha
//     -1 = izquierda
platformer_start_facing =
    1;


// =========================================================
// INTERACCIÓN
// =========================================================

active =
    true;


interaction_distance =
    48;


interaction_locked =
    false;


// Si quieres ponerle sprite:
// asígnalo desde el Object Editor.
//
// No necesita ser Solid.
