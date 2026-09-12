/// =========================================================
/// OBJ_SETTINGS
/// STEP COMPLETO
/// =========================================================
///
/// Mantiene sincronizado el equipamiento persistente y limpia
/// las dos armas eliminadas.
/// =========================================================


// =========================================================
// INVENTARIOS
// =========================================================

scr_inventarios_data();


// Elimina de saves existentes:
//
//     lanza_tardia
//     cuchillas_tardias
//
scr_equips_cleanup_removed();


// =========================================================
// SINCRONIZAR EQUIPAMIENTO ACTIVO
// =========================================================

if (instance_exists(obj_player))
{
    var _equip_player =
        instance_find(
            obj_player,
            0
        );


    if (_equip_player != noone)
    {
        if (
            variable_instance_exists(
                _equip_player,
                "equipo_arma"
            )
        )
        {
            global.inventory_data.equipado_arma =
                _equip_player.equipo_arma;


            global.equipped_arma =
                _equip_player.equipo_arma;
        }


        if (
            variable_instance_exists(
                _equip_player,
                "equipo_armadura"
            )
        )
        {
            global.inventory_data.equipado_armadura =
                _equip_player.equipo_armadura;


            global.equipped_armadura =
                _equip_player.equipo_armadura;
        }
    }
}


// Mantener ambas referencias de inventario sincronizadas.
if (
    variable_global_exists(
        "equipment_inventory"
    )
    &&
    is_array(
        global.equipment_inventory
    )
)
{
    global.inventory_data.equipamiento =
        global.equipment_inventory;
}


// =========================================================
// CINEMÁTICA DE WARP
// =========================================================

scr_cutscene_warp_entry_update();
