/// =========================================================
/// OBJ_WARP_BLOCK
/// CREATE
/// =========================================================

target_x =
    0;

target_y =
    0;

target_rm =
    0;

target_face =
    0;

target_music =
    -1;

keep_music =
    false;


// =========================================================
// CINEMÁTICA AL ENTRAR AL DESTINO
// =========================================================
//
// Vacío:
//     este warp NO inicia cinemática.
//
// Ejemplo:
//     target_cutscene = "entrada_gerson";
//
// =========================================================

target_cutscene =
    "";


// true:
//     solo una vez por partida.
//
// Una Nueva Partida limpia global.cutscene_flags,
// por lo que vuelve a poder ejecutarse.
//
// false:
//     se reproduce cada vez que usas el warp.
//
target_cutscene_once =
    true;
