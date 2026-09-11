// =========================================================
// PARA CUALQUIER OTRO OBJETO QUE DEBA PASAR
// DELANTE / DETRÁS DEL PLAYER
// =========================================================
//
// Añade UNA sola vez en su Create:
//
//     scr_depth_sort_register(id);
//
// Y listo.
//
// No necesita Step especial.
// obj_settings actualiza el depth automáticamente.
//
// ---------------------------------------------------------
// AJUSTE OPCIONAL DEL PUNTO DE APOYO
// ---------------------------------------------------------
//
// Si visualmente su "base" no coincide con bbox_bottom:
//
//     scr_depth_sort_register(id, 0, -4);
//
// El tercer valor mueve el punto de profundidad.
//
// ---------------------------------------------------------
// AJUSTE OPCIONAL DE EMPATE
// ---------------------------------------------------------
//
//     scr_depth_sort_register(id, -1, 0);
//
// Un bias más negativo lo pone ligeramente más delante
// cuando ambos tienen exactamente la misma Y.
//
