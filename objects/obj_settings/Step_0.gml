/// =========================================================
/// OBJ_SETTINGS
/// STEP
/// =========================================================
//
// IMPORTANTE:
//
// La party NO se actualiza aquí.
//
// scr_party_update() debe seguir ÚNICAMENTE en:
//
//     obj_settings -> End Step
//
// =========================================================


// Gestionar una posible cinemática que quedó pendiente
// desde el obj_warp_block utilizado.
scr_cutscene_warp_entry_update();
