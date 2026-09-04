/// =========================================================
/// OBJ_SETTINGS
/// ROOM START
/// =========================================================


// =========================================================
// MENÚ
// =========================================================

if (!instance_exists(obj_menu_manager))
{
    instance_create_layer(
        0,
        0,
        "Instances",
        obj_menu_manager
    );
}


// =========================================================
// PARTY
// =========================================================

scr_party_on_room_start();


// =========================================================
// CINEMÁTICA CONFIGURADA DESDE EL WARP
// =========================================================
//
// Si el obj_warp que nos trajo dejó una cinemática pendiente:
//
//     - bloqueamos peligros/triggers desde Room Start;
//     - esperamos a que termine el fade;
//     - luego el Step la inicia.
//
// =========================================================

scr_cutscene_warp_entry_on_room_start();
