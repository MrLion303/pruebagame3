/// =========================================================
/// OBJ_SETTINGS
/// STEP COMPLETO
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


// =========================================================
// SINCRONIZAR EQUIPAMIENTO ACTIVO CON INVENTARIO PERSISTENTE
// =========================================================
//
// BUG CORREGIDO:
//
// Antes, al equipar una nueva arma:
//
//     obj_player.equipo_arma
//
// cambiaba correctamente, PERO:
//
//     global.inventory_data.equipado_arma
//
// podía quedarse con el arma anterior hasta guardar.
//
// Si Maya se recreaba al cambiar de room, el sistema de carga
// le volvía a poner esa arma antigua. El inventario ya había
// recibido una copia de esa arma al hacer el intercambio, así
// que en el siguiente cambio podía aparecer OTRA copia.
//
// Ejemplo del bug:
//
//     equipada = Raqueta
//     equipas Cuchillo
//     inventario recibe Raqueta
//     cambias room
//     equipada vuelve erróneamente a Raqueta
//     equipas otra arma
//     inventario recibe OTRA Raqueta
//
// Desde ahora el equipo activo se refleja en la estructura
// persistente continuamente.
// =========================================================

scr_inventarios_data();


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


// Mantener también el array persistente apuntando al
// inventario de equipamiento que usa actualmente el menú/tienda.
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

// Gestionar una posible cinemática que quedó pendiente
// desde el obj_warp_block utilizado.
scr_cutscene_warp_entry_update();
